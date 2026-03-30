--[[

RestartCommand

Restarts a managed process by stopping it and starting it again.

--]]

local Commandline = require("@packages/Commandline")
local ProcessManager = require("@lunepm/Helpers/ProcessManager")

local pm = ProcessManager.new()

return Commandline.Command.new({
    Name = "restart",
    Description = "Restart a process.",
    Args = {
        Commandline.Arg.new({
            Name = "name",
            Description = "Name of the process to restart.",
            Required = true,
        }),
    },
    Impl = function(args)
        pm:Restart(args.name)
    end,
})
