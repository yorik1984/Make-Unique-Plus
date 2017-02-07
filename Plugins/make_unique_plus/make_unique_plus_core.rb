# Copyright 2017 by Yurij Kulchevich aka yorik1984
#
# This file is part of "Yorik Tools".
#
# "Yorik Tools" is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License.
#
# "Yorik Tools" is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with "Yorik Tools".  If not, see <http://www.gnu.org/licenses/>.
# ------------------------------------------------------------------------------
# Using ideas from source code
# honoluludesktop
# and plugin "Make Unique Selected Components" make_all_unique.rb
# ------------------------------------------------------------------------------
# License GPLv3
# Version: 1.0
# History:
# - 1.0 Initial release 26-Jan-2017
# ------------------------------------------------------------------------------
require "sketchup.rb"
require "extensions.rb"


# Core of Make Unique Plus - Plugin for making unique selected components..
#
# @author Yurij Kulchevich aka yorik1984
module YorikTools::MakeUniquePlus

  # Inputbox of nesting level
  #
  # @author Yurij Kulchevich aka yorik1984
  # @since 1.0
  class LevelInputbox

    # initialize method
    #
    # @since 1.0
    def initialize

      @prompts  = [ "Component nesting levels (biggest = All)", "Report" ]
      @defaults = ["2", "Off" ]
      @list     = ["", "Off|Short in messagebox|Full in console" ]
      @inputbox = []
    end

    # initialize method
    # @param selection [Sketchup::Selection] Selected components of the model
    # @param parent_level [Boolean] label of parent level components only
    #
    # @return [Hash] result answer from inputbox
    # @since 1.0
    def inputbox(selection, parent_level)
      nested_level_list = "2"
      if parent_level
        @inputbox[0] = nested_level_list
        @inputbox[1] = "Off"
      else
        real_nested_level = nested_level(selection)
        if real_nested_level > 2
          for i in 3..real_nested_level
            nested_level_list += "|#{i}"
          end
        end
        @list[0] = nested_level_list
        @inputbox = UI.inputbox(@prompts, @defaults, @list, "Make unique options")
      end
      input_labels = { :recursive => @inputbox[0],
                          :report => @inputbox[1] }
      return input_labels
    end

    # Recursive method to get maximum nested level in selected components
    #
    # @param selection [Sketchup::Selection] Selected components of the model
    # @param deep_level [Numeric] Temp variable.
    #        Default is parent deep level of the model
    # @param nesting_levels [Array] Collection of every nested level from
    #        maximum deep levels in the model components collection.
    #        Default are parent nested level of the model
    #
    # @return [Numeric] Biggest nested level of components nesting levels
    # @since 1.0
    def nested_level(selection, deep_level = 1, nesting_levels = [1])
      selection.each do |entity|
        definition = YorikTools::MakeUniquePlus::get_definition(entity)
        next if definition.nil?
        nesting_levels.push(deep_level + 1)
        nested_level(definition.entities, deep_level + 1, nesting_levels)
      end
      return nesting_levels.sort.last
    end

  end # class LevelInputbox

  # Get definition of the entity
  #
  # @param entity [Sketchup::Entity] any entity in the model
  # @return [Sketchup::ComponentDefinition or NilClass] definition of the entity
  # @since 1.0
  def self.get_definition(entity)
    if entity.is_a?(Sketchup::ComponentInstance)
      entity.definition
    elsif entity.is_a?(Sketchup::Group)
      entity.entities.parent
    else
      nil
    end
  end

  # Recursive method to get collection of components with attributes from list
  #
  # @param selection [Sketchup::Selection] Selected components of the model
  # @param nested_level [Numeric] maximum nested level for collecting components
  # @param components_list [Array] empty array before start for doing collection
  # @param current_nested_level [Numeric] nested level of current entity
  #
  # @return [Array] collection of unique components
  # @see nested_level
  # @since 1.0
  def self.collect_uniq_components(selection,
                                   nested_level,
                                   current_nested_level = 2,
                                   components_list = [])
    selection.each do |entity|
      definition = self.get_definition(entity)
      next if definition.nil?
      if current_nested_level <= nested_level &&
        entity.is_a?(Sketchup::ComponentInstance)
        separator = "  "
        if current_nested_level > 2
          for i in 3..current_nested_level
            separator += "| "
          end
        end
        components_list_row_tmp = ""
        level = current_nested_level.to_s + separator
        original_component_name = "#{entity.definition.name}"
        entity.make_unique
        unique_component_name = "#{entity.definition.name}"
        if original_component_name != unique_component_name
          components_list.push("#{level[0,3]}#{separator} " +
              original_component_name + " => " +  unique_component_name)
        else
          components_list.push("#{level[0,3]}#{separator} " +
              original_component_name + " => " +  "NO CHANGE")
        end

      end
      components_list =
          self.collect_uniq_components(definition.entities, nested_level,
              current_nested_level + 1, components_list)
    end
    return components_list
  end # collect_uniq_components

  # Main method of plugin to get basic data from user
  # @param selection [Sketchup::Selection] Selected components of the model
  # @param parent_level [Boolean] label of parent level components only
  #
  # @since 1.0
  def self.make_unique(selection, parent_level)
    make_unique_inputbox = LevelInputbox.new
    input = make_unique_inputbox.inputbox(selection, parent_level)
    model = Sketchup.active_model
    status = model.start_operation('Make unique', true)
    nested_level = input[:recursive].to_i
    report = input[:report].to_s
    total_count = self.collect_uniq_components(selection, nested_level)
    case report
    when "Short in messagebox"
      UI.messagebox("#{total_count.length} component(s) were made unique")
    when "Full in console"
      su_version_required = 14
      if Sketchup.version.to_f >= su_version_required
        SKETCHUP_CONSOLE.show if !SKETCHUP_CONSOLE.visible?
      end
      puts "========================================"
      puts "#{total_count.length} component(s) were made unique"
      puts "========================================"
      puts total_count
      puts "========================================"
    else
      nil
    end
    model.commit_operation
  end # make_unique

  unless file_loaded?(__FILE__)
      UI.add_context_menu_handler do |menu|
      selection = Sketchup.active_model.selection
      definition = self.get_definition(selection[0])
      unless definition.nil?
          sub_menu = menu.add_submenu(PLUGIN_NAME)
          sub_menu.add_item("Only parent level"){ self.make_unique(selection, true) }
          sub_menu.add_item("Choose nested level..."){ self.make_unique(selection, false) }
        end
    end
  end

end # module MakeUniquePlus

file_loaded(__FILE__)
