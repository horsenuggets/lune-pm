#!/usr/bin/env -S lune run

--[[

GenerateVersion.exec

Reads the VERSION file and generates a __VERSION__.luau module that
returns the version string. This is used to embed the version at build
time since compiled executables cannot read files.

--]]

const Commandline = require("@packages/Commandline")

const VERSION_OUTPUT = "Source/LunePM/LpmCommand/__VERSION__.luau"

const GenerateVersion = {}

function GenerateVersion.exec()
    Commandline.Toolkit.generateVersion({
        OutputPath = VERSION_OUTPUT,
    })
end

GenerateVersion.exec()
