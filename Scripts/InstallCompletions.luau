#!/usr/bin/env -S lune run

--[[

InstallCompletions

Installs shell completion scripts for the lpm CLI.

--]]

local Commandline = require("@packages/Commandline")
local LpmCommand = require("@lunepm/LpmCommand")
local process = require("@lune/process")

Commandline.Toolkit.installCompletions({
    Command = LpmCommand,
    Shell = process.args[1] or "zsh",
})
