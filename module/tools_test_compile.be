import tools

var testing = tools.testing

testing.parametrize("tools_test_compile_evaluate", [
    {"name": "addition", "values": ["4 + 5", 9]},
    {"name": "precedence", "values": ["2 + 3 * 4", 14]},
    {"name": "comparison", "values": ["7 > 3", true]},
], def(expression, expected)
    assert(testing.assert_equal(tools.compile.evaluate(expression), expected, "compiled expression result"))
end)
