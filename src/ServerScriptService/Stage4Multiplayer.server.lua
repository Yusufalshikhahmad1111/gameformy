-- Kingdoms Conquest — Stage 4 Multiplayer / Social
-- Lobby + party codes + cross-server matchmaking + reserved-server routing + reconnect handoff.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local MAX_PARTY = 4
local MAX_MATCH_PLAYERS = 8
local QUEUE_EXPIRY = 35
local RECONNECT_EXPIRY = 15 * 60
local MATCH_TOPIC_PREFIX = "KC_MATCH_READY_"
local QUEUE_NAME = "KingdomsConquest_Matchmaking_v1"
local RECONNECT_MAP_NAME = "KingdomsConquest_Reconnect_v1"

workspace:SetAttribute("Stage4Ready", true)
if workspace:GetAttribute("MatchActive") == nil then
	workspace:SetAttribute("MatchActive", false)
end

local remotes = ReplicatedStorage:FindFirstChild("Stage4Remotes")
if remotes then remotes:Destroy() end
remotes = Instance.new("Folder")
remotes.Name = "Stage4Remotes"
remotes.Parent = ReplicatedStorage

local actionRemote = Instance.new("RemoteEvent")
actionRemote.Name = "Action"
actionRemote.Parent = remotes

local stateRemote = Instance.new("RemoteEvent")
stateRemote.Name = "State"
stateRemote.Parent = remotes

local requestState = Instance.new("RemoteFunction")
requestState.Name = "RequestState"
requestState.Parent = remotes

local lobbySpawn = workspace:FindFirstChild("KingdomsLobbySpawn")
if not lobbySpawn then
	lobbySpawn = Instance.new("Part")
	lobbySpawn.Name = "KingdomsLobbySpawn"
	lobbySpawn.Anchored = true
	lobbySpawn.CanCollide = true
	lobbySpawn.Size = Vector3.new(50, 1, 50)
	lobbySpawn.Position = Vector3.new(0, 3, 160)
	lobbySpawn.Material = Enum.Material.Slate
	lobbySpawn.Color = Color3.fromRGB(37, 42, 40)
	lobbySpawn.Parent = workspace
end

local parties = {}
local playerParty = {}
local queuedParties = {}
local partyQueueNonce = {}
local localQueueOrder = {}
local pendingMatch = {}
local reconnectMap = nil
local matchmakingQueue = nil
local matchDirectory = nil
local rematchSignal = ReplicatedStorage:FindFirstChild("KingdomsRematchRequest")
if not rematchSignal then
	rematchSignal = Instance.new("BindableEvent")
	rematchSignal.Name = "KingdomsRematchRequest"
	rematchSignal.Parent = ReplicatedStorage
end

pcall(function()
	reconnectMap = MemoryStoreService:GetHashMap(RECONNECT_MAP_NAME)
	matchmakingQueue = MemoryStoreService:GetQueue(QUEUE_NAME, 30)
	matchDirectory = MemoryStoreService:GetHashMap("KingdomsConquest_MatchDirectory_v1")
end)

local function safeSetReconnect(userId, data)
	if not reconnectMap then return end
	pcall(function()
		reconnectMap:SetAsync(tostring(userId), data, RECONNECT_EXPIRY)
	end)
end

local function safeGetReconnect(userId)
	if not reconnectMap then return nil end
	local ok, value = pcall(function()
		return reconnectMap:GetAsync(tostring(userId))
	end)
	return ok and value or nil
end

local function safeRemoveReconnect(userId)
	if not reconnectMap then return end
	pcall(function()
		reconnectMap:RemoveAsync(tostring(userId))
	end)
end

local function topicForJob(jobId)
	return MATCH_TOPIC_PREFIX .. string.sub(jobId, 1, 55)
end

local function newPartyCode()
	for _ = 1, 30 do
		local code = string.format("%06d", math.random(0, 999999))
		local used = false
		for _, party in pairs(parties) do
			if party.Code == code then used = true break end
		end
		if not used then return code end
	end
	return string.format("%06d", math.random(0, 999999))
end

local function partyState(party)
	if not party then return nil end
	local members = {}
	for userId in pairs(party.Members) do
		local player = Players:GetPlayerByUserId(userId)
		table.insert(members, {
			UserId = userId,
			Name = player and player.DisplayName or ("User " .. tostring(userId)),
			Online = player ~= nil,
		})
	end
	table.sort(members, function(a, b) return a.UserId < b.UserId end)
	return {
		Id = party.Id,
		Code = party.Code,
		LeaderUserId = party.LeaderUserId,
		Members = members,
		Queued = queuedParties[party.Id] == true,
	}
