import tools_converter as converter

def send(type_id,dp_id,data)

    import string

    if type_id==1
        data=int(converter.to_bool(data))
    end

    var cmd=string.format('TuyaSend%s %s,%s',type_id,dp_id,data)
    return tasmota.cmd(cmd)
end

var mod = module("tools_tuya")
mod.send=send
return mod