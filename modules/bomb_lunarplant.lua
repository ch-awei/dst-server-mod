AddPrefabPostInit('bomb_lunarplant', function(inst)
	if not TheWorld.ismastersim then return end
	if not inst.components.complexprojectile then return end
	local _onlaunchfn = inst.components.complexprojectile.onlaunchfn
	inst.components.complexprojectile:SetOnLaunch(function(inst, attacker, ...)
		_onlaunchfn(inst, attacker, ...)
		attacker:DoTaskInTime(2, function(attacker)
			if attacker and attacker.components.inventory then
				local item = GLOBAL.SpawnPrefab(inst.prefab or 'bomb_lunarplant')
				attacker.components.inventory:GiveItem(item)
			end
		end)
	end)
end)
