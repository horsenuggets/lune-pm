#!/usr/bin/env -S lune run

--[[

BuildExecutable

Compiles the lpm CLI to a standalone executable. Embeds the VERSION at
build time since compiled executables cannot read files at runtime.

--]]

local Commandline = require("@packages/Commandline")
local process = require("@lune/process")

local VERSION_OUTPUT = "Source/LunePM/LpmCommand/__VERSION__.luau"

local function buildExecutable()
    Commandline.Toolkit.generateVersion({
        OutputPath = VERSION_OUTPUT,
    })

    Commandline.Toolkit.build({
        Name = "lpm",
        EntryPoint = "Source/LunePM",
        Target = process.args[1],
    })
end

buildExecutable()
