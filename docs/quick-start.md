# Quick start

Berry Tools provides shared utilities for Tasmota Berry scripts. Once the package is installed on a Tasmota device, import it and check the package version:

```berry
import tools
print(tools.version)
```

Modules are loaded lazily when accessed. For example, the callback registry and timer helpers are available through `tools.callbacks`:

```berry
var callbacks = tools.callbacks
```

See [Testing](testing.md) for running the package's Berry test suite.
