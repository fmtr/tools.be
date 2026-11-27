import tools

var testing = tools.testing

testing.parametrize("tools_test_tuya_build_command", [
    {"name": "boolean_on", "values": [1, 4, "true", "TuyaSend1 4,1"]},
    {"name": "boolean_off", "values": [1, 5, "off", "TuyaSend1 5,0"]},
    {"name": "other_data_point", "values": [2, 9, "sample-value", "TuyaSend2 9,sample-value"]},
], def(type_id, dp_id, data, expected_command)
    assert(testing.assert_equal(tools.tuya.build_command(type_id, dp_id, data), expected_command, "Tuya command"))
end)
