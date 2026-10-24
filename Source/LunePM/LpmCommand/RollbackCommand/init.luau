--[[

RollbackCommand

Rolls back a process to a previous version. Defaults to the previous
version if no version number is specified.

--]]

const Commandline = require("@packages/Commandline")
const ProcessManager = require("@lunepm/Helpers/ProcessManager")

const pm = ProcessManager.new()

return Commandline.Command.new({
    Name = "rollback",
    Description = "Rollback to a previous version.",
    Args = {
        Commandline.Arg.new({
            Name = "name",
            Description = "Name of the process.",
            Required = true,
        }),
    },
    Flags = {
        Commandline.Flag.new({
            Name = "version",
            Shorthand = "v",
            Description = "Version number to rollback to (default: previous).",
            Type = "number",
        }),
    },
    Impl = function(args, flags)
        pm:Rollback(args.name, flags.version)
    end,
})
