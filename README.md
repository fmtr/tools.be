# Berry Tools

Berry Tools is a shared utility package for the Berry runtime in Tasmota. It gives Tasmota scripts common building blocks—such as callbacks, configuration, networking, MQTT, logging, conversion, and web/update helpers—through one lazily loaded `tools` module.

```berry
import tools
print(tools.version)
```

Use the package from Berry scripts running on a Tasmota device. The repository's `module/` directory contains the package source and manifest.

## Documentation

- [Quick start](docs/quick-start.md)
- [Testing](docs/testing.md)
