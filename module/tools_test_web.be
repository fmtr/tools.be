import tools

var testing = tools.testing

testing.parametrize("tools_test_web_resolve_path", [
    {"name": "filename_from_url", "values": ["https://sample.invalid/assets/model.bin", nil, "model.bin"]},
    {"name": "root_uses_index", "values": ["https://sample.invalid/", nil, "index.html"]},
    {"name": "explicit_path_preserved", "values": ["https://sample.invalid/assets/model.bin", "/cache/model.bin", "/cache/model.bin"]},
], def(url, requested_path, expected_path)
    assert(testing.assert_equal(tools.web.resolve_path(url, requested_path), expected_path, "resolved download path"))
end)
