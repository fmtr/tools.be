import sys
import string

var PATHS=[]

sys.path().push(tasmota.wd)
for path:PATHS
    sys.path().push(string.format("%s/%s", tasmota.wd, path))
end

TAPP_METADATA=global.TAPP_METADATA!=nil?global.TAPP_METADATA:{}

TAPP_METADATA['tools']={
    'path': tasmota.wd,
    'import': false,
    'channel_id': nil,
    'version': '1.0.0-alpha.4',
}

if TAPP_METADATA['tools']['import']
    import tools
    global.tools=tools
end

try import tools_autoexec tools_autoexec.autoexec(TAPP_METADATA['tools']) except 'import_error' end