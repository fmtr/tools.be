import string
import tools_constants as constants

class Config

    # Module-wide configuration

    static var IS_DEVELOPMENT=string.find(constants.VERSION,'development')>=0

end

var mod = module("tools_config")
mod.Config=Config
return mod