end

local function sendState(player, status)
	local party = playerParty[player.UserId] and parties[playerParty[player.UserId]]
	stateRemote:FireClient(player, {
		Stage4Ready = true,
		MatchActive = workspace:GetAttribute("MatchActive") == true,
		MatchId = workspace:GetAttribute("MatchId"),
		Status = status or "",
		Party = partyState(party),
		QueuedPlayers = #localQueueOrder,
		Studio = RunService:IsStudio(),
	})
end

local function broadcastParty(party, status)
	if not party then return end
	for userId in pairs(party.Members) do
		local player = Players:GetPlayerByUserId(userId)
		if player then sendState(player, status) end
	end
end

local function createParty(player)
	if playerParty[player.UserId] then
		return false, "ALREADY_IN_PARTY"
	end
	local id = HttpService:GenerateGUID(false)
	local party = {
		Id = id,
		Code = newPartyCode(),
		LeaderUserId = player.UserId,
		Members = {[player.UserId] = true},
	}
	parties[id] = party
	playerParty[player.UserId] = id
	partyQueueNonce[id] = 0
	sendState(player, "Party created • share the 6-digit code")
	return true
end

local function removeFromQueue(partyId)
	queuedParties[partyId] = nil
	partyQueueNonce[partyId] = (partyQueueNonce[partyId] or 0) + 1
	for i = #localQueueOrder, 1, -1 do
		if localQueueOrder[i] == partyId then table.remove(localQueueOrder, i) end
	end
end

local function destroyParty(party)
	if not party then return end
	removeFromQueue(party.Id)
	for userId in pairs(party.Members) do
		playerParty[userId] = nil
	end
	parties[party.Id] = nil
end

local function leaveParty(player)
	local partyId = playerParty[player.UserId]
	local party = partyId and parties[partyId]
	if not party then
		sendState(player, "You are not in a party")
		return
	end
	if queuedParties[party.Id] then
		sendState(player, "Leave matchmaking before leaving the party")
		return
	end

	party.Members[player.UserId] = nil
	playerParty[player.UserId] = nil

	if party.LeaderUserId == player.UserId then
		local nextLeader = next(party.Members)
		if not nextLeader then
			destroyParty(party)
			sendState(player, "Party disbanded")
			return
		end
		party.LeaderUserId = nextLeader
	end

	sendState(player, "Left party")
	broadcastParty(party, "Party updated")
end

local function joinParty(player, code)
	if playerParty[player.UserId] then return false, "ALREADY_IN_PARTY" end
	local found
	for _, party in pairs(parties) do
		if party.Code == code then found = party break end
	end
	if not found then return false, "PARTY_NOT_FOUND" end
	local count = 0
	for _ in pairs(found.Members) do count += 1 end
	if count >= MAX_PARTY then return false, "PARTY_FULL" end
	if queuedParties[found.Id] then return false, "PARTY_ALREADY_QUEUED" end

	found.Members[player.UserId] = true
	playerParty[player.UserId] = found.Id
	broadcastParty(found, player.DisplayName .. " joined the party")
	return true
end

local function playerIdsForParty(party)
	local ids = {}
	for userId in pairs(party.Members) do
		table.insert(ids, userId)
	end
	table.sort(ids)
	return ids
end

local function ensurePartyForRematch(player)
	if playerParty[player.UserId] then
		return parties[playerParty[player.UserId]]
	end
	local teamId = player:GetAttribute("TeamId") or 1
	local id = HttpService:GenerateGUID(false)
	local party = {
		Id = id,
		Code = newPartyCode(),
		LeaderUserId = player.UserId,
		Members = {[player.UserId] = true},
	}
	parties[id] = party
	playerParty[player.UserId] = id

	-- Rebuild a rematch party from current-match teammates, capped at four.
	for _, candidate in ipairs(Players:GetPlayers()) do
		if candidate ~= player and (candidate:GetAttribute("TeamId") or 0) == teamId and not playerParty[candidate.UserId] then
			local count = 0
			for _ in pairs(party.Members) do count += 1 end
			if count >= MAX_PARTY then break end
			party.Members[candidate.UserId] = true
			playerParty[candidate.UserId] = party.Id
		end
	end
	return party
