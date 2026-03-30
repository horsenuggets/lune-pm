--[[

StartCommand

Starts a Lune application with auto-restart options. Spawns the process
in the background and registers it with the process store.

--]]

local Commandline = require("@packages/Commandline")
local ProcessManager = require("@lunepm/Helpers/ProcessManager")

local pm = ProcessManager.new()

return Commandline.Command.new({
    Name = "start",
    Description = "Start a Lune application.",
    Args = {
        Commandline.Arg.new({
            Name = "script",
            Description = "Path to the Lune script to run.",
            Required = true,
        }),
    },
    Flags = {
        Commandline.Flag.new({
            Name = "command",
            Shorthand = "c",
            Description = "Custom command to run (instead of lune run).",
            Type = "string",
        }),
        Commandline.Flag.new({
            Name = "cwd",
            Description = "Working directory for the process.",
            Type = "string",
        }),
        Commandline.Flag.new({
            Name = "max-restarts",
            Shorthand = "m",
            Description = "Maximum restart attempts (default: 10).",
            Type = "number",
        }),
        Commandline.Flag.new({
            Name = "name",
            Shorthand = "n",
            Description = "Name for the process.",
            Type = "string",
        }),
        Commandline.Flag.new({
            Name = "no-auto-restart",
            Description = "Disable automatic restart on crash.",
            Type = "boolean",
        }),
        Commandline.Flag.new({
            Name = "restart-delay",
            Shorthand = "d",
            Description = "Seconds to wait before restarting (default: 5).",
            Type = "number",
        }),
    },
    Impl = function(args, flags)
        pm:Start(args.script, {
            name = flags.name,
            cwd = flags.cwd,
            restartDelay = flags["restart-delay"],
            maxRestarts = flags["max-restarts"],
            noAutoRestart = flags["no-auto-restart"],
            command = flags.command,
        })
    end,
})
