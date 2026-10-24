#!/usr/bin/env -S lune run

--[[

lpm

The entry point for the lpm CLI. Registers the root command and executes
with process arguments.

--]]

const process = require("@lune/process")

const Commandline = require("@packages/Commandline")
const LpmCommand = require("@lunepm/LpmCommand")

const function lpm()
    Commandline.registerCommand(LpmCommand)
    LpmCommand:Execute(process.args)
end

lpm()
