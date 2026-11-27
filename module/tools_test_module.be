import tools
import introspect

var testing = tools.testing

class SampleModuleExport
    var value
    def init()
        self.value = "exported"
    end
end

def tools_test_module_exports_classes()
    var created = tools.module.create_module("sample_module_probe", [SampleModuleExport])
    assert(testing.assert_true(introspect.members(created).find("SampleModuleExport") != nil, "class member exported"))
    assert(testing.assert_equal(created.SampleModuleExport().value, "exported", "exported class remains constructible"))
end
