#!/usr/bin/env -S lune run

--[[

LunePM

The entry point for the lpm CLI. Registers the root command and executes
with process arguments.

--]]

const process = require("@lune/process")

const Commandline = require("@packages/Commandline")
const LpmCommand = require("@self/LpmCommand")

const function lunePm()
    Commandline.registerCommand(LpmCommand)
    LpmCommand:Execute(process.args)
end

lunePm()

return LpmCommand
