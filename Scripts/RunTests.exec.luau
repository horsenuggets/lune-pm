#!/usr/bin/env -S lune run

--[[

RunTests.exec

Executes all test suites and exits with appropriate status code. Optionally pass a test
name as an argument to run only that test suite.

[Usage] ./Scripts/RunTests.exec.luau [TestName]

--]]

const Testable = require("@devpackages/Testable")
const process = require("@lune/process")
const stdio = require("@lune/stdio")

const TESTS = {
    { Name = "ExampleTest", Func = require("../Tests/ExampleTest.spec") },
}

const RunTests = {}

function RunTests.exec()
    const filterName = process.args[1]
    local testsToRun = TESTS

    if filterName then
        testsToRun = {}
        for _, test in TESTS do
            if test.Name == filterName then
                table.insert(testsToRun, test)
            end
        end

        if #testsToRun == 0 then
            stdio.ewrite(`No test suite found with name "{filterName}".\n`)
            stdio.ewrite("Available test suites:\n")
            for _, test in TESTS do
                stdio.ewrite(`  - {test.Name}\n`)
            end
            process.exit(1)
        end
    end

    const _, passed = Testable.run(testsToRun)
    process.exit(if passed then 0 else 1)
end

RunTests.exec()
