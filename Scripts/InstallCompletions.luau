#!/usr/bin/env -S lune run

--[[

InstallCompletions

Installs shell completion scripts for the lpm CLI.

--]]

local Commandline = require("@packages/Commandline")
local process = require("@lune/process")

-- Build the command tree for completion generation
local rootCommand = Commandline.Command.new({
    Name = "lpm",
    Description = "A process manager for Lune applications, similar to pm2.",
    Subcommands = {
        Commandline.Command.new({
            Name = "delete",
            Description = "Delete a process from the list.",
            Args = {
                Commandline.Arg.new({
                    Name = "name",
                    Description = "Name of the process to delete.",
                    Required = true,
                }),
            },
        }),
        Commandline.Command.new({
            Name = "deploy",
            Description = "Deploy a new version of a process.",
            Args = {
                Commandline.Arg.new({
                    Name = "name",
                    Description = "Name of the process.",
                    Required = true,
                }),
                Commandline.Arg.new({
                    Name = "script",
                    Description = "Path to the new script.",
                    Required = true,
                }),
            },
        }),
        Commandline.Command.new({
            Name = "list",
            Description = "List all managed processes.",
        }),
        Commandline.Command.new({
            Name = "logs",
            Description = "View process logs.",
            Args = {
                Commandline.Arg.new({
                    Name = "name",
                    Description = "Name of the process.",
                    Required = true,
                }),
            },
            Flags = {
                Commandline.Flag.new({
                    Name = "follow",
                    Shorthand = "f",
                    Description = "Follow log output in real-time.",
                    Type = "boolean",
                }),
                Commandline.Flag.new({
                    Name = "lines",
                    Shorthand = "n",
                    Description = "Number of lines to show (default: 50).",
                    Type = "number",
                    Default = 50,
                }),
            },
        }),
        Commandline.Command.new({
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
        }),
        Commandline.Command.new({
            Name = "restart",
            Description = "Restart a process.",
            Args = {
                Commandline.Arg.new({
                    Name = "name",
                    Description = "Name of the process to restart.",
                    Required = true,
                }),
            },
        }),
        Commandline.Command.new({
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
        }),
        Commandline.Command.new({
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
        }),
        Commandline.Command.new({
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
        }),
        Commandline.Command.new({
            Name = "status",
            Description = "Show detailed status of a process.",
            Args = {
                Commandline.Arg.new({
                    Name = "name",
                    Description = "Name of the process.",
                    Required = true,
                }),
            },
        }),
        Commandline.Command.new({
            Name = "stop",
            Description = "Stop a running process (use 'all' to stop all).",
            Args = {
                Commandline.Arg.new({
                    Name = "name",
                    Description = "Name of the process to stop.",
                    Required = true,
                }),
            },
        }),
    },
})

Commandline.Toolkit.installCompletions({
    Command = rootCommand,
    Shell = process.args[1] or "zsh",
})
