import tools

var testing = tools.testing

def tools_test_config_development_flag_matches_constants()
    assert(testing.assert_equal(tools.config.Config.IS_DEVELOPMENT, tools.constants.IS_DEVELOPMENT, "development flags match"))
end
