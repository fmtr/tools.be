import tools

var testing = tools.testing

testing.parametrize("tools_test_logging_level_names", [
    {"name": "none", "values": [0, "NONE"]},
    {"name": "error", "values": [1, "ERROR"]},
    {"name": "info", "values": [2, "INFO"]},
    {"name": "debug", "values": [3, "DEBUG"]},
    {"name": "debug_more", "values": [4, "DEBUG_MORE"]},
], def(level, expected_name)
    assert(testing.assert_equal(tools.logging.Logger.get_level_name(level), expected_name, "level name"))
end)

def tools_test_logging_logger_configuration()
    var logger = tools.logging.Logger("sample-prefix", tools.logging.Logger.INFO, false)
    assert(testing.assert_equal(logger.prefix, "SAMPLE-PREFIX", "normalized prefix"))
    assert(testing.assert_equal(logger.level, tools.logging.Logger.INFO, "configured level"))
    assert(testing.assert_false(logger.log_repl, "repl output disabled"))
end
