import string
import tools_constants as constants


class Logger

    static var NONE=0    
    static var ERROR=1
    static var INFO=2
    static var DEBUG=3    
    static var DEBUG_MORE=4

    static var LEVEL_NAMES=['NONE','ERROR','INFO','DEBUG','DEBUG_MORE']

    var prefix, level, do_print, level_names

    static def get_level_name(level)

        return Logger.LEVEL_NAMES[level]

    end

    def init(prefix, level, do_print)

        self.prefix=string.toupper(prefix?prefix:constants.NAME_SHORT)
        self.level=level
        self.do_print=do_print==nil?true:do_print

    end

    def none(messages, do_print)
        return
    end

    def error(messages, do_print)
        return self.log(messages, Logger.ERROR, do_print)
    end

    def info(messages, do_print)
        return self.log(messages, Logger.INFO, do_print)
    end

    def debug(messages, do_print)
        return self.log(messages, Logger.DEBUG, do_print)
    end

    def debug_more(messages, do_print)
        return self.log(messages, Logger.DEBUG_MORE, do_print)
    end

    def log(messages, level, do_print)

        do_print=do_print==nil?self.do_print:do_print          

        if classname(messages)!='list'
            messages=[messages]
        end
    
        messages=messages.concat(' ')        
        log(string.format('%s: %s',self.prefix,messages), level)

        if do_print
            var timestamp=tasmota.cmd('Time').find('Time')
            print(string.format('%s: %s: [%s] %s',timestamp,self.prefix,self.get_level_name(level),messages))
        end

    end

end



var mod = module("tools_logging")
mod.Logger=Logger
return mod