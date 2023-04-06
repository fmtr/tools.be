import tools_constants as constants

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
        log_hct(string.format('Error reading "%s". Code %s', url, status))
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

var mod = module(constants.NAME)
mod.VERSION=constants.VERSION

mod.get_mac=get_mac
mod.get_device_name=get_device_name

mod.to_bool=to_bool
mod.from_bool=from_bool

mod.read_url=read_url
mod.download_url=download_url

log("TLS: Successfully imported tools.be version "+constants.VERSION+". You can now access it using the `tools` module, e.g. in `autoexec.be`, Berry Console, etc.")

return mod