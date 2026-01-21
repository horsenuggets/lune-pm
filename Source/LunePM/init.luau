--[[

LunePM

Main entry point for the lune-pm process manager. Registers CLI commands for managing Lune
applications in production.

--]]

local Commandline = require("@packages/Commandline")
local ProcessManager = require("@self/ProcessManager")
local ProcessStore = require("@self/ProcessStore")

local pm = ProcessManager.new()

-- Start command
local startCommand = Commandline.Command.new({
    Name = "start",
    Description = "Start a Lune application",
    Args = {
        Commandline.Arg.new({
            Name = "script",
            Description = "Path to the Lune script to run",
            Required = true,
        }),
    },
    Flags = {
        Commandline.Flag.new({
            Name = "name",
            Shorthand = "n",
            Description = "Name for the process",
            Type = "string",
        }),
        Commandline.Flag.new({
            Name = "cwd",
            Description = "Working directory for the process",
            Type = "string",
        }),
        Commandline.Flag.new({
            Name = "restart-delay",
            Shorthand = "d",
            Description = "Seconds to wait before restarting (default: 5)",
            Type = "number",
        }),
        Commandline.Flag.new({
            Name = "max-restarts",
            Shorthand = "m",
            Description = "Maximum restart attempts (default: 10)",
            Type = "number",
        }),
        Commandline.Flag.new({
            Name = "no-auto-restart",
            Description = "Disable automatic restart on crash",
            Type = "boolean",
        }),
        Commandline.Flag.new({
            Name = "command",
            Shorthand = "c",
            Description = "Custom command to run (instead of lune run)",
            Type = "string",
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

-- Stop command
local stopCommand = Commandline.Command.new({
    Name = "stop",
    Description = "Stop a running process (use 'all' to stop all)",
    Args = {
        Commandline.Arg.new({
            Name = "name",
            Description = "Name of the process to stop",
            Required = true,
        }),
    },
    Impl = function(args)
        pm:Stop(args.name)
    end,
})

-- Restart command
local restartCommand = Commandline.Command.new({
    Name = "restart",
    Description = "Restart a process",
    Args = {
        Commandline.Arg.new({
            Name = "name",
            Description = "Name of the process to restart",
            Required = true,
        }),
    },
    Impl = function(args)
        pm:Restart(args.name)
    end,
})

-- List command
local listCommand = Commandline.Command.new({
    Name = "list",
    Description = "List all managed processes",
    Impl = function()
        pm:List()
    end,
})

-- Logs command
local logsCommand = Commandline.Command.new({
    Name = "logs",
    Description = "View process logs",
    Args = {
        Commandline.Arg.new({
            Name = "name",
            Description = "Name of the process",
            Required = true,
        }),
    },
    Flags = {
        Commandline.Flag.new({
            Name = "lines",
            Shorthand = "n",
            Description = "Number of lines to show (default: 50)",
            Type = "number",
            Default = 50,
        }),
        Commandline.Flag.new({
            Name = "follow",
            Shorthand = "f",
            Description = "Follow log output in real-time",
            Type = "boolean",
        }),
    },
    Impl = function(args, flags)
        pm:Logs(args.name, flags.lines, flags.follow)
    end,
})

-- Delete command
local deleteCommand = Commandline.Command.new({
    Name = "delete",
    Description = "Delete a process from the list",
    Args = {
        Commandline.Arg.new({
            Name = "name",
            Description = "Name of the process to delete",
            Required = true,
        }),
    },
    Impl = function(args)
        pm:Delete(args.name)
    end,
})

-- Deploy command
local deployCommand = Commandline.Command.new({
    Name = "deploy",
    Description = "Deploy a new version of a process",
    Args = {
        Commandline.Arg.new({
            Name = "name",
            Description = "Name of the process",
            Required = true,
        }),
        Commandline.Arg.new({
            Name = "script",
            Description = "Path to the new script",
            Required = true,
        }),
    },
    Impl = function(args)
        pm:Deploy(args.name, args.script)
    end,
})

-- Rollback command
local rollbackCommand = Commandline.Command.new({
    Name = "rollback",
    Description = "Rollback to a previous version",
    Args = {
        Commandline.Arg.new({
            Name = "name",
            Description = "Name of the process",
            Required = true,
        }),
    },
    Flags = {
        Commandline.Flag.new({
            Name = "version",
            Shorthand = "v",
            Description = "Version number to rollback to (default: previous)",
            Type = "number",
        }),
    },
    Impl = function(args, flags)
        pm:Rollback(args.name, flags.version)
    end,
})

-- Status command
local statusCommand = Commandline.Command.new({
    Name = "status",
    Description = "Show detailed status of a process",
    Args = {
        Commandline.Arg.new({
            Name = "name",
            Description = "Name of the process",
            Required = true,
        }),
    },
    Impl = function(args)
        pm:Status(args.name)
    end,
})

-- Startup command
local startupCommand = Commandline.Command.new({
    Name = "startup",
    Description = "Configure lune-pm to start on system boot",
    Flags = {
        Commandline.Flag.new({
            Name = "platform",
            Shorthand = "p",
            Description = "Platform (systemd)",
            Type = "string",
            Default = "systemd",
        }),
    },
    Impl = function(_, flags)
        pm:Startup(flags.platform)
    end,
})

-- Monit command
local monitCommand = Commandline.Command.new({
    Name = "monit",
    Description = "Real-time process monitoring dashboard",
    Flags = {
        Commandline.Flag.new({
            Name = "interval",
            Shorthand = "i",
            Description = "Refresh interval in seconds (default: 2)",
            Type = "number",
            Default = 2,
        }),
    },
    Impl = function(_, flags)
        pm:Monit(flags.interval)
    end,
})

-- Register all commands
Commandline.registerCommand(startCommand)
Commandline.registerCommand(stopCommand)
Commandline.registerCommand(restartCommand)
Commandline.registerCommand(listCommand)
Commandline.registerCommand(logsCommand)
Commandline.registerCommand(deleteCommand)
Commandline.registerCommand(deployCommand)
Commandline.registerCommand(rollbackCommand)
Commandline.registerCommand(statusCommand)
Commandline.registerCommand(startupCommand)
Commandline.registerCommand(monitCommand)

return {
    Commandline = Commandline,
    ProcessManager = ProcessManager,
    ProcessStore = ProcessStore,
}
