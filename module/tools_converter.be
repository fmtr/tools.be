import string
import tools_constants as constants

def to_bool(value)
    return [str(true),str(1),string.tolower(constants.ON)].find(string.tolower(str(value)))!=nil
end

def from_bool(value)
    return to_bool(value)?constants.ON:constants.OFF
end

var mod = module("tools_converter")
mod.to_bool=to_bool
mod.from_bool=from_bool
return mod