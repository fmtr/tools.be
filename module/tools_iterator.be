class EnumeratedValue

    var value, i

    def init(i,value)
        self.i=i
        self.value=value
    end

end

def to_chars(s)
    var chars=[]
    for i: 0..(size(s)-1)
        chars.push(s[i])
    end
    return chars
end

def set_default(data,key,value)
    if !data.contains(key)
        data[key]=value
    end
    return data
end

def reverse_map(data)
    var reversed={}
    for key: data.keys()
        reversed[data[key]]=key
    end
    return reversed
end

def get_keys(data)
    var keys=[]
    for key: data.keys()
        keys.push(key)
    end
    return keys
end

def update_map(data,data_update)
    for key: data_update.keys()
        var value=data_update[key]
        if value!=nil
            data[key]=value
        end
    end
    return data
end



def enumerate(data)

    var enumerateds=[]
    var count=0
    for datum:data
        enumerateds.push(EnumeratedValue(count,datum))
        count+=1
    end

    return enumerateds

end

def get_list(data,i,default)
    
    return i<=size(data)-1?data[i]:default

end

var mod = module("tools_iterator")

mod.to_chars=to_chars
mod.set_default=set_default
mod.reverse_map=reverse_map
mod.get_keys=get_keys
mod.update_map=update_map
mod.enumerate=enumerate
mod.get_list=get_list

return mod