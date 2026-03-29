AddPrefabPostInit('world', function(world)
  if TUNING_MEDAL ~= nil and TUNING_MEDAL.AUTOTRAP_RESET_TIME ~= nil and TUNING_MEDAL.AUTOTRAP_RESET_TIME > 1 then
    TUNING_MEDAL.AUTOTRAP_RESET_TIME = 1
  end
end)

AddPrefabPostInit('medal_cookpot', function(inst)
  if not TheWorld.ismastersim then return end
  if inst.components.stewer ~= nil then
    inst.components.stewer.cooktimemult = 0
  end
end)
