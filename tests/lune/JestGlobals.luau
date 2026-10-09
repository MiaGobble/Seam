local process = require("@lune/process")

local suites = {}
local currentSuite = nil
local failures = 0
local passes = 0

local function deepEqual(a: any, b: any): boolean
    if a == b then
        return true
    end

    if typeof(a) ~= typeof(b) then
        return false
    end

    if typeof(a) ~= "table" then
        return false
    end

    for key, value in a do
        if not deepEqual(value, b[key]) then
            return false
        end
    end

    for key in b do
        if a[key] == nil then
            return false
        end
    end

    return true
end

local function expect(received: any)
    local assertion = {}

    function assertion.toBe(expected: any)
        if received ~= expected then
            error(`Expected {tostring(expected)}, got {tostring(received)}`, 2)
        end
    end

    function assertion.toEqual(expected: any)
        if not deepEqual(received, expected) then
            error(`Expected values to be deeply equal`, 2)
        end
    end

    function assertion.toBeNil()
        if received ~= nil then
            error(`Expected nil, got {tostring(received)}`, 2)
        end
    end

    function assertion.toBeTruthy()
        if not received then
            error(`Expected value to be truthy, got {tostring(received)}`, 2)
        end
    end

    function assertion.toBeFalsy()
        if received then
            error(`Expected value to be falsy, got {tostring(received)}`, 2)
        end
    end

    return assertion
end

local function describe(name: string, callback: () -> ())
    local previous = currentSuite
    currentSuite = {
        name = name,
        tests = {},
    }
    table.insert(suites, currentSuite)
    callback()
    currentSuite = previous
end

local function it(name: string, callback: () -> ())
    assert(currentSuite, "it() must be called inside describe()")
    table.insert(currentSuite.tests, {
        name = name,
        callback = callback,
    })
end

local function run(): number
    for _, suite in suites do
        print(`\n{suite.name}`)

        for _, test in suite.tests do
            local ok, err = pcall(test.callback)
            if ok then
                passes += 1
                print(`  ✓ {test.name}`)
            else
                failures += 1
                print(`  ✗ {test.name}`)
                print(`    {err}`)
            end
        end
    end

    print(`\nTests: {passes} passed, {failures} failed, {passes + failures} total`)

    if failures > 0 then
        process.exit(1)
    end

    return 0
end

return {
    describe = describe,
    it = it,
    expect = expect,
    run = run,
}
