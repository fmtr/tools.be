import tools_constants as constants
import string

var MAC_EMPTY='00:00:00:00:00:00'

def get_mac()

    var status_net=tasmota.cmd('status 5').find('StatusNET',{})
    var mac_wifi=status_net.find('Mac', MAC_EMPTY)
    var mac_ethernet=status_net.find('Ethernet', {}).find('Mac', MAC_EMPTY)

    if [MAC_EMPTY,nil].find(mac_wifi)==nil
        return mac_wifi
    elif [MAC_EMPTY,nil].find(mac_ethernet)==nil
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

def to_bool(value)
  return [str(true),str(1),string.tolower(constants.ON)].find(string.tolower(str(value)))!=nil
end

def from_bool(value)
  return to_bool(value)?constants.ON:constants.OFF
end

def read_url(url, retries)

    var client = webclient()
    client.begin(url)
    var status=client.GET()
    if status==200
        return client.get_string()
    else
        log(string.format('TLS: Error reading "%s". Code %s', url, status))
        return false
    end

  end

def download_url(url, file_path, retries)

    retries=retries==nil?10:retries

    try
        tasmota.urlfetch(url,file_path)
        return true
    except .. as exception

        log(['Error downloading URL',str(url),':',str(exception),'.',' Retries remaining: ',str(retries)].concat(''))

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

var mod = module(constants.NAME)
mod.VERSION=constants.VERSION

mod.get_mac=get_mac
mod.get_mac_short=get_mac_short
mod.get_mac_last_six=get_mac_last_six

mod.get_device_name=get_device_name

mod.to_bool=to_bool
mod.from_bool=from_bool

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



log("TLS: Successfully imported tools.be version "+constants.VERSION+". You can now access it using the `tools` module, e.g. in `autoexec.be`, Berry Console, etc.")

return mod