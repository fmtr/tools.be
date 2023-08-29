import tools_logger, tools_iterator

class Rule

    static var DATA_ARGS=['value_raw','trigger','message']
    static var IS_JSON_DEFAULT=false
    var trigger, function_raw, id, enabled, is_json

    def init(trigger,function,id,is_json)

        self.trigger=trigger
        self.function_raw=function
        self.is_json=is_json!=nil?is_json:self.IS_JSON_DEFAULT
        self.id=self.get_id(id)
        self.enabled=false
        self.enable()

    end  

    def get_data(values)

        var data={'registration':self}

        if !size(self.DATA_ARGS)
            return data
        end

        var value
        for enumerated:tools_iterator.enumerate(self.DATA_ARGS)
            data[enumerated.value]=tools_iterator.get_list(values,enumerated.i)
        end

        return data

    end

    def function(*args)

        var data=self.get_data(args)
        var value=data.find('value_raw')
        
        if self.is_json
            import json
            value=json.load(value)
        end

        var output=self.function_raw(value,data)

        return output

    end

    def get_id(id)

        if id==nil
            import uuid
            id=uuid.uuid4()
        end

        return id

    end

    def tostring()
        return string.format('%s(%s,%s,%s)', classname(self), self.trigger,self.function,self.id)
    end

    def enable()

        tools_logger.logger.debug(string.format('Enabling callback registration %s', self))
        self.enabled=true
        return self._enable()

    end

    def disable()

        tools_logger.logger.debug(string.format('Disabling callback registration %s', self))
        self.enabled=false
        return self._disable()

    end

    def _enable()

        return tasmota.add_rule(self.trigger, /value_raw trigger message->self.function(value_raw,trigger,message), self.id)

    end

    def _disable()

        return tasmota.remove_rule(self.trigger, self.id)

    end

end

class MqttSubscription: Rule

    static var IS_JSON_DEFAULT=true
    static var DATA_ARGS=['topic','code','value_raw','value_bytes']
    
    def get_id(id)

        return self.trigger

    end  

    def _enable()

        import mqtt
        return mqtt.subscribe(self.trigger, /topic code value_raw value_bytes->self.function(topic,code,value_raw,value_bytes))

    end

    def _disable()

        import mqtt
        tools_logger.logger.info(string.format('Removing all callbacks registered to topic "%s".', self.trigger))
        return mqtt.unsubscribe(self.trigger)

    end

end


class Cron: Rule

    static var DATA_ARGS=['current','next']

    def _enable()

        return tasmota.add_cron(self.trigger, /current next->self.function(current,next), self.id)

    end

    def _disable()

        return tasmota.remove_cron(self.id)

    end

    def get_next()

        return tasmota.next_cron(self.id)

    end

end

class Timer: Rule

    static var DATA_ARGS=[]

    def _enable()

        return tasmota.set_timer(self.trigger, /->self.function(), self.id)

    end

    def _disable()

        return tasmota.remove_timer(self.id)

    end

end

class Registry

    var data

    def init()

        self.data={}

    end

    def add(rule, function)

        if !isinstance(rule,Rule)
            rule=Rule(rule,function)
        end

        if self.data.contains(rule.id)
            self.data[rule.id].disable()
        end        

        self.data[rule.id]=rule        

    end

    def disable(id)
        self.data[id].disable()
    end

    def remove(id)
        self.disable(id)
        self.data.remove(id)
    end

    def disable_all()

        for id: self.data.keys()

            self.disable(id)

        end

    end

    def remove_all()

        for id: self.data.keys()

            self.remove(id)

        end

    end

    def get(id)

        return self.data[id]

    end

end


var mod = module("tools_callbacks")
mod.Rule=Rule
mod.MqttSubscription=MqttSubscription
mod.Cron=Cron
mod.Timer=Timer
mod.Registry=Registry

return mod