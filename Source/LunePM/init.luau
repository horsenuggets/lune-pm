#!/usr/bin/env -S lune run

--[[

LunePM

The entry point for the lpm CLI. Registers the root command and executes
with process arguments.

--]]

local process = require("@lune/process")

local Commandline = require("@packages/Commandline")
local LpmCommand = require("@self/LpmCommand")

local function lunePm()
    Commandline.registerCommand(LpmCommand)
    LpmCommand:Execute(process.args)
end

lunePm()
