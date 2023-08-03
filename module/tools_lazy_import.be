# Keep this light as it will be early-imported by all lazy import libraries.

def create_monad(name,object)
    var mod = module(name)
    mod.init = def (_) return object end
    return mod
end

class DynamicClassReadOnly

    static var MEMBERS

    def member(name)
        if self.MEMBERS.contains(name)
            return self.MEMBERS[name](self)
        else
            import undefined
            return undefined
        end
    end

end

class LazyImportInterface: DynamicClassReadOnly

    static var NAME

    def create_module()
        return create_monad(self.NAME, self)
    end

end

var mod = module("tools_lazy_import")

mod.create_monad=create_monad
mod.LazyImportInterface=LazyImportInterface

return mod