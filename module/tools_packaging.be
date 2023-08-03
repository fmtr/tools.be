def get_metadata(path)

    # Extract metadata from TAPP path name

    import re
    
    var PATTERN_EXTRAS='(/([a-zA-Z0-9_,.-]+)(\\[([a-zA-Z_,-]+)?\\])?\\.[Tt][Aa][Pp][Pp])#'
    
    var match=re.searchall(PATTERN_EXTRAS, path)

    if !size(match)
        match=[[nil,nil,nil,nil]]
    end

    match=match[0]

    var data={
        'path': match[1],
        'module': match[2],
        'extras': match[3]==nil?nil:string.split(match[4],','),
    }

    return data

end

var mod = module("tools_packaging")
mod.get_metadata=get_metadata

return mod