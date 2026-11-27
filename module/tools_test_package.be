import tools

var testing = tools.testing

def tools_test_package_converter_output_feeds_iterator()
    var words = ["on", "off", "true"]
    var booleans = []
    for entry: tools.iterator.enumerate(words)
        booleans.push(tools.converter.to_bool(entry.value))
    end
    assert(testing.assert_equal(size(booleans), 3, "converted value count"))
    assert(testing.assert_true(booleans[0], "first converted value"))
    assert(testing.assert_false(booleans[1], "second converted value"))
    assert(testing.assert_true(booleans[2], "third converted value"))
end
