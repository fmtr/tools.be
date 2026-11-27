import tools_converter as converter

def build_command(type_id,dp_id,data)
    import string

    if type_id==1
        data=int(converter.to_bool(data))
    end

    return string.format('TuyaSend%s %s,%s',type_id,dp_id,data)
end

def send(type_id,dp_id,data)
    return tasmota.cmd(build_command(type_id,dp_id,data))
end

var mod = module("tools_tuya")
mod.build_command=build_command
mod.send=send
return mod
