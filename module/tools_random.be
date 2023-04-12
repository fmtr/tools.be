import math

math.srand(tasmota.millis())

def get_rand(limit)
    return math.rand()%limit
end


var mod = module("tools_random")
mod.get_rand=get_rand

return mod