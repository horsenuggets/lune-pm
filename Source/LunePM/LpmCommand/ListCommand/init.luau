--[[

ListCommand

Lists all managed processes with their status, PID, restart count, version,
and auto-restart configuration.

--]]

const Commandline = require("@packages/Commandline")
const ProcessManager = require("@lunepm/Helpers/ProcessManager")

const pm = ProcessManager.new()

return Commandline.Command.new({
    Name = "list",
    Description = "List all managed processes.",
    Impl = function()
        pm:List()
    end,
})
