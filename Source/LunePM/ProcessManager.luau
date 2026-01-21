--[[

ProcessManager

Handles spawning, monitoring, and controlling processes. Provides start, stop, restart,
and monitoring functionality with auto-restart support.

--]]

local ProcessStore = require("@self/ProcessStore")
local fs = require("@lune/fs")
local process = require("@lune/process")
local stdio = require("@lune/stdio")
local t = require("@packages/t")
local task = require("@lune/task")

local ProcessManager = {}
ProcessManager.__index = ProcessManager

local store = ProcessStore.new()

local DEFAULT_RESTART_DELAY = 5
local DEFAULT_MAX_RESTARTS = 10

function ProcessManager.new()
    local self = setmetatable({}, ProcessManager)
    return self
end

local function isProcessRunning(pid: number): boolean
    local result = process.exec("kill", { "-0", tostring(pid) })
    return result.ok
end

local function getProcessCommand(config: ProcessStore.ProcessConfig): (string, { string })
    if config.command then
        local parts = string.split(config.command, " ")
        local cmd = table.remove(parts, 1) :: string
        return cmd, parts
    end

    return "lune", { "run", config.script }
end

function ProcessManager.Start(
    self: ProcessManager,
    scriptPath: string,
    options: {
        name: string?,
        cwd: string?,
        restartDelay: number?,
        maxRestarts: number?,
        noAutoRestart: boolean?,
        command: string?,
        env: { [string]: string }?,
    }?
): ProcessStore.ProcessConfig
    assert(t.string(scriptPath), "Expected scriptPath to be a string")

    local opts = options or {}

    if not opts.command and not fs.isFile(scriptPath) then
        error(`Script not found: {scriptPath}`)
    end

    local processName = opts.name or scriptPath:match("([^/]+)%.luau$") or "unnamed"

    local existing = store:Get(processName)
    if existing and existing.status == "online" and existing.pid then
        if isProcessRunning(existing.pid) then
            error(`Process "{processName}" is already running (pid: {existing.pid})`)
        end
    end

    local logPath = store:GetLogPath(processName)
    local workingDir = opts.cwd or process.cwd

    local config: ProcessStore.ProcessConfig = existing
        or {
            name = processName,
            script = scriptPath,
            cwd = workingDir,
            pid = nil,
            status = "stopped",
            restarts = 0,
            maxRestarts = opts.maxRestarts or DEFAULT_MAX_RESTARTS,
            restartDelay = opts.restartDelay or DEFAULT_RESTART_DELAY,
            autoRestart = not opts.noAutoRestart,
            createdAt = os.date("%Y-%m-%dT%H:%M:%S"),
            updatedAt = os.date("%Y-%m-%dT%H:%M:%S"),
            currentVersion = 0,
            versions = {},
            env = opts.env,
            command = opts.command,
        }

    config.cwd = workingDir
    config.restartDelay = opts.restartDelay or config.restartDelay or DEFAULT_RESTART_DELAY
    config.maxRestarts = opts.maxRestarts or config.maxRestarts or DEFAULT_MAX_RESTARTS
    config.autoRestart = if opts.noAutoRestart ~= nil then not opts.noAutoRestart else config.autoRestart
    if opts.command then
        config.command = opts.command
    end
    if opts.env then
        config.env = opts.env
    end

    if config.currentVersion == 0 and not config.command then
        config.script = scriptPath
        store:SaveVersion(processName, scriptPath)
        config = store:Get(processName) :: ProcessStore.ProcessConfig
    end

    local cmd, args = getProcessCommand(config)
    local shellCmd = `nohup {cmd} {table.concat(args, " ")} >> {logPath} 2>&1 & echo $!`

    local result = process.exec("sh", { "-c", shellCmd }, {
        cwd = config.cwd,
    })

    if result.ok then
        local pid = tonumber(result.stdout:match("%d+"))
        config.pid = pid
        config.status = "online"
        store:Save(config)

        print(`{stdio.color("green")}Started{stdio.style("reset")} {processName} (pid: {pid})`)
    else
        config.status = "errored"
        store:Save(config)
        error(`Failed to start process: {result.stderr}`)
    end

    return config
