import tools
import path

var testing = tools.testing
var parameterized_names = testing.parametrize("tools_test_testing_parameterized_equality", [
    {"name": "small_integers", "values": [3, 3]},
    {"name": "empty-text", "values": ["", ""]},
    {"name": "zero", "values": [0, 0]},
], def(left, right)
    assert(testing.assert_equal(left, right, "parameterized equality"))
end)

def tools_test_testing_assertion_helpers()
    assert(testing.assert_true(true, "true assertion"))
    assert(testing.assert_false(false, "false assertion"))
    assert(testing.assert_equal("sample-amber", "sample-amber", "equal strings"))
    assert(testing.assert_equal(0, 0, "zero is a valid expected value"))
    assert(testing.assert_near(1.01, 1.0, 0.02, "close reals"))
    assert(testing.assert_not_nil("present", "non-nil value"))
end

def tools_test_testing_assert_raises()
    assert(testing.assert_raises("assert_failed", /->assert(false, "raised sample")))
    assert(testing.assert_raises("assert_failed", /->assert(false, "checked sample"), "checked sample"))
    assert(testing.assert_raises("assert_failed", /->testing.assert_raises("assert_failed", /->nil)))
end

def tools_test_testing_parameterization_registers_named_cases()
    assert(testing.assert_equal(size(parameterized_names), 3, "generated test count"))
    assert(testing.assert_equal(parameterized_names[0], "tools_test_testing_parameterized_equality_small_integers", "first generated name"))
end

def tools_test_testing_spy_records_calls_and_stubs()
    var spy = testing.Spy()
    spy.stub("publish", "queued")
    var result = spy.publish("channel-saffron", "payload-elm")
    assert(testing.assert_equal(result, "queued", "stubbed return value"))
    assert(spy.assert_called("publish", ["channel-saffron", "payload-elm"], 1))
    spy.reset()
    assert(spy.assert_called("publish", [], 0))
end

def tools_test_testing_spy_assertions_reject_wrong_calls()
    var spy = testing.Spy()
    spy.send("message-lilac")
    assert(testing.assert_raises("assert_failed", /->spy.assert_called("send", ["message-silver"], 1)))
    assert(testing.assert_raises("assert_failed", /->spy.assert_called("send", ["message-lilac"], 2)))
end

def tools_test_testing_with_stub_restores_on_return_and_error()
    var target = module("sample_testing_stub_target")
    target.transform = def(value)
        return value * 2
    end
    var spy = testing.Spy()
    spy.stub("transform", "replaced")

    var result = testing.with_stub(target, "transform", spy.callback("transform"), def()
        return target.transform(6)
    end)
    assert(testing.assert_equal(result, "replaced", "stubbed call result"))
    assert(spy.assert_called("transform", [6], 1))
    assert(testing.assert_equal(target.transform(6), 12, "original member restored after return"))

    assert(testing.assert_raises("assert_failed", /->testing.with_stub(target, "transform", spy.callback("transform"), /->assert(false, "stub callback failure"))))
    assert(testing.assert_equal(target.transform(7), 14, "original member restored after callback error"))
end

def tools_test_testing_runner_records_success_and_failure()
    var runner = testing.Runner("unused", 5, nil)
    var success = {"suite": "sample-suite", "name": "sample-success", "function": /->true}
    var failure = {"suite": "sample-suite", "name": "sample-failure", "function": /->assert(false, "runner sample")}

    assert(testing.assert_true(runner._run_case(success), "successful case result"))
    assert(testing.assert_equal(runner.progress["completed"], 1, "first completed case count"))
    assert(testing.assert_equal(runner.progress["last_test"], "sample-suite.sample-success", "first completed test"))
    assert(testing.assert_true(runner.progress["last_test_passed"], "first test result"))
    assert(testing.assert_false(runner._run_case(failure), "failed case result"))
    assert(testing.assert_equal(runner.passed, 1, "successful case count"))
    assert(testing.assert_equal(runner.failed, 1, "failed case count"))
    assert(testing.assert_equal(size(runner.failures), 1, "recorded failure count"))
    assert(testing.assert_equal(runner.failures[0]["name"], "sample-suite.sample-failure", "recorded failed case"))
    assert(testing.assert_equal(runner.progress["completed"], 2, "completed case count"))
    assert(testing.assert_equal(runner.progress["last_test"], "sample-suite.sample-failure", "last completed test"))
    assert(testing.assert_false(runner.progress["last_test_passed"], "last test result"))
    assert(testing.assert_true(runner.progress["updated_at_ms"] != nil, "last progress update timestamp"))
end

def tools_test_testing_focus_selects_exact_module_stems()
    var all_modules = testing.Runner("tools", 5, nil)
    var focused_modules = testing.Runner("tools", 5, ["tools_test_converter"])
    assert(all_modules._is_selected("tools_test_converter"))
    assert(focused_modules._is_selected("tools_test_converter"))
    assert(testing.assert_false(focused_modules._is_selected("tools_test_iterator"), "unfocused module"))
end

def tools_test_testing_runner_defaults_empty_base_dir_to_root()
    var missing_dir_runner = testing.Runner("unused", 5, nil)
    var empty_dir_runner = testing.Runner("unused", 5, nil, "")

    assert(testing.assert_equal(missing_dir_runner.base_dir, "/", "default test directory"))
    assert(testing.assert_equal(empty_dir_runner.base_dir, "/", "empty test directory"))
    assert(testing.assert_equal(missing_dir_runner._test_file_path("tools_test_sample.be"), "tools_test_sample.be", "root test path"))
end

def tools_test_testing_runner_uses_archive_base_dir()
    var archive_dir = "sample-tests.tapp#"
    var runner = testing.Runner("unused", 5, nil, archive_dir)
    var listdir_spy = testing.Spy()
    listdir_spy.stub("listdir", [])

    assert(testing.assert_raises("assert_failed", /->testing.with_stub(path, "listdir", listdir_spy.callback("listdir"), /->runner._load_tests())))
    assert(listdir_spy.assert_called("listdir", [archive_dir], 1))
    assert(testing.assert_equal(runner._test_file_path("tools_test_sample.be"), archive_dir .. "tools_test_sample.be", "archive test path"))
end
