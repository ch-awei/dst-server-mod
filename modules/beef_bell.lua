if IsClient then return end

local function on_player_dismounted(inst, data)
  local mount = data and data.target or nil
  if mount and mount:IsValid() then
    SpawnPrefab("small_puff").Transform:SetPosition(mount.Transform:GetWorldPosition())
    mount:Remove()
  end
end

local function OnDespawn(inst)
  for beef, _ in pairs(inst.components.leader.followers) do
    if not beef.components.health:IsDead() then
      beef._marked_for_despawn = true
      local dismounting = false
      if beef.components.rideable ~= nil then
        beef.components.rideable.canride = false
        local rider = beef.components.rideable.rider
        if rider and rider.components.rider then
          dismounting = true
          rider.components.rider:Dismount()
          rider:ListenForEvent("dismounted", on_player_dismounted)
        end
      end
      if beef.components.health ~= nil then
        beef.components.health:SetInvincible(true)
      end
      if not dismounting then
        SpawnPrefab("small_puff").Transform:SetPosition(beef.Transform:GetWorldPosition())
        beef:Remove()
      end
    end
  end
end

AddPrefabPostInit('beef_bell', function(inst)
  if not TheWorld.ismastersim or not inst.components.useabletargeteditem then
    return
  end
  local _usefn = inst.components.useabletargeteditem.onusefn
  inst.components.useabletargeteditem.onusefn = function(inst, ...)
    local res, msg = _usefn(inst, ...)
    if inst:HasTag('nobundling') then
      inst:RemoveTag('nobundling')
    end
    return res, msg
  end
  inst:ListenForEvent("onremove", OnDespawn)
end)
