import tools_logger

class Rule

    var trigger, function, id, enabled

    def init(trigger,function,id)

        self.trigger=trigger
        self.function=function
        self.id=self.get_id(id)
        self.enabled=false
        self.enable()

    end  

    def get_id(id)

        if id==nil
            import uuid
            id=uuid.uuid4()
        end

        return id

    end

    def tostring()
        return string.format('%s(%s,%s,%s)', classof(self), self.trigger,self.function,self.id)
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

        return tasmota.add_rule(self.trigger, self.function, self.id)

    end

    def _disable()

        return tasmota.remove_rule(self.trigger, self.id)

    end

end

class MqttSubscription: Rule
    
    def get_id(id)

        return self.trigger

    end  

    def _enable()

        import mqtt
        return mqtt.subscribe(self.trigger, self.function)

    end

    def _disable()

        import mqtt
        tools_logger.logger.info(string.format('Removing all callbacks registered to topic "%s".', self.trigger))
        return mqtt.unsubscribe(self.trigger)

    end

end


class Cron: Rule

    def _enable()

        return tasmota.add_cron(self.trigger, self.function, self.id)

    end

    def _disable()

        return tasmota.remove_cron(self.id)

    end

    def get_next()

        return tasmota.next_cron(self.id)

    end

end

class Timer: Rule

    def _enable()

        return tasmota.set_timer(self.trigger, self.function, self.id)

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