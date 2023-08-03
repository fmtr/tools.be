import tools_network

def get_topic()
    var topic=tasmota.cmd('topic').find('Topic')
    if !topic
        raise "Couldn't get topic"
    end

    topic=string.replace(topic,'%06X',tools_network.get_mac_last_six())

    return topic
end

def get_topic_lwt()
    return ['tele',get_topic(),'LWT'].concat('/')
end

var mod = module("tools_mqtt")
mod.get_topic=get_topic
mod.get_topic_lwt=get_topic_lwt

return mod