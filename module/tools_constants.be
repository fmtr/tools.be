var VERSION='0.1.4'

import introspect

var mod = module("tools_constants")
mod.VERSION=VERSION
mod.NAME='tools'
mod.NAME_SHORT='t.b'
mod.MAC_EMPTY='00:00:00:00:00:00'

mod.ON='ON'
mod.OFF='OFF'

mod.WEB_CLIENT_SUPPORTS_REDIRECTS=introspect.members(webclient()).find('set_follow_redirects')!=nil

return mod