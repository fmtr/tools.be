# Exercises startup logging without freezing human-facing copy.
import tools
import tools_autoexec
import global

var testing = tools.testing

def tools_test_autoexec_logs_startup_message()
    var original_log = global.member("log")
    var log_spy = testing.Spy()
    var result = testing.with_stub(global, "log", log_spy.callback("log"), def()
        return tools_autoexec.autoexec({"channel_id": "release", "import": false})
    end)
    var message = log_spy.calls[0]["args"][0]

    assert(testing.assert_equal(result, nil, "autoexec return value"))
    assert(testing.assert_true(size(message) > 0, "startup message is nonempty"))
    assert(log_spy.assert_called("log", [message], 1))
    assert(testing.assert_true(global.member("log") == original_log, "log binding restored after stub"))
end
