import tools
import global

var testing = tools.testing

def tools_test_version_matches_package_metadata()
    assert(testing.assert_equal(tools.version, global.TAPP_METADATA["tools"]["version"], "package version metadata"))
end
