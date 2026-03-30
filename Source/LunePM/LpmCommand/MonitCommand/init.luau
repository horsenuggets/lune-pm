--[[

MonitCommand

Real-time process monitoring dashboard that refreshes at a configurable
interval.

--]]

local Commandline = require("@packages/Commandline")
local ProcessManager = require("@lunepm/Helpers/ProcessManager")

local pm = ProcessManager.new()

return Commandline.Command.new({
    Name = "monit",
    Description = "Real-time process monitoring dashboard.",
    Flags = {
        Commandline.Flag.new({
            Name = "interval",
            Shorthand = "i",
            Description = "Refresh interval in seconds (default: 2).",
            Type = "number",
            Default = 2,
        }),
    },
    Impl = function(_, flags)
        pm:Monit(flags.interval)
    end,
})
