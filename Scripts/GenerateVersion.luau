#!/usr/bin/env -S lune run

--[[

GenerateVersion

Reads the VERSION file and generates a __VERSION__.luau module that
returns the version string. This is used to embed the version at build
time since compiled executables cannot read files.

--]]

local Commandline = require("@packages/Commandline")

local VERSION_OUTPUT = "Source/LunePM/LpmCommand/__VERSION__.luau"

local function generateVersion()
    Commandline.Toolkit.generateVersion({
        OutputPath = VERSION_OUTPUT,
    })
end

generateVersion()
