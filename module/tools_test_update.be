import tools

var testing = tools.testing

def tools_test_update_stubs_failed_download_without_restarting()
    var download_spy = testing.Spy()
    download_spy.stub("download_url", false)
    var url = "https://example.invalid/archive"
    var destination = "/sample.tapp"

    var result = testing.with_stub(tools.web, "download_url", download_spy.callback("download_url"), def()
        return tools.update.update_tapp_github_asset(url, "sample-org", "sample-project", "sample.tapp", destination)
    end)

    assert(testing.assert_false(result, "download failure result"))
    assert(download_spy.assert_called("download_url", [url, destination, nil], 1))
end
