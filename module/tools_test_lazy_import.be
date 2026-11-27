import tools

var testing = tools.testing

def tools_test_lazy_import_monad_returns_wrapped_object()
    var wrapped = {"sample-key": "sample-value"}
    var lazy_module = tools.lazy_import.create_monad("sample_lazy_import_probe", wrapped)
    assert(testing.assert_equal(lazy_module.init(nil)["sample-key"], "sample-value", "wrapped module value"))
end
