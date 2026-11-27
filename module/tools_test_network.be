import tools
import string

var testing = tools.testing

def tools_test_network_mac_formats_are_consistent()
    var mac = tools.network.get_mac()
    var parts = string.split(mac, ":")
    var short_mac = string.tolower(parts[0] .. parts[1] .. parts[2] .. parts[3] .. parts[4] .. parts[5])
    var expected_tail = string.tolower(parts[3] .. parts[4] .. parts[5])
    assert(testing.assert_equal(size(parts), 6, "MAC address octet count"))
    assert(testing.assert_equal(tools.network.get_mac_short(), short_mac, "compact MAC format"))
    assert(testing.assert_equal(string.tolower(tools.network.get_mac_last_six()), expected_tail, "last three MAC octets"))
end