end

local function enqueueParty(party)
	if not party then return false, "NO_PARTY" end
	if party.LeaderUserId == 0 then return false, "NO_LEADER" end
	if queuedParties[party.Id] then return false, "ALREADY_QUEUED" end

	local ids = playerIdsForParty(party)
	if #ids == 0 then return false, "EMPTY_PARTY" end

	local nonce = (partyQueueNonce[party.Id] or 0) + 1
	partyQueueNonce[party.Id] = nonce
	queuedParties[party.Id] = true
	table.insert(localQueueOrder, party.Id)

	local ticket = {
		PartyId = party.Id,
		Code = party.Code,
		Nonce = nonce,
		JobId = game.JobId,
		PlayerUserIds = ids,
		PartySize = #ids,
		CreatedAt = os.time(),
	}

	if matchmakingQueue and not RunService:IsStudio() then
		local ok = pcall(function()
			matchmakingQueue:AddAsync(ticket, QUEUE_EXPIRY, 0)
		end)
		if not ok then
			removeFromQueue(party.Id)
			return false, "MATCHMAKING_UNAVAILABLE"
		end
	end

	broadcastParty(party, "Searching for opponents…")
	return true
end

local function assignTeams(playerIds, tickets)
	local teams = {}
	local team = 1
	for _, ticket in ipairs(tickets) do
		for _, userId in ipairs(ticket.PlayerUserIds) do
			teams[tostring(userId)] = team
		end
		team = (team == 1) and 2 or 1
	end
	return teams
end

local function activateLocalMatch(matchId, teamMap)
	workspace:SetAttribute("MatchId", matchId)
	for userIdString, teamId in pairs(teamMap) do
		local player = Players:GetPlayerByUserId(tonumber(userIdString))
		if player then
			player:SetAttribute("TeamId", teamId)
			local teams = game:GetService("Teams")
			local teamObject = teams:FindFirstChild(teamId == 1 and "Crimson" or "Azure")
			if teamObject then
				player.Team = teamObject
				player.Neutral = false
			end
		end
	end
	workspace:SetAttribute("MatchActive", true)
	for _, player in ipairs(Players:GetPlayers()) do
		sendState(player, "Match started")
	end
end

local function teleportPartyToMatch(payload)
	local party = parties[payload.PartyId]
	local localPlayers = {}
	if not party or not queuedParties[party.Id] or partyQueueNonce[party.Id] ~= payload.Nonce then
		return
	end
	for userId in pairs(party.Members) do
		local player = Players:GetPlayerByUserId(userId)
		if player then table.insert(localPlayers, player) end
	end
	if #localPlayers == 0 then return end

	local options = Instance.new("TeleportOptions")
	options.ReservedServerId = payload.ReservedServerId
	options:SetTeleportData({
		kcMatchId = payload.MatchId,
		kcTeamMap = payload.TeamMap,
		kcRejoin = false,
	})

	pendingMatch[payload.MatchId] = {
		ReservedServerId = payload.ReservedServerId,
		Players = localPlayers,
	}

	local ok, err = pcall(function()
		TeleportService:TeleportAsync(game.PlaceId, localPlayers, options)
	end)
	if ok then
		removeFromQueue(party.Id)
		pendingMatch[payload.MatchId].PartyId = party.Id
		broadcastParty(party, "Teleporting to battle…")
	else
		warn("[KingdomsConquest][Stage4] Teleport failed:", err)
		broadcastParty(party, "Teleport failed • retrying queue")
	end
end

local function publishMatch(selectedTickets)
	local matchId = HttpService:GenerateGUID(false)
	local reservedServerId = HttpService:GenerateGUID(false)
	if matchDirectory then
		pcall(function()
			matchDirectory:SetAsync(matchId, {ReservedServerId = reservedServerId, PlaceId = game.PlaceId, CreatedAt = os.time()}, RECONNECT_EXPIRY)
		end)
	end
	local teamMap = assignTeams(nil, selectedTickets)

	for _, ticket in ipairs(selectedTickets) do
		local reconnectData = {
			MatchId = matchId,
			ReservedServerId = reservedServerId,
			PlaceId = game.PlaceId,
			TeamId = nil,
			ExpiresAt = os.time() + RECONNECT_EXPIRY,
		}
		for _, userId in ipairs(ticket.PlayerUserIds) do
			reconnectData.TeamId = teamMap[tostring(userId)]
			safeSetReconnect(userId, reconnectData)
		end
	end

	for _, ticket in ipairs(selectedTickets) do
		local message = {
			PartyId = ticket.PartyId,
			Nonce = ticket.Nonce,
			MatchId = matchId,
			ReservedServerId = reservedServerId,
			TeamMap = teamMap,
		}
		local topic = topicForJob(ticket.JobId)
		pcall(function()
			MessagingService:PublishAsync(topic, message)
		end)
	end
