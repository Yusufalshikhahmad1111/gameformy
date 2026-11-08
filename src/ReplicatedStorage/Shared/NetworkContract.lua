-- Kingdoms Conquest — single authoritative network contract
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkContract = {}

NetworkContract.Version = 1

local EVENT_SPECS = {
    {Name="Command", ClassName="RemoteEvent"},
    {Name="State", ClassName="RemoteEvent"},
    {Name="Feedback", ClassName="RemoteEvent"},
    {Name="VFX", ClassName="UnreliableRemoteEvent"},
    {Name="LobbyAction", ClassName="RemoteEvent"},
    {Name="LobbyState", ClassName="RemoteEvent"},
    {Name="RequestState", ClassName="RemoteFunction"},
    {Name="RequestLobbyState", ClassName="RemoteFunction"},
}

local function ensureRemote(parent, spec)
    local current = parent:FindFirstChild(spec.Name)
    if current and current.ClassName ~= spec.ClassName then
        current:Destroy()
        current = nil
    end

    if not current then
        current = Instance.new(spec.ClassName)
        current.Name = spec.Name
        current.Parent = parent
    end

    return current
end

function NetworkContract.Ensure()
    local folder = ReplicatedStorage:FindFirstChild("KingdomsRemotes")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "KingdomsRemotes"
        folder.Parent = ReplicatedStorage
    end

    folder:SetAttribute("ContractVersion", NetworkContract.Version)

    local remotes = {}
    for _, spec in ipairs(EVENT_SPECS) do
        remotes[spec.Name] = ensureRemote(folder, spec)
    end

    return folder, remotes
end

function NetworkContract.Get()
    local folder = ReplicatedStorage:FindFirstChild("KingdomsRemotes")
    if not folder then
        return nil, "KingdomsRemotes missing"
    end

    if folder:GetAttribute("ContractVersion") ~= NetworkContract.Version then
        return nil, "Network contract version mismatch"
    end

    local remotes = {}
    for _, spec in ipairs(EVENT_SPECS) do
        local remote = folder:FindFirstChild(spec.Name)
        if not remote or remote.ClassName ~= spec.ClassName then
            return nil, "Missing or invalid remote: " .. spec.Name
        end
        remotes[spec.Name] = remote
    end

    return folder, remotes
end

function NetworkContract.List()
    local names = {}
    for _, spec in ipairs(EVENT_SPECS) do
        table.insert(names, spec.Name)
    end
    return names
end

return NetworkContract
