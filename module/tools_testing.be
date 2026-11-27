import path
import string
import introspect
import global
import math
import tools

class Spy
    var calls
    var responses

    def init()
        self.calls = []
        self.responses = {}
    end

    def stub(method_name, result)
        self.responses[method_name] = result
        return self
    end

    def member(name)
        var spy = self
        return def(*args)
            var recorded_args = []
            var index = 1
            while index < size(args)
                recorded_args.push(args[index])
                index += 1
            end
            spy.calls.push({"name": name, "args": recorded_args})
            return spy.responses.find(name)
        end
    end

    def callback(name)
        var spy = self
        return def(*args)
            spy.calls.push({"name": name, "args": args})
            return spy.responses.find(name)
        end
    end

    def _same_args(actual, expected)
        if size(actual) != size(expected)
            return false
        end
        var index = 0
        while index < size(actual)
            if actual[index] != expected[index]
                return false
            end
            index += 1
        end
        return true
    end

    def assert_called(method_name, expected_args, expected_count)
        var count = 0
        for call: self.calls
            if call["name"] == method_name
                assert(self._same_args(call["args"], expected_args), f"Unexpected arguments for {method_name}")
                count += 1
            end
        end
        assert(count == expected_count, f"Expected {expected_count} calls to {method_name}, got {count}")
        return true
    end

    def reset()
        self.calls = []
        return self
    end

    def tostring()
        return "Spy"
    end
end

def assert_true(actual, message)
    assert(actual == true, f"{message}: expected true, got {actual}")
    return true
end

def assert_false(actual, message)
    assert(actual == false, f"{message}: expected false, got {actual}")
    return true
end

def assert_equal(actual, expected, message)
    assert(actual == expected, f"{message}: expected {expected}, got {actual}")
    return true
end

def assert_near(actual, expected, tolerance, message)
    assert(math.abs(actual - expected) <= tolerance, f"{message}: expected {expected} ± {tolerance}, got {actual}")
    return true
end

def assert_not_nil(actual, message)
    assert(actual != nil, f"{message}: expected a value")
    return true
end

def assert_raises(expected_error, callback, *expected_messages)
    var did_raise = false
    try
        callback()
    except .. as error, message
        did_raise = true
        assert(str(error) == expected_error, f"Unexpected exception type: expected {expected_error}, got {error}")
        if size(expected_messages) > 0
            assert(str(message) == expected_messages[0], f"{expected_messages[0]}: got {message}")
        end
    end
    assert(did_raise, "Expected callback to raise")
    return true
end

def with_stub(target, member_name, replacement, callback)
    import introspect

    var original = introspect.get(target, member_name)
    introspect.set(target, member_name, replacement)
    var result
    try
        result = callback()
    except .. as error, message
        introspect.set(target, member_name, original)
        raise error, message
    end
    introspect.set(target, member_name, original)
    return result
end

def _make_parameterized_test(callback, values)
    return def()
        call(callback, values)
    end
end

def parameterize(base_name, cases, callback)
    var generated_names = []
    for test_case: cases
        var test_name = base_name .. "_" .. test_case["name"]
        global.setmember(test_name, _make_parameterized_test(callback, test_case["values"]))
        generated_names.push(test_name)
    end
    return generated_names
end

