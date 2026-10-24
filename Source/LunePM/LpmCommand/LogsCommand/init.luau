--[[

LogsCommand

Views process logs with optional line count and follow mode for
real-time tailing.

--]]

const Commandline = require("@packages/Commandline")
const ProcessManager = require("@lunepm/Helpers/ProcessManager")

const pm = ProcessManager.new()

return Commandline.Command.new({
    Name = "logs",
    Description = "View process logs.",
    Args = {
        Commandline.Arg.new({
            Name = "name",
            Description = "Name of the process.",
            Required = true,
        }),
    },
    Flags = {
        Commandline.Flag.new({
            Name = "follow",
            Shorthand = "f",
            Description = "Follow log output in real-time.",
            Type = "boolean",
        }),
        Commandline.Flag.new({
            Name = "lines",
            Shorthand = "n",
            Description = "Number of lines to show (default: 50).",
            Type = "number",
            Default = 50,
        }),
    },
    Impl = function(args, flags)
        pm:Logs(args.name, flags.lines, flags.follow)
    end,
})
