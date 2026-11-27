import tools

var testing = tools.testing

def tools_test_callbacks_registry_tracks_and_removes_timer()
    var registry = tools.callbacks.Registry()
    var fired = false
    var timer = tools.callbacks.Timer(60000, def() fired = true end, "sample-test-timer")
    registry.add(timer, nil)
    var found = registry.get("sample-test-timer")
    registry.remove("sample-test-timer")

    assert(testing.assert_true(found == timer, "registered timer lookup"))
    assert(testing.assert_false(timer.enabled, "removed timer disabled"))
    assert(testing.assert_false(registry.data.contains("sample-test-timer"), "removed timer absent from registry"))
    assert(testing.assert_false(fired, "long-delay timer did not fire during removal"))
end
