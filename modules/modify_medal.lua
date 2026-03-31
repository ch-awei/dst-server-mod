AddSimPostInit(function()
  local time = SafeGet(TUNING_MEDAL, "AUTOTRAP_RESET_TIME")
  if time > 1 then
    TUNING_MEDAL.AUTOTRAP_RESET_TIME = 1
  end
end)

AddPrefabPostInit("medal_cookpot", function(inst)
  -- if not TheWorld.ismastersim then return end
  if inst.components.stewer ~= nil then
    inst.components.stewer.cooktimemult = 0
  end
end)
