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

    import string
    var topic_mask=tasmota.cmd('FullTopic')['FullTopic']
    var prefix=tasmota.cmd('prefix')['Prefix3']

    var topic=topic_mask
    topic=string.replace(topic,'%topic%',get_topic())
    topic=string.replace(topic,'%prefix%',prefix)


    return string.format('%s/LWT',topic)

end

def publish_json(topic,data,retain)
    import mqtt
	import json    
    return mqtt.publish(topic,json.dump(data),retain)
end

var mod = module("tools_mqtt")
mod.get_topic=get_topic
mod.get_topic_lwt=get_topic_lwt
mod.publish_json=publish_json

return mod