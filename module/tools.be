import string
import tools_constants as constants
import tools_converter as converter
import tools_tuya as tuya
import tools_logging as logging

def get_mac()

    var status_net=tasmota.cmd('status 5').find('StatusNET',{})
    var mac_wifi=status_net.find('Mac', constants.MAC_EMPTY)
    var mac_ethernet=status_net.find('Ethernet', {}).find('Mac', constants.MAC_EMPTY)

    if [constants.MAC_EMPTY,nil].find(mac_wifi)==nil
        return mac_wifi
    elif [constants.MAC_EMPTY,nil].find(mac_ethernet)==nil
        return mac_ethernet
    end

    raise "Couldn't get MAC address"
end

def get_mac_short()
    return string.split(string.tolower(get_mac()),':').concat()
end

def get_mac_last_six()
    return string.replace(string.split(get_mac(),':',3)[3],':','')
end

def get_device_name()
    var device_name=tasmota.cmd('DeviceName').find('DeviceName')
    if !device_name
        raise "Couldn't get device name"
    end
    return device_name
end

def read_url(url, retries, logger)

    logger=logging.get_logger_default(logger)

    var client = webclient()
    client.begin(url)
    var status=client.GET()
    if status==200
        return client.get_string()
    else
        logger(string.format('Error reading "%s". Code %s', url, status))
        return false
    end

  end

def download_url(url, file_path, retries, logger)

    logger=logging.get_logger_default(logger)

    retries=retries==nil?10:retries

    try
        tasmota.urlfetch(url,file_path)
        return true
    except .. as exception

        logger(string.format('Error downloading URL "%s" (Code: %s). Retries remaining: %s.', url, exception, retries))

        retries-=1
        if !retries
            return false
        else
            return download_url(url,file_path,retries)
        end

    end
end

def get_topic()
    var topic=tasmota.cmd('topic').find('Topic')
    if !topic
        raise "Couldn't get topic"
    end

    topic=string.replace(topic,'%06X',get_mac_last_six())

    return topic
end

def get_topic_lwt()
    return ['tele',get_topic(),'LWT'].concat('/')
end

def get_uptime_sec()
    var uptime=tasmota.cmd('status 11').find('StatusSTS',{}).find('UptimeSec')
    if uptime==nil
        raise "Couldn't get uptime"
    end
    return uptime
end

def to_chars(s)
    var chars=[]
    for i: 0..(size(s)-1)
        chars.push(s[i])
    end
    return chars
end

def set_default(data,key,value)
    if !data.contains(key)
        data[key]=value
    end
    return data
end

def reverse_map(data)
    var reversed={}
    for key: data.keys()
        reversed[data[key]]=key
    end
    return reversed
end

def get_keys(data)
    var keys=[]
    for key: data.keys()
        keys.push(key)
    end
    return keys
end

def update_map(data,data_update)
    for key: data_update.keys()
        var value=data_update[key]
        if value!=nil
            data[key]=value
        end
    end
    return data
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

def update_tapp(name, url,path_module, logger)

    logger=logging.get_logger_default(logger)

    logger(string.format('Starting %s update...', name))

    var is_download_success=download_url(url,path_module)
    if is_download_success
        logger(string.format('Download %s update succeeded. Restarting...', name))
        tasmota.cmd('restart 1')        
        return true
    else
        logger(string.format('Download %s update failed.', name))
        return false
    end    

end

def get_latest_version(org,repo,logger)    

    logger=logging.get_logger_default(logger)


    logger(string.format('Fetching %s/%s latest version...', org, repo))

    var url=string.format(
        'https://europe-west2-extreme-flux-351112.cloudfunctions.net/get_github_latest_release_version?org=%s&repo=%s',
        org,
        repo
    )

    var version=read_url(url)
    if version
        return version
    else
        logger(string.format('Failed reading %s/%s latest version from URL "%s".', org, repo, url))
        return false
    end

end


var mod = module(constants.NAME)
mod.VERSION=constants.VERSION

mod.get_mac=get_mac
mod.get_mac_short=get_mac_short
mod.get_mac_last_six=get_mac_last_six

mod.get_device_name=get_device_name

mod.converter=converter
mod.tuya=tuya
mod.logging=logging

mod.read_url=read_url
mod.download_url=download_url

mod.get_topic=get_topic
mod.get_topic_lwt=get_topic_lwt
mod.get_uptime_sec=get_uptime_sec
mod.to_chars=to_chars
mod.set_default=set_default
mod.reverse_map=reverse_map
mod.get_keys=get_keys
mod.update_map=update_map

mod.update_tapp=update_tapp

mod.get_latest_version=get_latest_version
mod.get_current_version_tasmota=get_current_version_tasmota

def autoexec()
    logging.log_tools("Successfully imported tools.be version "+constants.VERSION+". You can now access it using the `tools` module, e.g. in `autoexec.be`, Berry Console, etc.")
end

mod.autoexec=autoexec

return mod