#!/usr/bin/env -S lune run

--[[

lpm

The entry point for the lpm CLI. Registers the root command and executes
with process arguments.

--]]

local process = require("@lune/process")

local Commandline = require("@packages/Commandline")
local LpmCommand = require("@lunepm/LpmCommand")

local function lpm()
    Commandline.registerCommand(LpmCommand)
    LpmCommand:Execute(process.args)
end

lpm()
