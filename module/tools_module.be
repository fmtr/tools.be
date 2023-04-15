import introspect

def create_module(mod,classes)

    if type(mod)=='string'
        mod=module(mod)
    end

    if classes==nil
        classes=[]
    end

    if type(classes)=='class'
        classes=[classes]
    end

    for cls: classes
        introspect.set(mod, classname(cls), cls)
    end

    return mod

end

var mod = module("tools_module")
mod.create_module=create_module

return mod