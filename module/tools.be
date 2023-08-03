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

def get_device_name()
    var device_name=tasmota.cmd('DeviceName').find('DeviceName')
    if !device_name
        raise "Couldn't get device name"
    end
    return device_name
end

def get_uptime_sec()
    var uptime=tasmota.cmd('status 11').find('StatusSTS',{}).find('UptimeSec')
    if uptime==nil
        raise "Couldn't get uptime"
    end
    return uptime
end



def get_current_version_tasmota()

    import string

    var version_current=tasmota.cmd('status 2').find('StatusFWR',{}).find('Version','Unknown')
    var tas_seps=['(tasmota32)','(tasmota)']

    var sep
    for tas_sep: tas_seps
        if string.find(version_current,tas_sep)>=0
            sep=tas_sep
        end
    end

    if sep==nil
        return version_current
    end

    var mmp=string.split(version_current,sep)[0]
    var build=string.replace(string.replace(sep,'(',''),')','')

    return string.format("%s", mmp)

end

def get_metadata(path)

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
mod.get_device_name=get_device_name
mod.logger=logger
mod.constants=constants
mod.converter=converter
mod.tuya=tuya
mod.logging=logging
mod.random=random
mod.module=tools_module
mod.callbacks=tools_callbacks

mod.get_uptime_sec=get_uptime_sec

mod.iterator=tools_iterator
mod.mqtt=tools_mqtt

mod.get_current_version_tasmota=get_current_version_tasmota

def autoexec()
    logger.logger.info("Successfully imported tools.be version "+constants.VERSION+". You can now access it using the `tools` module, e.g. in `autoexec.be`, Berry Console, etc.")
end

mod.autoexec=autoexec

return mod