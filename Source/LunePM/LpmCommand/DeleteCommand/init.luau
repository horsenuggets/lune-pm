--[[

DeleteCommand

Deletes a process from the process store. Stops it first if running.

--]]

local Commandline = require("@packages/Commandline")
local ProcessManager = require("@lunepm/Helpers/ProcessManager")

local pm = ProcessManager.new()

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
