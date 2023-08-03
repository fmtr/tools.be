import string
import tools_constants as constants
import tools_logger as logger
import tools_converter as converter
import tools_tuya as tuya
import tools_logging as logging
import tools_random as random
import tools_module
import tools_lazy_import as lazy_import
import tools_callbacks
import tools_network
import tools_web
import tools_update
import tools_iterator
import tools_mqtt
import tools_platform
import tools_packaging

var mod = module(constants.NAME)
mod.VERSION=constants.VERSION

mod.lazy_import=lazy_import
mod.network=tools_network
mod.web=tools_web
mod.update=tools_update
mod.iterator=tools_iterator
mod.mqtt=tools_mqtt
mod.platform=tools_platform
mod.packaging=tools_packaging

mod.logger=logger
mod.constants=constants
mod.converter=converter
mod.tuya=tuya
mod.logging=logging
mod.random=random
mod.module=tools_module
mod.callbacks=tools_callbacks

def autoexec()
    logger.logger.info("Successfully imported tools.be version "+constants.VERSION+". You can now access it using the `tools` module, e.g. in `autoexec.be`, Berry Console, etc.")
end

mod.autoexec=autoexec

return mod