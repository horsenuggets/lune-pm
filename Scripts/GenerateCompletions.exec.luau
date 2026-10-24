#!/usr/bin/env -S lune run

--[[

GenerateCompletions.exec

Generates shell completion scripts for the lpm CLI.

[Usage] ./Scripts/GenerateCompletions.exec.luau [bash|zsh|fish|powershell]

--]]

const Commandline = require("@packages/Commandline")
const LpmCommand = require("@lunepm/LpmCommand")
const process = require("@lune/process")

const GenerateCompletions = {}

function GenerateCompletions.exec()
    print(Commandline.Completions.generate(LpmCommand, process.args[1] or "zsh"))
end

GenerateCompletions.exec()
