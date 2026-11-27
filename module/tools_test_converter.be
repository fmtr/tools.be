import tools

var testing = tools.testing

testing.parametrize("tools_test_converter_to_bool", [
    {"name": "uppercase_on", "values": ["ON", true]},
    {"name": "mixed_case_true", "values": ["TrUe", true]},
    {"name": "numeric_one", "values": [1, true]},
    {"name": "uppercase_off", "values": ["OFF", false]},
    {"name": "unrecognized_text", "values": ["disabled-word", false]},
], def(value, expected)
    assert(testing.assert_equal(tools.converter.to_bool(value), expected, "to_bool result"))
end)

testing.parametrize("tools_test_converter_from_bool", [
    {"name": "true_value", "values": [true, "ON"]},
    {"name": "false_value", "values": [false, "OFF"]},
], def(value, expected)
    assert(testing.assert_equal(tools.converter.from_bool(value), expected, "from_bool result"))
end)