end

function ProcessManager.Stop(self: ProcessManager, name: string): boolean
    assert(t.string(name), "Expected name to be a string")

    if name == "all" then
        local processes = store:GetAll()
        local stopped = 0
        for processName, config in processes do
            if config.status == "online" then
                self:Stop(processName)
                stopped += 1
            end
        end
        print(`Stopped {stopped} {stopped == 1 and "process" or "processes"}`)
        return true
    end

    local config = store:Get(name)
    if not config then
        error(`Process "{name}" not found`)
    end

    if config.status ~= "online" or not config.pid then
        print(`{stdio.color("yellow")}Process "{name}" is not running{stdio.style("reset")}`)
        return false
    end

    local result = process.exec("kill", { tostring(config.pid) })

    config.status = "stopped"
    config.pid = nil
    store:Save(config)
    print(`{stdio.color("red")}Stopped{stdio.style("reset")} {name}`)
    return true
end

function ProcessManager.Restart(self: ProcessManager, name: string): ProcessStore.ProcessConfig
    assert(t.string(name), "Expected name to be a string")

    local config = store:Get(name)
    if not config then
        error(`Process "{name}" not found`)
    end

    if config.status == "online" then
        self:Stop(name)
        task.wait(0.5)
    end

    config = store:Get(name) :: ProcessStore.ProcessConfig
    config.restarts += 1
    store:Save(config)

    return self:Start(config.script, {
        name = name,
        cwd = config.cwd,
        restartDelay = config.restartDelay,
        maxRestarts = config.maxRestarts,
        noAutoRestart = not config.autoRestart,
        command = config.command,
        env = config.env,
    })
end

function ProcessManager.List(self: ProcessManager)
    local processes = store:GetAll()

    if not next(processes) then
        print("No processes registered")
        return
    end

    print()
    local header = string.format(
        "%s%-15s %-10s %-8s %-10s %-8s %-12s%s",
        stdio.style("bold"),
        "Name",
        "Status",
        "PID",
        "Restarts",
        "Version",
        "Auto-restart",
        stdio.style("reset")
    )
    print(header)
    print(string.rep("-", 75))

    for name, config in processes do
        local actuallyRunning = config.pid and isProcessRunning(config.pid)

        if config.status == "online" and not actuallyRunning then
            config.status = "errored"
            config.pid = nil
            store:Save(config)
        end

        local statusColor = if config.status == "online"
            then stdio.color("green")
            elseif config.status == "errored" then stdio.color("red")
            else stdio.color("yellow")

        local pid = config.pid and tostring(config.pid) or "-"
        local version = `v{config.currentVersion}`
        local autoRestart = config.autoRestart and "yes" or "no"

        local row = string.format(
            "%-15s %s%-10s%s %-8s %-10d %-8s %-12s",
            name,
            statusColor,
            config.status,
            stdio.style("reset"),
            pid,
            config.restarts,
            version,
            autoRestart
        )
        print(row)
    end

    print()
end

function ProcessManager.Logs(self: ProcessManager, name: string, lines: number?, follow: boolean?)
    assert(t.string(name), "Expected name to be a string")

    local config = store:Get(name)
    if not config then
        error(`Process "{name}" not found`)
    end

    local logPath = store:GetLogPath(name)
    if not fs.isFile(logPath) then
        print("No logs available")
        return
    end

    local numLines = lines or 50

    if follow then
        print(`{stdio.style("dim")}--- Following logs for {name} (Ctrl+C to stop) ---{stdio.style("reset")}`)
        process.exec("tail", { `-n{numLines}`, "-f", logPath }, {
            stdio = "inherit",
        })
    else
        local result = process.exec("tail", { `-n{numLines}`, logPath })
        if result.ok then
            print(`{stdio.style("dim")}--- Last {numLines} lines of {name} ---{stdio.style("reset")}`)
            print(result.stdout)
        else
            print("Failed to read logs")
        end
    end
