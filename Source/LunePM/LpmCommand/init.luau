--[[

LpmCommand

The root command for the lpm CLI. Registers all subcommands for managing
Lune application processes.

--]]

local Commandline = require("@packages/Commandline")
local DeleteCommand = require("@self/DeleteCommand")
local DeployCommand = require("@self/DeployCommand")
local ListCommand = require("@self/ListCommand")
local LogsCommand = require("@self/LogsCommand")
local MonitCommand = require("@self/MonitCommand")
local RestartCommand = require("@self/RestartCommand")
local RollbackCommand = require("@self/RollbackCommand")
local StartCommand = require("@self/StartCommand")
local StartupCommand = require("@self/StartupCommand")
local StatusCommand = require("@self/StatusCommand")
local StopCommand = require("@self/StopCommand")
local __VERSION__ = require("@self/__VERSION__")

return Commandline.Command.new({
    Name = "lpm",
    Description = "A process manager for Lune applications, similar to pm2.",
    Version = __VERSION__,
    Subcommands = {
        DeleteCommand,
        DeployCommand,
        ListCommand,
        LogsCommand,
        MonitCommand,
        RestartCommand,
        RollbackCommand,
        StartCommand,
        StartupCommand,
        StatusCommand,
        StopCommand,
    },
})
