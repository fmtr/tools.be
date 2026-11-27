import tools
import string

var testing = tools.testing

def tools_test_mqtt_topic_uses_configured_device_topic()
    var topic = tools.mqtt.get_topic()
    assert(testing.assert_true(size(topic) > 0, "resolved topic is nonempty"))
    assert(testing.assert_true(string.find(topic, "%06X") < 0, "MAC placeholder resolved"))
end

def tools_test_mqtt_lwt_topic_has_one_separator()
    var topic = tools.mqtt.get_topic_lwt()
    assert(testing.assert_true(string.endswith(topic, "/LWT"), "LWT suffix"))
    assert(testing.assert_true(string.find(topic, "//") < 0, "no duplicate topic separator"))
    assert(testing.assert_true(string.find(topic, "%topic%") < 0, "topic placeholder resolved"))
    assert(testing.assert_true(string.find(topic, "%prefix%") < 0, "prefix placeholder resolved"))
end
