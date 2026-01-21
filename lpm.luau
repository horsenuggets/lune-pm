#!/usr/bin/env -S lune run

--[[

lpm

CLI entry point for lune-pm. Parses command line arguments and executes the appropriate
command.

--]]

local LunePM = require("@lunepm")
local process = require("@lune/process")
local stdio = require("@lune/stdio")

local function lpm()
    local args = process.args

    if #args == 0 then
        print()
        print(`{stdio.style("bold")}lune-pm{stdio.style("reset")} - Process manager for Lune applications`)
        print()
        print("Usage: lpm <command> [options]")
        print()
        print("Commands:")
        print("  start <script>    Start a Lune application")
        print("  stop <name>       Stop a running process (use 'all' to stop all)")
        print("  restart <name>    Restart a process")
        print("  list              List all managed processes")
        print("  logs <name>       View process logs")
        print("  delete <name>     Delete a process from the list")
        print("  deploy <name>     Deploy a new version")
        print("  rollback <name>   Rollback to a previous version")
        print("  status <name>     Show detailed status")
        print("  startup           Configure boot persistence (systemd)")
        print("  monit             Real-time monitoring dashboard")
        print()
        print("Options:")
        print("  --name, -n          Specify process name (for start)")
        print("  --restart-delay     Seconds to wait before auto-restart")
        print("  --max-restarts      Maximum restart attempts")
        print("  --no-auto-restart   Disable automatic restart")
        print("  --follow, -f        Follow log output (for logs)")
        print("  --lines, -n         Number of log lines (for logs)")
        print("  --version, -v       Version number (for rollback)")
        print()
        return
    end

    local commandString = table.concat(args, " ")

    local success, err = pcall(function()
        LunePM.Commandline.execute(commandString)
    end)

    if not success then
        print(`{stdio.color("red")}Error:{stdio.style("reset")} {err}`)
        process.exit(1)
    end
end

lpm()
