--[[

RestartCommand

Restarts a managed process by stopping it and starting it again.

--]]

const Commandline = require("@packages/Commandline")
const ProcessManager = require("@lunepm/Helpers/ProcessManager")

const pm = ProcessManager.new()

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