end

local function processMemoryQueue()
	if RunService:IsStudio() or not matchmakingQueue then return end
	local ok, items, readId = pcall(function()
		return matchmakingQueue:ReadAsync(4, false, 0)
	end)
	if not ok or not items or #items == 0 then return end

	local selected = {}
	local totalPlayers = 0

	for _, ticket in ipairs(items) do
		local size = tonumber(ticket.PartySize) or #(ticket.PlayerUserIds or {})
		if size <= MAX_PARTY and totalPlayers + size <= MAX_MATCH_PLAYERS then
			if #selected == 0 or totalPlayers + size <= MAX_MATCH_PLAYERS then
				table.insert(selected, ticket)
				totalPlayers += size
			end
		end
		if totalPlayers >= MAX_MATCH_PLAYERS then break end
	end

	if #selected < 2 or totalPlayers < 2 then
		-- Keep the ticket(s) invisible until the MemoryStore invisibility timeout expires.
		return
	end

	local selectedMap = {}
	for _, ticket in ipairs(selected) do
		selectedMap[ticket.PartyId .. ":" .. tostring(ticket.Nonce)] = true
	end

	-- Re-add tickets that were read but not selected.
	for _, ticket in ipairs(items) do
		local key = ticket.PartyId .. ":" .. tostring(ticket.Nonce)
		if not selectedMap[key] then
			pcall(function()
				matchmakingQueue:AddAsync(ticket, QUEUE_EXPIRY, 0)
			end)
		end
	end

	pcall(function()
		matchmakingQueue:RemoveAsync(readId)
	end)
	publishMatch(selected)
end

local function studioStartMatch()
	if not RunService:IsStudio() then return end
	local selected = {}
	for _, partyId in ipairs(localQueueOrder) do
		local party = parties[partyId]
		if party and queuedParties[partyId] then
			local ids = playerIdsForParty(party)
			table.insert(selected, {
				PartyId = partyId,
				Nonce = partyQueueNonce[partyId],
				PlayerUserIds = ids,
				PartySize = #ids,
			})
		end
		if #selected >= 2 then break end
	end
	if #selected < 2 then return false end

	local matchId = "STUDIO-" .. HttpService:GenerateGUID(false)
	local teamMap = assignTeams(nil, selected)
	for _, ticket in ipairs(selected) do
		removeFromQueue(ticket.PartyId)
	end
	activateLocalMatch(matchId, teamMap)
	return true
end

requestState.OnServerInvoke = function(player)
	local party = playerParty[player.UserId] and parties[playerParty[player.UserId]]
	return {
		Stage4Ready = true,
		MatchActive = workspace:GetAttribute("MatchActive") == true,
		MatchId = workspace:GetAttribute("MatchId"),
		Party = partyState(party),
		QueuedPlayers = #localQueueOrder,
		Studio = RunService:IsStudio(),
	}
end

