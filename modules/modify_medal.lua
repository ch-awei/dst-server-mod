if not EndableOneOfMods({'1909182187'}) then return end

AddPrefabPostInit('world', function(world)
  if TUNING_MEDAL ~= nil and TUNING_MEDAL.AUTOTRAP_RESET_TIME ~= nil and TUNING_MEDAL.AUTOTRAP_RESET_TIME > 1 then
    TUNING_MEDAL.AUTOTRAP_RESET_TIME = 1
  end
end)

AddPrefabPostInit('medal_cookpot', function(inst)
  if not TheWorld.ismastersim then return end
  if inst.components.stewer ~= nil then
    inst.components.stewer.cooktimemult = 0.01
  end
end)

local medal_apices = require('medal_defs/medal_spice_defs')
if type(medal_apices) == 'table' then
  SpiceCaneat(medal_apices)
end