end

function ProcessManager.Delete(self: ProcessManager, name: string)
    assert(t.string(name), "Expected name to be a string")

    local config = store:Get(name)
    if not config then
        error(`Process "{name}" not found`)
    end

    if config.status == "online" then
        self:Stop(name)
    end

    store:Delete(name)
    print(`Deleted process "{name}"`)
end

function ProcessManager.Deploy(self: ProcessManager, name: string, scriptPath: string): number
    assert(t.string(name), "Expected name to be a string")
    assert(t.string(scriptPath), "Expected scriptPath to be a string")

    if not fs.isFile(scriptPath) then
        error(`Script not found: {scriptPath}`)
    end

    local config = store:Get(name)
    if not config then
        error(`Process "{name}" not found`)
    end

    local versionNumber = store:SaveVersion(name, scriptPath)
    config = store:Get(name) :: ProcessStore.ProcessConfig

    print(`Deployed version {versionNumber} of "{name}"`)

    if config.status == "online" then
        self:Restart(name)
    end

    return versionNumber
end

function ProcessManager.Rollback(self: ProcessManager, name: string, version: number?): number
    assert(t.string(name), "Expected name to be a string")

    local config = store:Get(name)
    if not config then
        error(`Process "{name}" not found`)
    end

    local targetVersion = version or (config.currentVersion - 1)

    if targetVersion < 1 or targetVersion > #config.versions then
        error(`Invalid version: {targetVersion}. Available: 1-{#config.versions}`)
    end

    if targetVersion == config.currentVersion then
        print(`Already on version {targetVersion}`)
        return targetVersion
    end

    config.currentVersion = targetVersion
    store:Save(config)

    print(`Rolled back "{name}" to version {targetVersion}`)

    if config.status == "online" then
        local versionPath = store:GetVersionPath(name, targetVersion)
        if versionPath then
            config.script = versionPath
            store:Save(config)
            self:Restart(name)
        end
    end

    return targetVersion
end

function ProcessManager.Status(self: ProcessManager, name: string)
    assert(t.string(name), "Expected name to be a string")

    local config = store:Get(name)
    if not config then
        error(`Process "{name}" not found`)
    end

    local actuallyRunning = config.pid and isProcessRunning(config.pid)
    if config.status == "online" and not actuallyRunning then
        config.status = "errored"
        config.pid = nil
        store:Save(config)
    end

    print()
    print(`{stdio.style("bold")}Process: {name}{stdio.style("reset")}`)
    print(string.rep("-", 40))
    print(`Status:        {config.status}`)
    print(`PID:           {config.pid or "-"}`)
    print(`Script:        {config.script}`)
    print(`Working dir:   {config.cwd or "-"}`)
    print(`Command:       {config.command or "lune run <script>"}`)
    print(`Restarts:      {config.restarts}`)
    print(`Max restarts:  {config.maxRestarts or DEFAULT_MAX_RESTARTS}`)
    print(`Restart delay: {config.restartDelay or DEFAULT_RESTART_DELAY}s`)
    print(`Auto-restart:  {config.autoRestart and "yes" or "no"}`)
    print(`Version:       {config.currentVersion}/{#config.versions}`)
    print(`Created:       {config.createdAt}`)
    print(`Updated:       {config.updatedAt}`)
    print()
end

