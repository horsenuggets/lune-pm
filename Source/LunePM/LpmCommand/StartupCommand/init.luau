--[[

StartupCommand

Configures lune-pm to start on system boot using systemd. Generates a
resurrect script and prints instructions for setting up the service.

--]]

local Commandline = require("@packages/Commandline")
local ProcessManager = require("@lunepm/Helpers/ProcessManager")

local pm = ProcessManager.new()

return Commandline.Command.new({
    Name = "startup",
    Description = "Configure lune-pm to start on system boot.",
    Flags = {
        Commandline.Flag.new({
            Name = "platform",
            Shorthand = "p",
            Description = "Platform (systemd).",
            Type = "string",
            Default = "systemd",
        }),
    },
    Impl = function(_, flags)
        pm:Startup(flags.platform)
    end,
})
