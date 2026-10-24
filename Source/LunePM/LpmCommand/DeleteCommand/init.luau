--[[

DeleteCommand

Deletes a process from the process store. Stops it first if running.

--]]

const Commandline = require("@packages/Commandline")
const ProcessManager = require("@lunepm/Helpers/ProcessManager")

const pm = ProcessManager.new()

return Commandline.Command.new({
    Name = "delete",
    Description = "Delete a process from the list.",
    Args = {
        Commandline.Arg.new({
            Name = "name",
            Description = "Name of the process to delete.",
            Required = true,
        }),
    },
    Impl = function(args)
        pm:Delete(args.name)
    end,
})