# run(prefix, delay_ms, focus_modules, base_dir) discovers `${prefix}_test_*.be`;
# test functions begin with the filename stem. Focus entries are exact stems
# (without `.be`); nil selects every matching module. Empty base_dir selects `/`.
class Runner
    var prefix
    var delay_ms
    var focus_modules
    var base_dir
    var registry
    var suites
    var suite_order
    var suite_modules
    var test_cases
    var next_index
    var passed
    var failed
    var failures
    var current_timer
    var started_at
    var duration_ms
    var heap_before_load_bytes
    var heap_start_bytes
    var heap_min_bytes
    var heap_before_cleanup_bytes
    var heap_end_bytes
    var heap_min_case
    var finished
    var progress
    var result

    def init(prefix, delay_ms, focus_modules, base_dir)
        self.prefix = prefix
        self.delay_ms = delay_ms
        self.focus_modules = focus_modules
        self.base_dir = (base_dir == nil || base_dir == "") ? "/" : base_dir
        self.registry = tools.callbacks.Registry()
        self.suites = {}
        self.suite_order = []
        self.suite_modules = {}
        self.test_cases = []
        self.next_index = 0
        self.passed = 0
        self.failed = 0
        self.failures = []
        self.current_timer = nil
        self.started_at = nil
        self.duration_ms = nil
        self.heap_before_load_bytes = tasmota.get_free_heap()
        self.heap_start_bytes = self.heap_before_load_bytes
        self.heap_min_bytes = self.heap_start_bytes
        self.heap_before_cleanup_bytes = nil
        self.heap_end_bytes = nil
        self.heap_min_case = "runner initialization"
        self.finished = false
        self.progress = {
            "completed": 0,
            "total": 0,
            "last_test": nil,
            "last_test_passed": nil,
            "updated_at_ms": tasmota.millis(),
            "finished": false,
        }
        self.result = nil
    end

    def _is_selected(suite_name)
        if self.focus_modules == nil
            return true
        end
        return self.focus_modules.find(suite_name) != nil
    end

    def _test_file_path(filename)
        if self.base_dir == "/"
            return filename
        end
        if string.endswith(self.base_dir, "/") || string.endswith(self.base_dir, "#")
            return self.base_dir .. filename
        end
        return self.base_dir .. "/" .. filename
    end

    def _load_tests()
        self.suites = {}
        self.suite_order = []
        self.suite_modules = {}
        self.test_cases = []
        var filename_prefix = self.prefix .. "_test_"
        for filename: path.listdir(self.base_dir)
            if string.startswith(filename, filename_prefix) && string.endswith(filename, ".be")
                var suite_name = string.split(filename, ".")[0]
                if self._is_selected(suite_name)
                    var function_prefix = suite_name .. "_"
                    for name: introspect.members(nil)
                        if string.startswith(name, function_prefix) && type(global.member(name)) == "function"
                            global.setmember(name, nil)
                        end
                    end
                    var test_path = self._test_file_path(filename)
                    assert(load(test_path), f"Could not load {test_path}")
                    var suite = module(suite_name)
                    self.suite_modules[suite_name] = suite
                    self.suites[suite_name] = {"total": 0, "passed": 0, "failed": 0}
                    self.suite_order.push(suite_name)
                    for name: introspect.members(nil)
                        if string.startswith(name, function_prefix)
                            var candidate = global.member(name)
                            if type(candidate) == "function"
                                introspect.set(suite, name, candidate)
                                self.test_cases.push({"suite": suite_name, "name": name, "function": candidate})
                                self.suites[suite_name]["total"] += 1
                            end
                        end
                    end
                end
            end
        end
        assert(size(self.test_cases) > 0, "No test functions discovered for the selected modules")
    end

    def _start()
        self.heap_before_load_bytes = tasmota.get_free_heap()
        self._load_tests()
        self.progress["total"] = size(self.test_cases)
        self.progress["updated_at_ms"] = tasmota.millis()
        self.heap_start_bytes = tasmota.get_free_heap()
        self.heap_min_bytes = self.heap_start_bytes
        self.heap_before_cleanup_bytes = nil
        self.heap_end_bytes = nil
        self.heap_min_case = "test start"
        self.next_index = 0
        self.passed = 0
        self.failed = 0
        self.failures = []
        self.finished = false
        self.started_at = tasmota.millis()
        if self.focus_modules == nil
            print(f"Starting {size(self.test_cases)} tests in {size(self.suite_order)} modules")
        else
            var focus_display = self.focus_modules.concat(", ")
            print(f"Starting {size(self.test_cases)} focused tests in {size(self.suite_order)} modules: {focus_display}")
        end
        self._schedule_next()
    end

    def _schedule_next()
        self.current_timer = tools.callbacks.Timer(self.delay_ms, /value data->self._run_next(), nil)
        self.registry.add(self.current_timer, nil)
    end

    def _sample_heap(case_name)
        var free_bytes = tasmota.get_free_heap()
        if free_bytes < self.heap_min_bytes
            self.heap_min_bytes = free_bytes
            self.heap_min_case = case_name
        end
        return free_bytes
    end

    def _run_case(test_case)
        var display_name = test_case["suite"] .. "." .. test_case["name"]
        test_case["heap_free_before_bytes"] = self._sample_heap(display_name .. " before")
        var test_passed = false
        try
            test_case["function"]()
            self.passed += 1
            test_passed = true
        except .. as error, message
            self.failed += 1
            self.failures.push({"name": display_name, "error": str(error), "message": str(message)})
        end
        test_case["passed"] = test_passed
        test_case["heap_free_after_bytes"] = self._sample_heap(display_name .. " after")
        self.progress["completed"] += 1
        self.progress["last_test"] = display_name
        self.progress["last_test_passed"] = test_passed
        self.progress["updated_at_ms"] = tasmota.millis()
        return test_passed
    end

    def _run_next()
        self.registry.remove(self.current_timer.id)
        self.current_timer = nil
        var test_case = self.test_cases[self.next_index]
        self.next_index += 1
        var suite_result = self.suites[test_case["suite"]]
        var test_passed = self._run_case(test_case)
        test_case["function"] = nil
        if test_passed
            suite_result["passed"] += 1
            var display_name = test_case["suite"] .. "." .. test_case["name"]
            print(f"PASS {display_name}")
        else
            suite_result["failed"] += 1
            var failure = self.failures[size(self.failures) - 1]
            var failure_name = failure["name"]
            var failure_error = failure["error"]
            var failure_message = failure["message"]
            print(f"FAIL {failure_name} {failure_error}: {failure_message}")
        end
        if self.next_index == size(self.test_cases)
            self._finish()
        else
            self._schedule_next()
        end
    end

    def _clear_loaded_tests()
        for suite_name: self.suite_order
            var function_prefix = suite_name .. "_"
            for name: introspect.members(nil)
                if string.startswith(name, function_prefix) && type(global.member(name)) == "function"
                    global.setmember(name, nil)
                end
            end
            var suite = self.suite_modules[suite_name]
            for name: introspect.members(suite)
                if string.startswith(name, function_prefix)
                    introspect.set(suite, name, nil)
                end
            end
        end
        self.suite_modules = {}
    end

    def _finish()
        self.duration_ms = tasmota.millis() - self.started_at
        self.heap_before_cleanup_bytes = self._sample_heap("before cleanup")
        for suite_name: self.suite_order
            var stats = self.suites[suite_name]
            var suite_passed = stats["passed"]
            var suite_total = stats["total"]
            var suite_failed = stats["failed"]
            print(f"{suite_name}: {suite_passed}/{suite_total} passed, {suite_failed} failed")
        end
        print(f"Tests complete: {self.passed} passed, {self.failed} failed in {self.duration_ms} ms")

        self._clear_loaded_tests()
        self.current_timer = tools.callbacks.Timer(1, /value data->self._finish_report(), nil)
        self.registry.add(self.current_timer, nil)
    end

    def _finish_report()
        self.registry.remove(self.current_timer.id)
        self.current_timer = nil

        var load_delta_bytes = self.heap_start_bytes - self.heap_before_load_bytes
        self.result = {
            "passed": self.passed,
            "failed": self.failed,
            "total": size(self.test_cases),
            "duration_ms": self.duration_ms,
            "modules": self.suite_order,
            "suites": self.suites,
            "cases": self.test_cases,
            "failures": self.failures,
            "memory": {
                "source": "tasmota.get_free_heap",
                "unit": "bytes",
                "free_before_load_bytes": self.heap_before_load_bytes,
                "free_at_start_bytes": self.heap_start_bytes,
                "free_low_water_bytes": self.heap_min_bytes,
                "low_water_case": self.heap_min_case,
                "free_before_cleanup_bytes": self.heap_before_cleanup_bytes,
                "free_at_end_bytes": nil,
                "load_delta_bytes": load_delta_bytes,
                "low_water_delta_bytes": self.heap_min_bytes - self.heap_start_bytes,
                "end_delta_bytes": nil,
                "low_water_percent_of_start": nil,
                "end_percent_of_start": nil,
            },
        }

        tasmota.gc()
        self.heap_end_bytes = tasmota.get_free_heap()
        var heap_min_percent_of_start = int(100.0 * real(self.heap_min_bytes) / real(self.heap_start_bytes))
        var heap_end_percent_of_start = int(100.0 * real(self.heap_end_bytes) / real(self.heap_start_bytes))
        self.result["memory"]["free_at_end_bytes"] = self.heap_end_bytes
        self.result["memory"]["end_delta_bytes"] = self.heap_end_bytes - self.heap_start_bytes
        self.result["memory"]["low_water_percent_of_start"] = heap_min_percent_of_start
        self.result["memory"]["end_percent_of_start"] = heap_end_percent_of_start
        print(f"ESP free heap: {self.heap_before_load_bytes} B before load; {self.heap_start_bytes} B at test start (load delta {load_delta_bytes} B); minimum {self.heap_min_bytes} B ({heap_min_percent_of_start}% of start) after {self.heap_min_case}; {self.heap_before_cleanup_bytes} B before cleanup; {self.heap_end_bytes} B after cleanup and GC ({heap_end_percent_of_start}% of start)")
        self.progress["updated_at_ms"] = tasmota.millis()
        self.progress["finished"] = true
        self.finished = true
    end
end

var mod = module("tools_testing")
mod.Runner = Runner
mod.Spy = Spy
mod.assert_true = assert_true
mod.assert_false = assert_false
mod.assert_equal = assert_equal
mod.assert_near = assert_near
mod.assert_not_nil = assert_not_nil
mod.assert_raises = assert_raises
mod.parametrize = parameterize
mod.with_stub = with_stub
mod.run = def(prefix, delay_ms, focus_modules, base_dir)
    var runner = Runner(prefix, delay_ms, focus_modules, base_dir)
    runner._start()
    return runner
end

return mod
