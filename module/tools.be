import tools_constants as constants

var mod = module(constants.NAME)
mod.VERSION=constants.VERSION

log("TLS: Successfully imported tools.be version "+constants.VERSION+". You can now access it using the `tools` module, e.g. in `autoexec.be`, Berry Console, etc.")

return mod