actionRemote.OnServerEvent:Connect(function(player, action, payload)
	if type(action) ~= "string" then return end
	payload = type(payload) == "table" and payload or {}

	if action == "CreateParty" then
		createParty(player)
	elseif action == "JoinParty" then
		local ok, reason = joinParty(player, tostring(payload.Code or ""):sub(1, 6))
		if not ok then sendState(player, "Could not join • " .. reason) end
	elseif action == "LeaveParty" then
		leaveParty(player)
	elseif action == "Queue" then
		local party = playerParty[player.UserId] and parties[playerParty[player.UserId]]
		if not party then
			local ok = createParty(player)
			party = ok and parties[playerParty[player.UserId]] or nil
		end
		if party and party.LeaderUserId == player.UserId then
			local ok, reason = enqueueParty(party)
			if not ok then sendState(player, "Queue failed • " .. reason) end
		else
			sendState(player, "Only the party leader can queue")
		end
		if RunService:IsStudio() then studioStartMatch() end
	elseif action == "LeaveQueue" then
		local party = playerParty[player.UserId] and parties[playerParty[player.UserId]]
		if party and party.LeaderUserId == player.UserId then
			removeFromQueue(party.Id)
			broadcastParty(party, "Matchmaking cancelled")
		end
	elseif action == "StartPractice" then
		if RunService:IsStudio() and not workspace:GetAttribute("MatchActive") then
			local party = playerParty[player.UserId]
			if not party then
				createParty(player)
				party = parties[playerParty[player.UserId]]
			end
			local teamMap = {[tostring(player.UserId)] = 1}
			workspace:SetAttribute("MatchId", "PRACTICE-" .. HttpService:GenerateGUID(false))
			player:SetAttribute("TeamId", 1)
			local teamObject = game:GetService("Teams"):FindFirstChild("Crimson")
			if teamObject then player.Team = teamObject player.Neutral = false end
			workspace:SetAttribute("MatchActive", true)
			sendState(player, "Practice match started")
		end
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(0.2)
		if not workspace:GetAttribute("MatchActive") then
			character:PivotTo(lobbySpawn.CFrame + Vector3.new(0, 5, 0))
		end
	end)

	local joinData = player:GetJoinData()
	local teleportData = joinData and joinData.TeleportData
	if type(teleportData) == "table" and teleportData.kcMatchId then
		workspace:SetAttribute("MatchId", teleportData.kcMatchId)
		if type(teleportData.kcTeamMap) == "table" then
			local teamId = teleportData.kcTeamMap[tostring(player.UserId)] or 1
			player:SetAttribute("TeamId", teamId)
			local teamObject = game:GetService("Teams"):FindFirstChild(teamId == 1 and "Crimson" or "Azure")
			if teamObject then player.Team = teamObject player.Neutral = false end
		end
		workspace:SetAttribute("MatchActive", true)
		safeRemoveReconnect(player.UserId)
	else
		local reconnect = safeGetReconnect(player.UserId)
		if reconnect and reconnect.ReservedServerId and reconnect.ExpiresAt and reconnect.ExpiresAt > os.time() and not RunService:IsStudio() then
			local options = Instance.new("TeleportOptions")
			options.ReservedServerId = reconnect.ReservedServerId
			options:SetTeleportData({
				kcMatchId = reconnect.MatchId,
				kcTeamMap = {[tostring(player.UserId)] = reconnect.TeamId or 1},
				kcRejoin = true,
			})
			task.defer(function()
				pcall(function()
					TeleportService:TeleportAsync(reconnect.PlaceId or game.PlaceId, {player}, options)
				end)
			end)
			return
		end
	end

	sendState(player, "Lobby ready")
end)

Players.PlayerRemoving:Connect(function(player)
	playerParty[player.UserId] = nil
end)

pcall(function()
	MessagingService:SubscribeAsync(topicForJob(game.JobId), function(message)
		if type(message.Data) == "table" then
			task.defer(teleportPartyToMatch, message.Data)
		end
	end)
end)

if not RunService:IsStudio() then
	task.spawn(function()
		while true do
			processMemoryQueue()
			task.wait(2)
		end
	end)
end

TeleportService.TeleportInitFailed:Connect(function(player, result, errorMessage)
	warn("[KingdomsConquest][Stage4] TeleportInitFailed:", player.Name, result, errorMessage)
	local partyId = playerParty[player.UserId]
	local party = partyId and parties[partyId]
	if party and not queuedParties[party.Id] then
		local ok, reason = enqueueParty(party)
		if not ok then
			sendState(player, "Teleport failed • queue retry unavailable: " .. tostring(reason))
			return
		end
	end
	sendState(player, "Teleport failed • re-queued")
end)

rematchSignal.Event:Connect(function(player)
	if not player or not player:IsDescendantOf(Players) then return end
	if workspace:GetAttribute("MatchActive") == true then
		sendState(player, "Finish the current match before rematching")
		return
	end
	local party = ensurePartyForRematch(player)
	if party.LeaderUserId == player.UserId then
		local ok, reason = enqueueParty(party)
		if not ok then broadcastParty(party, "Rematch queue failed • " .. reason) end
	else
		broadcastParty(party, "Rematch party ready • leader is queuing")
	end
end)

print("[KingdomsConquest] Stage 4 multiplayer/social initialized.")
