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

def get_metadata(path)

    # Extract metadata from TAPP path name

    import re
    
    var PATTERN_EXTRAS='(/([a-zA-Z0-9_,.-]+)(\\[([a-zA-Z_,-]+)?\\])?\\.[Tt][Aa][Pp][Pp])#'
    
    var match=re.searchall(PATTERN_EXTRAS, path)

    if !size(match)
        match=[[nil,nil,nil,nil]]
    end

    match=match[0]

    var data={
        'path': match[1],
        'module': match[2],
        'extras': match[3]==nil?nil:string.split(match[4],','),
    }

    return data

end

var mod = module(constants.NAME)
mod.VERSION=constants.VERSION

mod.get_metadata=get_metadata
mod.lazy_import=lazy_import
mod.network=tools_network
mod.web=tools_web
mod.update=tools_update

mod.logger=logger
mod.constants=constants
mod.converter=converter
mod.tuya=tuya
mod.logging=logging
mod.random=random
mod.module=tools_module
mod.callbacks=tools_callbacks



mod.iterator=tools_iterator
mod.mqtt=tools_mqtt
mod.platform=tools_platform



def autoexec()
    logger.logger.info("Successfully imported tools.be version "+constants.VERSION+". You can now access it using the `tools` module, e.g. in `autoexec.be`, Berry Console, etc.")
end

mod.autoexec=autoexec

return mod