import tools

var testing = tools.testing

testing.parametrize("tools_test_iterator_get_list", [
    {"name": "first", "values": [["cedar", "maple", "birch"], 0, "cedar"]},
    {"name": "middle", "values": [["cedar", "maple", "birch"], 1, "maple"]},
    {"name": "last", "values": [["cedar", "maple", "birch"], 2, "birch"]},
    {"name": "past_end", "values": [["cedar", "maple", "birch"], 3, "absent"]},
    {"name": "empty", "values": [[], 0, "absent"]},
], def(items, index, expected)
    assert(testing.assert_equal(tools.iterator.get_list(items, index, "absent"), expected, "get_list result"))
end)

def tools_test_iterator_enumerate_and_chars()
    var indexed = tools.iterator.enumerate(["north", "south"])
    assert(testing.assert_equal(size(indexed), 2, "enumeration length"))
    assert(testing.assert_equal(indexed[0].i, 0, "first index"))
    assert(testing.assert_equal(indexed[1].i, 1, "second index"))
    assert(testing.assert_equal(indexed[1].value, "south", "second value"))

    var chars = tools.iterator.to_chars("oak")
    assert(testing.assert_equal(size(chars), 3, "character count"))
    assert(testing.assert_equal(chars[0], "o", "first character"))
    assert(testing.assert_equal(chars[2], "k", "last character"))
end

def tools_test_iterator_map_helpers()
    var data = {"retain": 0, "change": 2}
    tools.iterator.set_default(data, "retain", 9)
    tools.iterator.set_default(data, "add", 4)
    tools.iterator.update_map(data, {"change": 7, "retain": nil})
    assert(testing.assert_equal(data["retain"], 0, "default does not overwrite falsey value"))
    assert(testing.assert_equal(data["add"], 4, "default initializes absent key"))
    assert(testing.assert_equal(data["change"], 7, "update applies value"))

    var reversed = tools.iterator.reverse_map({"left": "right"})
    assert(testing.assert_equal(reversed["right"], "left", "reverse map entry"))
    var keys = tools.iterator.get_keys({"alpha": 1, "beta": 2})
    assert(testing.assert_equal(size(keys), 2, "key count"))
    assert(testing.assert_true(keys.find("alpha") != nil, "first key present"))
    assert(testing.assert_true(keys.find("beta") != nil, "second key present"))
end
