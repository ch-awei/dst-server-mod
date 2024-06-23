TUNING.SALTLICK_BEEFALO_USES = 0
TUNING.PERISH_CAGE_MULT = 0
TUNING.PERISH_MUSHROOM_LIGHT_MULT = 0
TUNING.PERISH_FRIDGE_MULT = 0.2
TUNING.PERISH_SALTBOX_MULT = 0
TUNING.BEARGERFUR_SACK_PRESERVER_RATE = 0

local fresh_list = {'sisturn', 'seedpouch'}

for _, v in pairs(fresh_list) do
  AddPrefabPostInit(v, function(inst)
    if not TheWorld.ismastersim then return end
    if not inst.components.preserver then
      inst:AddComponent('preserver')
    end
    local rate = inst.components.preserver.perish_rate_multiplier
    if type(rate) ~= 'number' or rate > 0 then
      inst.components.preserver:SetPerishRateMultiplier(0)
    end
  end)
end

local function Recovery(item)
  if item and item.awei_stop_perish and item.components.perishable then
    item.awei_stop_perish = nil
    item.components.perishable:StartPerishing()
  end
end

local function StopPerishing(inst)
  local c, _i, item = inst.components.container, 0
  if not c then return end
  for k, v in pairs(c.slots) do
    if v:HasTag('lightbattery') then
      _i, item = k, v
      break
    end
  end
  if item and item.components.perishable and not item.awei_stop_perish then
    item.awei_stop_perish = true
    item.components.perishable:StopPerishing()
  end
  if _i == 0 or _i == #c.slots then return end
  for k = _i + 1, #c.slots do
    Recovery(c.slots[k])
  end
end

AddPrefabPostInit('hutch', function(inst)
  if not TheWorld.ismastersim then return end
  inst:ListenForEvent('itemget', StopPerishing)
  inst:ListenForEvent('itemlose', function(inst, data)
    Recovery(data and data.prev_item)
    StopPerishing(inst)
  end)
  local on_preload = inst.OnPreLoad or function() end
  inst.OnPreLoad = function(inst, data, ...)
    StopPerishing(inst)
    return on_preload(inst, data, ...)
  end
end)
