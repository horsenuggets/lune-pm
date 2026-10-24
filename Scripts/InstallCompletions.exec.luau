#!/usr/bin/env -S lune run

--[[

InstallCompletions.exec

Installs shell completion scripts for the lpm CLI.

[Usage] ./Scripts/InstallCompletions.exec.luau [bash|zsh|fish|powershell]

--]]

const Commandline = require("@packages/Commandline")
const LpmCommand = require("@lunepm/LpmCommand")
const process = require("@lune/process")

const InstallCompletions = {}

function InstallCompletions.exec()
    Commandline.Toolkit.installCompletions({
        Command = LpmCommand,
        Shell = process.args[1] or "zsh",
    })
end

InstallCompletions.exec()
