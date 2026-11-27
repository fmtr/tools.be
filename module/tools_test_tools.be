import tools

var testing = tools.testing

def tools_test_tools_lazy_testing_export()
    assert(testing.assert_not_nil(tools.testing.Runner, "testing runner export"))
    assert(testing.assert_not_nil(tools.testing.parametrize, "parameterization export"))
    assert(testing.assert_equal(tools.VERSION, tools.version, "lazy version export"))
end
