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
            Short = "n",
            Description = "Name for the process",
            Type = "string",
        }),
    },
    Run = function(args, flags)
        pm:Start(args.script, flags.name)
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
    Run = function(args)
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
    Run = function(args)
        pm:Restart(args.name)
    end,
})

-- List command
local listCommand = Commandline.Command.new({
    Name = "list",
    Description = "List all managed processes",
    Run = function()
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
            Short = "n",
            Description = "Number of lines to show",
            Type = "number",
            Default = 50,
        }),
    },
    Run = function(args, flags)
        pm:Logs(args.name, flags.lines)
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
    Run = function(args)
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
    Run = function(args)
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
            Short = "v",
            Description = "Version number to rollback to (default: previous)",
            Type = "number",
        }),
    },
    Run = function(args, flags)
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
    Run = function(args)
        pm:Status(args.name)
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

return {
    Commandline = Commandline,
    ProcessManager = ProcessManager,
    ProcessStore = ProcessStore,
}
