if GLOBAL.TheNet:GetIsServer() or GLOBAL.TheNet:IsDedicated() then
	print("[custom-shards] Starting")
	local BIDIR_CONNECTIONS = {}
	local BIDIR_CONNECTIONS = GetModConfigData("Connections")
	local DELETE_UNUSED = GetModConfigData("DeleteUnused")

	local targets = nil

	local function printObject(obj)
		local result
		if not obj then
			result = "<nil>"
		elseif "table" == type(obj) then
			result = "{ "
			for k,v in pairs(obj) do
				result = result..k.." = "..printObject(v)..", "
			end
			result = " }"
		elseif "function" == type(obj) then
			result = "<function>"
		else
			result = ""..obj
		end
		return result
	end

	local function getTargets(shardId)
		if not targets and BIDIR_CONNECTIONS[shardId] then
			targets = BIDIR_CONNECTIONS[shardId]
			print("[custom-shards] shardId="..shardId)
			print("[custom-shards] targets["..#targets.."]")
			print("[custom-shards] target="..printObject(targets))
		end
		return targets
	end

	AddPrefabPostInitAny(function (inst)
		if inst and inst.components and inst.components.worldmigrator then
			local shardId = GLOBAL.TheShard:GetShardId()
			getTargets(shardId)
			print("[custom-shards] "..inst.prefab)
			if inst.components.worldmigrator.id then
				print("[custom-shards] id ------------> "..inst.components.worldmigrator.id)
			end
			if inst.components.worldmigrator.linkedWorld then
				print("[custom-shards] linkedWorld ---> "..inst.components.worldmigrator.linkedWorld)
			end
			if inst.components.worldmigrator.auto then
				print("[custom-shards] auto -----------> true")
			else
				print("[custom-shards] auto -----------> false")
			end
			if inst.components.worldmigrator.receivedPortal then
				print("[custom-shards] receivedPortal -> "..inst.components.worldmigrator.receivedPortal)
			end

			if 0 < #targets then
				local target = targets[1]
				inst.components.worldmigrator:SetDestinationWorld(target, true)
				table.remove(targets, 1)
				print("[custom-shards] Connected "..shardId.." to world "..target.." via "..inst.prefab)
			else
				print("[custom-shards] Removing "..inst.prefab.." from world "..shardId)
--				inst:Remove()
			end
		end
	end)
else
	print("[custom-shards] skipping")
end
