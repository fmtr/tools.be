import string
import tools_logging as logging
import tools_constants as constants
import tools_config as config

var Logger=logging.Logger

var mod = module("tools_logger")

mod.logger=Logger(
    constants.NAME_SHORT,
    config.Config.IS_DEVELOPMENT?Logger.DEBUG_MORE:Logger.DEBUG_MORE,
    config.Config.IS_DEVELOPMENT
)

return mod