import tools

var testing = tools.testing

def tools_test_packaging_extracts_module_and_extras()
    var metadata = tools.packaging.get_metadata("/sample_driver[BLE,DISPLAY].tapp#")
    assert(testing.assert_equal(metadata["path"], "/sample_driver[BLE,DISPLAY].tapp", "archive path"))
    assert(testing.assert_equal(metadata["module"], "sample_driver", "module name"))
    assert(testing.assert_equal(size(metadata["extras"]), 2, "extras count"))
    assert(testing.assert_true(metadata["extras"].find("BLE") != nil, "first extra present"))
    assert(testing.assert_true(metadata["extras"].find("DISPLAY") != nil, "second extra present"))
end

def tools_test_packaging_handles_plain_path()
    var metadata = tools.packaging.get_metadata("/sample_driver.tapp#")
    assert(testing.assert_equal(metadata["path"], "/sample_driver.tapp", "plain archive path"))
    assert(testing.assert_equal(metadata["module"], "sample_driver", "plain module name"))
    assert(testing.assert_equal(metadata["extras"], nil, "no extras"))
end

def tools_test_packaging_ignores_unmatched_path()
    var metadata = tools.packaging.get_metadata("/not-an-archive.bin")
    assert(testing.assert_equal(metadata["path"], nil, "unmatched path"))
    assert(testing.assert_equal(metadata["module"], nil, "unmatched module"))
    assert(testing.assert_equal(metadata["extras"], nil, "unmatched extras"))
end
