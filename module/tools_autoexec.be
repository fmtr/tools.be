def autoexec(metadata)
    import tools_version    

    var IS_DEVELOPMENT=metadata['channel_id']=='development'

    var message
    if metadata['import']
        message="Successfully imported tools version "+tools_version.VERSION+". You can now access it using the `tools` module, e.g. in `autoexec.be`, Berry Console, etc."
    else
        message="Successfully loaded TAPP and configured paths for tools version "+tools_version.VERSION+". To use it, you will need to `import tools`, e.g. in `autoexec.be`, Berry Console, etc."
    end

    log(message)

    if IS_DEVELOPMENT
        print(message)
    end

end

var mod = module("tools_autoexec")
mod.autoexec=autoexec
return mod