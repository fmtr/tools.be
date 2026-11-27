import tools

var testing = tools.testing

def tools_test_platform_readonly_values()
    assert(testing.assert_not_nil(tools.platform.get_device_name(), "device name"))
    assert(testing.assert_true(tools.platform.get_uptime_sec() >= 0, "uptime is nonnegative"))
    assert(testing.assert_not_nil(tools.platform.get_current_version_tasmota(), "firmware version"))
    assert(testing.assert_not_nil(tools.platform.get_memory_kb(), "heap report"))
end
