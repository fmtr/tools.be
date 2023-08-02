# Keep this light as it will be early-imported by all lazy import libraries.

def create_module(mod,classes)

    import introspect

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

class DynamicClass

    var members

    def init(members)
        self.members = members
    end

    def setmember(name, value)
        self.members[name] = value
    end

    def member(name)
        if self.members.contains(name)
            return self.members[name](self)
        else
            import undefined
            return undefined
        end
    end

end

def create_monad(name,object)
    var mod = module(name)
    mod.init = def (_) return object end
    return mod
end

def create_lazy_import_interface(name,members)
    return create_monad(name, DynamicClass(members))
end

var mod = module("tools_module")
mod.create_module=create_module
mod.create_lazy_import_interface=create_lazy_import_interface

return mod