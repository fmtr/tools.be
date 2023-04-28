import string
import tools_constants as constants


class Logger

    static var NONE=0    
    static var ERROR=1
    static var INFO=2
    static var DEBUG=3    
    static var DEBUG_MORE=4

    static var LEVEL_NAMES=['NONE','ERROR','INFO','DEBUG','DEBUG_MORE']

    var prefix, level, log_repl

    static def get_level_name(level)

        return Logger.LEVEL_NAMES[level]

    end

    def init(prefix, level, log_repl)

        self.prefix=string.toupper(prefix?prefix:constants.NAME_SHORT)
        self.level=level
        self.log_repl=log_repl==nil?true:log_repl

    end

    def none(messages, log_repl)
        return
    end

    def error(messages, log_repl)
        return self.log(messages, self.ERROR, log_repl)
    end

    def info(messages, log_repl)
        return self.log(messages, self.INFO, log_repl)
    end

    def debug(messages, log_repl)
        return self.log(messages, self.DEBUG, log_repl)
    end

    def debug_more(messages, log_repl)
        return self.log(messages, self.DEBUG_MORE, log_repl)
    end

    def log(messages, level, log_repl)

        log_repl=log_repl==nil?self.log_repl:log_repl          

        if classname(messages)!='list'
            messages=[messages]
        end
    
        messages=messages.concat(' ')        
        log(string.format('%s: %s',self.prefix,messages), level)

        if log_repl
            var timestamp=tasmota.time_str(tasmota.rtc()['utc'])
            print(string.format('%s: %s: [%s] %s',timestamp,self.prefix,self.get_level_name(level),messages))
        end

    end

end



var mod = module("tools_logging")
mod.Logger=Logger
return mod