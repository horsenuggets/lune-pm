--[[

ProcessStore

Manages persistent storage of process configurations and state. Stores data in a JSON file
in the user's home directory.

--]]

const fs = require("@lune/fs")
const process = require("@lune/process")
const serde = require("@lune/serde")
const t = require("@packages/t")

const LPM_DATA_DIR = `{process.env.HOME}/.lune-pm`
const PROCESS_FILE = `{LPM_DATA_DIR}/processes.json`
const VERSIONS_DIR = `{LPM_DATA_DIR}/versions`
const LOGS_DIR = `{LPM_DATA_DIR}/logs`

export type ProcessConfig = {
    name: string,
    script: string,
    cwd: string?,
    pid: number?,
    status: "online" | "stopped" | "errored",
    restarts: number,
    maxRestarts: number?,
    restartDelay: number?,
    autoRestart: boolean?,
    createdAt: string,
    updatedAt: string,
    currentVersion: number,
    versions: { string },
    env: { [string]: string }?,
    command: string?,
}

const ProcessStore = {}
ProcessStore.__index = ProcessStore

const function ensureDirectories()
    if not fs.isDir(LPM_DATA_DIR) then
        fs.writeDir(LPM_DATA_DIR)
    end
    if not fs.isDir(VERSIONS_DIR) then
        fs.writeDir(VERSIONS_DIR)
    end
    if not fs.isDir(LOGS_DIR) then
        fs.writeDir(LOGS_DIR)
    end
end

function ProcessStore.new()
    const self = setmetatable({}, ProcessStore)
    ensureDirectories()
    return self
end

function ProcessStore.GetAll(self: ProcessStore): { [string]: ProcessConfig }
    if not fs.isFile(PROCESS_FILE) then
        return {}
    end

    const content = fs.readFile(PROCESS_FILE)
    const success, data = pcall(function()
        return serde.decode("json", content)
    end)

    if success then
        return data
    end
    return {}
end

function ProcessStore.Get(self: ProcessStore, name: string): ProcessConfig?
    assert(t.string(name), "Expected name to be a string")

    const processes = self:GetAll()
    return processes[name]
end

function ProcessStore.Save(self: ProcessStore, config: ProcessConfig)
    assert(t.table(config), "Expected config to be a table")
    assert(t.string(config.name), "Expected config.name to be a string")

    const processes = self:GetAll()
    config.updatedAt = os.date("%Y-%m-%dT%H:%M:%S")
    processes[config.name] = config
    fs.writeFile(PROCESS_FILE, serde.encode("json", processes, true))
end

function ProcessStore.Delete(self: ProcessStore, name: string)
    assert(t.string(name), "Expected name to be a string")

    const processes = self:GetAll()
    processes[name] = nil
    fs.writeFile(PROCESS_FILE, serde.encode("json", processes, true))
end

function ProcessStore.SaveVersion(self: ProcessStore, name: string, scriptPath: string): number
    assert(t.string(name), "Expected name to be a string")
    assert(t.string(scriptPath), "Expected scriptPath to be a string")

    const config = self:Get(name)
    if not config then
        error(`Process "{name}" not found`)
    end

    const versionDir = `{VERSIONS_DIR}/{name}`
    if not fs.isDir(versionDir) then
        fs.writeDir(versionDir)
    end

    const versionNumber = #config.versions + 1
    const versionFile = `{versionDir}/v{versionNumber}.luau`

    -- Copy the script to the versions directory
    const content = fs.readFile(scriptPath)
    fs.writeFile(versionFile, content)

    table.insert(config.versions, versionFile)
    config.currentVersion = versionNumber
    self:Save(config)

    return versionNumber
end

function ProcessStore.GetVersionPath(self: ProcessStore, name: string, version: number?): string?
    assert(t.string(name), "Expected name to be a string")

    const config = self:Get(name)
    if not config then
        return nil
    end

    const v = version or config.currentVersion
    return config.versions[v]
end

function ProcessStore.GetLogPath(self: ProcessStore, name: string): string
    assert(t.string(name), "Expected name to be a string")
    return `{LOGS_DIR}/{name}.log`
end

function ProcessStore.GetDataDir(): string
    return LPM_DATA_DIR
end

export type ProcessStore = typeof(ProcessStore) & typeof(ProcessStore.new())

return ProcessStore
