--[[

ListCommand

Lists all managed processes with their status, PID, restart count, version,
and auto-restart configuration.

--]]

local Commandline = require("@packages/Commandline")
local ProcessManager = require("@lunepm/Helpers/ProcessManager")

local pm = ProcessManager.new()

return Commandline.Command.new({
    Name = "list",
    Description = "List all managed processes.",
    Impl = function()
        pm:List()
    end,
})
