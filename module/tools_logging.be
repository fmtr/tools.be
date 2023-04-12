import string
import tools_constants as constants

def get_logger(name)

    def logger(message)
        log(string.format('%s: %s',string.toupper(name),message))
    end

    return logger

end

var log_tools=get_logger(constants.NAME_SHORT)

def get_logger_default(logger)
    return logger?logger:log_tools
end


def logger_debug(logger, messages, is_debug)

    if !is_debug
        return
    end

    if classname(messages)!='list'
        messages=[messages]
    end

    messages=messages.concat(' ')

    logger(messages)

    var timestamp=tasmota.cmd('Time').find('Time')

    print(string.format('%s: %s',timestamp, messages))

end

var mod = module("tools_logging")
mod.get_logger=get_logger
mod.get_logger_default=get_logger_default
mod.logger_debug=logger_debug
mod.log_tools=log_tools
return mod