--[[

StopCommand

Stops a running process by name, or all processes when "all" is passed.

--]]

local Commandline = require("@packages/Commandline")
local ProcessManager = require("@lunepm/Helpers/ProcessManager")

local pm = ProcessManager.new()

return Commandline.Command.new({
    Name = "stop",
    Description = "Stop a running process (use 'all' to stop all).",
    Args = {
        Commandline.Arg.new({
            Name = "name",
            Description = "Name of the process to stop.",
            Required = true,
        }),
    },
    Impl = function(args)
        pm:Stop(args.name)
    end,
})
