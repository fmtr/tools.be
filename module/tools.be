import tools_constants as constants
import tools_lazy_import

print("tools.be",constants.VERSION, "compiling...")

class LazyImportInterfaceTools: tools_lazy_import.LazyImportInterface

    static var NAME=constants.NAME
    static var MEMBERS={

        'VERSION':def (self) return constants.VERSION end,
        'version':def (self) return constants.VERSION end,

        'constants':def (self) import tools_constants return tools_constants end,
        'lazy_import':def (self) import tools_lazy_import return tools_lazy_import end,

        'network':def (self) import tools_network return tools_network end,
        'web':def (self) import tools_web return tools_web end,
        'update':def (self) import tools_update return tools_update end,
        'iterator':def (self) import tools_iterator return tools_iterator end,
        'mqtt':def (self) import tools_mqtt return tools_mqtt end,
        'platform':def (self) import tools_platform return tools_platform end,
        'logging':def (self) import tools_logging return tools_logging end,
        'logger':def (self) import tools_logger return tools_logger end,
        'converter':def (self) import tools_converter return tools_converter end,
        'tuya':def (self) import tools_tuya return tools_tuya end,
        'logging':def (self) import tools_logging return tools_logging end,
        'random':def (self) import tools_random return tools_random end,
        'module':def (self) import tools_module return tools_module end,
        'callbacks':def (self) import tools_callbacks return tools_callbacks end,
        'compile':def (self) import tools_compile return tools_compile end,
    }


end

var interface=LazyImportInterfaceTools().create_module()

print("tools.be",constants.VERSION, "compiled OK.")

return interface