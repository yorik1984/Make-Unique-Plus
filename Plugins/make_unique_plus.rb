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
# License GPLv3
# Version: 1.0
# Description: Loader for make_unique_plus/make_unique_plus_core.rb
# History:
# - 1.0 Initial release 26-Jan-2017
# ------------------------------------------------------------------------------

require "sketchup.rb"
require "extensions.rb"

# Personal name space of yorik1984 in SketchUp plugins development.
#
# @author Yurij Kulchevich aka yorik1984
module YorikTools

  # Loader of Make Unique Plus - Plugin for making unique selected components.
  #
  # @author Yurij Kulchevich aka yorik1984
  module MakeUniquePlus

    FILENAMESPACE      = File.basename(__FILE__, ".rb")
    PATH_ROOT          = File.dirname(__FILE__).freeze
    PATH               = File.join(PATH_ROOT, FILENAMESPACE).freeze

    PLUGIN_COPYRIGHT   = "© by Yurij Kulchevich aka yorik1984".freeze
    PLUGIN_CREATOR     = "© Юрий Кульчевич aka yorik1984".freeze
    PLUGIN_ID          = "MakeUniquePlus".freeze
    PLUGIN_NAME        = "Make Unique Plus".freeze
    PLUGIN_VERSION     = "1.0".freeze

    plugin_description = "Plugin for making unique selected components"
    unless file_loaded?(__FILE__)
      loader                 = File.join( PATH, FILENAMESPACE + "_core.rb" )
      @make_unique_plus             = SketchupExtension.new(PLUGIN_NAME, loader)
      @make_unique_plus.description = plugin_description
      @make_unique_plus.version     = PLUGIN_VERSION
      @make_unique_plus.copyright   = PLUGIN_COPYRIGHT
      @make_unique_plus.creator     = PLUGIN_CREATOR
      Sketchup.register_extension(@make_unique_plus, true)
    end

  end # module MakeUniquePlus

end # module YorikTools

file_loaded(__FILE__)
