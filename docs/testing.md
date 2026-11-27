# Running Berry tests

The test runner and package self-tests are in `module/`. Tests are Berry files named `<prefix>_test_<module>.be`; test functions in each file begin with that filename stem and an underscore.

## Start a run

From a Tasmota Berry console, import `tools` and start the asynchronous full suite:

```berry
import tools
var runner = tools.testing.run("tools", 5, nil)
```

The arguments are the filename prefix, delay between tests in milliseconds, optional focus list, and optional base directory. `nil` or an empty string for the base directory means `/`. To run selected test modules, pass their exact filename stems (without `.be`):

```berry
var runner = tools.testing.run("tools", 5, ["tools_test_converter", "tools_test_testing"])
```

To scan tests in the root of a TAPP archive, pass its archive prefix as the fourth argument. Do not add a slash after `#`:

```berry
var runner = tools.testing.run("tools", 5, nil, "/foo.tapp#")
```

TAPP archive discovery uses `path.listdir()` support for TAPP files, available in Tasmota 15.2.0.3 and later.

## Poll progress

`run()` returns before tests finish. Read `runner.progress` to check status without fetching the full report after every test:

```berry
print(runner.progress)
```

The map has `completed`, `total`, `last_test`, `last_test_passed`, `updated_at_ms`, and `finished`. For example:

```berry
{
    "completed": 7,
    "total": 64,
    "last_test": "example_test_parser.example_test_parser_accepts_valid_record",
    "last_test_passed": true,
    "updated_at_ms": 183420,
    "finished": false
}
```

`updated_at_ms` is based on Tasmota's uptime `millis()`, not wall-clock time. It changes after each test completes and when the final report is ready. Once `runner.progress["finished"]` is true (equivalently, `runner.finished`), read `runner.result` for the full report.

## Parameterized cases

Use `tools.testing.parametrize(base_name, cases, callback)` to register each row as a separate test. Each row has a unique `name` and a `values` list. Berry's `call(callback, values)` passes each list element as a positional argument, so give the callback matching parameters:

```berry
import tools
var testing = tools.testing

testing.parametrize("example_test_parser_even_value", [
    {"name": "small", "values": [4, true]},
    {"name": "large", "values": [22, true]},
], def(value, expected)
    assert(testing.assert_equal(value % 2 == 0, expected, "even result"))
end)
```

## Spies and temporary stubs

`Spy.callback(name)` returns a plain function that records its positional arguments. `testing.with_stub(target, member_name, replacement, callback)` replaces an existing member for the duration of a callback and restores it on both success and exception:

```berry
var spy = testing.Spy()
spy.stub("send", false)
var result = testing.with_stub(service, "send", spy.callback("send"), def()
    return service.send("sample-payload")
end)
assert(spy.assert_called("send", ["sample-payload"], 1))
```

Use these helpers instead of manually changing module or global members in a test. Other helpers include `assert_true`, `assert_false`, `assert_equal`, `assert_near`, `assert_not_nil`, and `assert_raises`.

## Results and memory

When complete, `runner.result` contains overall `passed`, `failed`, and `total` counts; elapsed time; per-module `suites`; per-test `cases`; failure details; and memory statistics. Each case records its pass state and free heap before and after its callback. A failure entry contains the test `name`, Berry `error`, and `message`, for example:

```berry
{
    "name": "example_test_parser.example_test_parser_rejects_bad_record",
    "error": "assert_failed",
    "message": "field count: expected 3, got 2"
}
```

The memory map reports free ESP/Tasmota heap in bytes before loading, at test start, at the sampled low-water mark, before cleanup, and after cleanup/GC. Its low-water and end percentages are relative to free heap at test start—not percentages of total device RAM. Tasmota does not expose a reliable total-heap denominator through this Berry API.
