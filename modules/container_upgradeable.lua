local function OnUpgrade(inst, performer, upgraded_from_item)
  local numupgrades = inst.components.upgradeable.numupgrades
  if numupgrades == 1 then
    inst._chestupgrade_stacksize = true
    if inst.components.container ~= nil then
      inst.components.container:EnableInfiniteStackSize(true)
      inst:AddTag('_is_InfiniteStackSize')
    end
    if upgraded_from_item then
      local x, y, z = inst.Transform:GetWorldPosition()
      local fx = SpawnPrefab("chestupgrade_stacksize_taller_fx")
      fx.Transform:SetPosition(x, y, z)
    end
  end
  inst.components.upgradeable.upgradetype = nil

  if inst.components.lootdropper ~= nil then
    inst.components.lootdropper:SetLoot({ "alterguardianhatshard" })
  end
end

AddComponentPostInit('container', function(self, inst)
  if inst.components.upgradeable ~= nil
    or inst:HasOneOfTags({'chest_upgradeable', '_health'})
    or not self.acceptsstacks
  then
    return
  end

  local upgradeable = inst:AddComponent('upgradeable')
  upgradeable.upgradetype = UPGRADETYPES.CHEST
  upgradeable:SetOnUpgradeFn(OnUpgrade)

  local _onload = inst.OnLoad or function() end
  inst.OnLoad = function(_, ...)
    if _.components.upgradeable ~= nil and _.components.upgradeable.numupgrades > 0 then
      OnUpgrade(_)
    end
    return _onload(_, ...)
  end
end)

if IsServer then return end

AddPrefabPostInitAny(function(inst)
  if inst:HasOneOfTags({'INLIMBO', 'FX', 'NOCLICK', '_health'}) then
    return
  end
  inst:DoTaskInTime(0, function(inst)
    if not inst:HasTag('_container') then return end
    ResetBasicName(inst, function(str)
      if inst:HasTag('_is_InfiniteStackSize') then
        return '[弹性] ' .. str
      end
    end)
  end)
end)