function ProcessManager.Startup(self: ProcessManager, platform: string?)
    local plat = platform or "systemd"

    if plat ~= "systemd" then
        error(`Unsupported platform: {plat}. Currently only "systemd" is supported.`)
    end

    local user = process.env.USER or "root"
    local home = process.env.HOME or `/home/{user}`
    local rokitPath = `{home}/.rokit/bin`

    local serviceContent = "[Unit]\n"
        .. "Description=lune-pm Process Manager\n"
        .. "After=network.target\n"
        .. "\n"
        .. "[Service]\n"
        .. "Type=oneshot\n"
        .. "RemainAfterExit=yes\n"
        .. `User={user}\n`
        .. `Environment=HOME={home}\n`
        .. `Environment=PATH={rokitPath}:/usr/local/bin:/usr/bin:/bin\n`
        .. `ExecStart={rokitPath}/lune run {home}/.lune-pm/resurrect.luau\n`
        .. `ExecStop={rokitPath}/lpm stop all\n`
        .. "\n"
        .. "[Install]\n"
        .. "WantedBy=multi-user.target\n"

    local resurrectScript = [=[#!/usr/bin/env -S lune run

--[[

resurrect

Restores all saved processes on system startup.

--]]

local process = require("@lune/process")
local fs = require("@lune/fs")
local serde = require("@lune/serde")

local LPM_DATA_DIR = process.env.HOME .. "/.lune-pm"
local PROCESS_FILE = LPM_DATA_DIR .. "/processes.json"

local function resurrect()
	if not fs.isFile(PROCESS_FILE) then
		print("No processes to resurrect")
		return
	end

	local content = fs.readFile(PROCESS_FILE)
	local processes = serde.decode("json", content)

	for name, config in processes do
		if config.autoRestart then
			print("Resurrecting " .. name .. "...")
			local result = process.exec("lpm", { "start", config.script, "--name", name })
			if result.ok then
				print("  Started " .. name)
			else
				print("  Failed to start " .. name .. ": " .. result.stderr)
			end
		end
	end
end

resurrect()
]=]

    local dataDir = ProcessStore.GetDataDir()
    local resurrectPath = `{dataDir}/resurrect.luau`
    fs.writeFile(resurrectPath, resurrectScript)

    print(`{stdio.style("bold")}Startup Configuration{stdio.style("reset")}`)
    print()
    print("1. Create the systemd service file:")
    print(`   sudo nano /etc/systemd/system/lune-pm.service`)
    print()
    print("2. Paste this content:")
    print()
    print(serviceContent)
    print()
    print("3. Enable the service:")
    print(`   sudo systemctl daemon-reload`)
    print(`   sudo systemctl enable lune-pm`)
    print()
    print(`Resurrect script saved to: {resurrectPath}`)
end

function ProcessManager.Monit(self: ProcessManager, interval: number?)
    local refreshInterval = interval or 2

    print(`{stdio.style("bold")}Process Monitor{stdio.style("reset")} (refresh: {refreshInterval}s, Ctrl+C to exit)`)
    print()

    while true do
        process.exec("clear", {})
        print(`{stdio.style("bold")}lune-pm Monitor{stdio.style("reset")} - {os.date("%H:%M:%S")}`)
        print()
        self:List()

        task.wait(refreshInterval)
    end
end

function ProcessManager.CheckAndRestart(self: ProcessManager)
    local processes = store:GetAll()
    local restarted = 0

    for name, config in processes do
        if config.autoRestart and config.status == "online" then
            if config.pid and not isProcessRunning(config.pid) then
                print(`Process "{name}" crashed, restarting...`)

                if config.restarts >= (config.maxRestarts or DEFAULT_MAX_RESTARTS) then
                    print(`  Max restarts ({config.maxRestarts}) reached, not restarting`)
                    config.status = "errored"
                    store:Save(config)
                else
                    local delay = config.restartDelay or DEFAULT_RESTART_DELAY
                    print(`  Waiting {delay} seconds before restart...`)
                    task.wait(delay)
                    self:Restart(name)
                    restarted += 1
                end
            end
        end
    end

    return restarted
end

export type ProcessManager = typeof(ProcessManager) & typeof(ProcessManager.new())

return ProcessManager
