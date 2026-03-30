--[[

StatusCommand

Shows detailed status information for a specific process including PID,
script path, restart configuration, and version history.

--]]

local Commandline = require("@packages/Commandline")
local ProcessManager = require("@lunepm/Helpers/ProcessManager")

local pm = ProcessManager.new()

return Commandline.Command.new({
    Name = "status",
    Description = "Show detailed status of a process.",
    Args = {
        Commandline.Arg.new({
            Name = "name",
            Description = "Name of the process.",
            Required = true,
        }),
    },
    Impl = function(args)
        pm:Status(args.name)
    end,
})
