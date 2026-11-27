import tools
import string

var testing = tools.testing

def tools_test_constants_version_and_names()
    assert(testing.assert_equal(tools.constants.VERSION, tools.version, "version shared by modules"))
    assert(testing.assert_equal(tools.constants.NAME, "tools", "package name"))
    assert(testing.assert_equal(tools.constants.ON, "ON", "on constant"))
    assert(testing.assert_equal(tools.constants.OFF, "OFF", "off constant"))
    assert(testing.assert_equal(tools.constants.IS_DEVELOPMENT, string.find(tools.constants.VERSION, "development") >= 0, "development version flag"))
end

def tools_test_constants_optional_web_feature_is_boolean()
    assert(testing.assert_true(type(tools.constants.WEB_CLIENT_SUPPORTS_REDIRECTS) == "bool", "web redirect capability flag"))
end
