import tools_constants as constants

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


var mod = module("tools_network")
mod.get_mac=get_mac
mod.get_mac_short=get_mac_short
mod.get_mac_last_six=get_mac_last_six

return mod