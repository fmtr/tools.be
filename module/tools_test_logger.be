import tools

var testing = tools.testing

def tools_test_logger_singleton_configuration()
    assert(testing.assert_equal(tools.logger.logger.prefix, "T.B", "singleton prefix"))
    assert(testing.assert_equal(tools.logger.logger.level, tools.logging.Logger.DEBUG_MORE, "singleton level"))
    assert(testing.assert_equal(tools.logger.logger.log_repl, tools.config.Config.IS_DEVELOPMENT, "repl output follows development mode"))
end
