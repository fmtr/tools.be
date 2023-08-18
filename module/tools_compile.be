def evaluate(code)
    return compile("return "+str(code))()
end

var mod = module("tools_compile")
mod.evaluate=evaluate

return mod