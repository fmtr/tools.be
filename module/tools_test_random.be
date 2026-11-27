# Bounds and no-argument behavior are checked against the random contract.
import tools

var testing = tools.testing

testing.parametrize("tools_test_random_integer_bounds", [
    {"name": "equal_bounds", "values": [2, 2, 2, 2]},
    {"name": "negative_and_positive", "values": [-5, 3, -5, 3]},
    {"name": "reversed_bounds", "values": [8, -2, -2, 8]},
    {"name": "one_argument", "values": [6, nil, 0, 6]},
], def(lower, upper, expected_lower, expected_upper)
    var result = tools.random.get_random(lower, upper)
    assert(testing.assert_true(result >= expected_lower && result <= expected_upper, "integer random result within inclusive bounds"))
end)

def tools_test_random_without_bounds_is_unit_interval()
    for index: 0..15
        var value = tools.random.get_random()
        assert(testing.assert_true(value >= 0.0 && value < 1.0, "real random result in unit interval"))
    end
end
