import math

math.srand(tasmota.millis())

def get_random_real()
    return math.rand()%1048576/real(1048576.)
end

def get_random(a, b)
    if a==nil && b==nil
        return get_random_real()
    end

    if b==nil
        b = a
        a = 0
    end

    if a > b
        var a_old=a
        var b_old=b
        a=b_old
        b=a_old
    end

    var random_real = get_random_real()
    var scaled_number

    if type(a)==type(0) && type(b)==type(0)
        scaled_number = a + int((b - a + 1) * random_real)
    else
        scaled_number = a + (b - a) * random_real
    end

    return scaled_number
end

var mod = module("tools_random")
mod.get_random=get_random

return mod