--[[

ProcessManager

Handles spawning, monitoring, and controlling Lune processes. Provides start, stop, restart,
and monitoring functionality.

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

function ProcessManager.new()
    local self = setmetatable({}, ProcessManager)
    return self
end

function ProcessManager.Start(self: ProcessManager, scriptPath: string, name: string?): ProcessStore.ProcessConfig
    assert(t.string(scriptPath), "Expected scriptPath to be a string")

    if not fs.isFile(scriptPath) then
        error(`Script not found: {scriptPath}`)
    end

    local processName = name or scriptPath:match("([^/]+)%.luau$") or "unnamed"

    -- Check if process already exists
    local existing = store:Get(processName)
    if existing and existing.status == "online" then
        error(`Process "{processName}" is already running`)
    end

    local logPath = store:GetLogPath(processName)

    -- Create or update process config
    local config: ProcessStore.ProcessConfig = existing
        or {
            name = processName,
            script = scriptPath,
            pid = nil,
            status = "stopped",
            restarts = 0,
            createdAt = os.date("%Y-%m-%dT%H:%M:%S"),
            updatedAt = os.date("%Y-%m-%dT%H:%M:%S"),
            currentVersion = 0,
            versions = {},
        }

    -- Save the script version if this is a new process or the script changed
    if config.currentVersion == 0 or config.script ~= scriptPath then
        config.script = scriptPath
        store:SaveVersion(processName, scriptPath)
        config = store:Get(processName) :: ProcessStore.ProcessConfig
    end

    -- Start the process in the background using nohup
    local result = process.exec("sh", {
        "-c",
        `nohup lune run {scriptPath} >> {logPath} 2>&1 & echo $!`,
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

    if result.ok then
        config.status = "stopped"
        config.pid = nil
        store:Save(config)
        print(`{stdio.color("red")}Stopped{stdio.style("reset")} {name}`)
        return true
    else
        -- Process might already be dead
        config.status = "stopped"
        config.pid = nil
        store:Save(config)
        return true
    end
end

function ProcessManager.Restart(self: ProcessManager, name: string): ProcessStore.ProcessConfig
    assert(t.string(name), "Expected name to be a string")

    local config = store:Get(name)
    if not config then
        error(`Process "{name}" not found`)
    end

    if config.status == "online" then
        self:Stop(name)
        task.wait(0.5) -- Brief pause before restart
    end

    config.restarts += 1
    store:Save(config)

    return self:Start(config.script, name)
end

function ProcessManager.List(self: ProcessManager)
    local processes = store:GetAll()

    if not next(processes) then
        print("No processes registered")
        return
    end

    print()
    local header = string.format(
        "%s%-15s %-10s %-8s %-10s %-8s%s",
        stdio.style("bold"),
        "Name",
        "Status",
        "PID",
        "Restarts",
        "Version",
        stdio.style("reset")
    )
    print(header)
    print(string.rep("-", 60))

    for name, config in processes do
        local statusColor = if config.status == "online"
            then stdio.color("green")
            elseif config.status == "errored" then stdio.color("red")
            else stdio.color("yellow")

        local pid = config.pid and tostring(config.pid) or "-"
        local version = `v{config.currentVersion}`

        local row = string.format(
            "%-15s %s%-10s%s %-8s %-10d %-8s",
            name,
            statusColor,
            config.status,
            stdio.style("reset"),
            pid,
            config.restarts,
            version
        )
        print(row)
    end

    print()
end

function ProcessManager.Logs(self: ProcessManager, name: string, lines: number?)
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
    local result = process.exec("tail", { `-n{numLines}`, logPath })

    if result.ok then
        print(`{stdio.style("dim")}--- Last {numLines} lines of {name} ---{stdio.style("reset")}`)
        print(result.stdout)
    else
        print("Failed to read logs")
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

    -- Save new version
    local versionNumber = store:SaveVersion(name, scriptPath)
    config = store:Get(name) :: ProcessStore.ProcessConfig

    print(`Deployed version {versionNumber} of "{name}"`)

    -- Restart if running
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

    -- Restart if running
    if config.status == "online" then
        -- Get the version script path
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

    print()
    print(`{stdio.style("bold")}Process: {name}{stdio.style("reset")}`)
    print(string.rep("-", 40))
    print(`Status:       {config.status}`)
    print(`PID:          {config.pid or "-"}`)
    print(`Script:       {config.script}`)
    print(`Restarts:     {config.restarts}`)
    print(`Version:      {config.currentVersion}/{#config.versions}`)
    print(`Created:      {config.createdAt}`)
    print(`Updated:      {config.updatedAt}`)
    print()
end

export type ProcessManager = typeof(ProcessManager) & typeof(ProcessManager.new())

return ProcessManager
