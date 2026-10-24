--[[

LpmCommand

The root command for the lpm CLI. Registers all subcommands for managing
Lune application processes.

--]]

const Commandline = require("@packages/Commandline")
const DeleteCommand = require("@self/DeleteCommand")
const DeployCommand = require("@self/DeployCommand")
const ListCommand = require("@self/ListCommand")
const LogsCommand = require("@self/LogsCommand")
const MonitCommand = require("@self/MonitCommand")
const RestartCommand = require("@self/RestartCommand")
const RollbackCommand = require("@self/RollbackCommand")
const StartCommand = require("@self/StartCommand")
const StartupCommand = require("@self/StartupCommand")
const StatusCommand = require("@self/StatusCommand")
const StopCommand = require("@self/StopCommand")
const __VERSION__ = require("@self/__VERSION__")

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
