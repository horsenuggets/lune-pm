--[[

DeployCommand

Deploys a new version of a process. Saves the script as a new version
and restarts the process if it is running.

--]]

local Commandline = require("@packages/Commandline")
local ProcessManager = require("@lunepm/Helpers/ProcessManager")

local pm = ProcessManager.new()

return Commandline.Command.new({
    Name = "deploy",
    Description = "Deploy a new version of a process.",
    Args = {
        Commandline.Arg.new({
            Name = "name",
            Description = "Name of the process.",
            Required = true,
        }),
        Commandline.Arg.new({
            Name = "script",
            Description = "Path to the new script.",
            Required = true,
        }),
    },
    Impl = function(args)
        pm:Deploy(args.name, args.script)
    end,
})
