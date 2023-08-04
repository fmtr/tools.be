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

def get_memory_kb()
    return tasmota.cmd('Status 4').find('StatusMEM',{}).find('Heap','Unknown')
end

var mod = module("tools_platform")

mod.get_device_name=get_device_name
mod.get_uptime_sec=get_uptime_sec
mod.get_memory_kb=get_memory_kb
mod.get_current_version_tasmota=get_current_version_tasmota

return mod