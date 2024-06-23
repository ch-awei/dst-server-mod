if IsClient then return end

local _prefab = 'alterguardianhatshard'

local function Enable(inst)
  if not inst:HasTag('init_befresh') then
    inst:AddTag('init_befresh')
    inst._has_preserver = inst.components.preserver ~= nil
    if inst._has_preserver then
      inst._perish_rate_multiplier = inst.components.preserver.perish_rate_multiplier
    end
  end
  if not inst.components.preserver then
    inst:AddComponent('preserver')
  end
  local _rate = inst.components.preserver.perish_rate_multiplier
  if type(_rate) ~= 'number' or _rate > 0 then
    inst.components.preserver:SetPerishRateMultiplier(0)
  end
end

AddComponentPostInit('container', function(self, inst)
  local _onload = inst.OnLoad or function()end
  inst.OnLoad = function(inst, data, ...)
    if self:Has(_prefab, 1) then
      Enable(inst)
    end
    return _onload(inst, data, ...)
  end
  local _onpreload = inst.OnPreLoad or function()end
  inst.OnPreLoad = function(inst, data, ...)
    if self:Has(_prefab, 1) then
      Enable(inst)
    end
    return _onpreload(inst, data, ...)
  end
  inst:ListenForEvent('itemget', function(inst, data)
    if data and data.item and data.item.prefab == _prefab and inst.components.container:Has(_prefab, 1) then
      Enable(inst)
    end
  end)
  inst:ListenForEvent('itemlose', function(inst)
    if inst:HasTag('init_befresh') and not inst.components.container:Has(_prefab, 1) and inst.components.preserver ~= nil then
      if inst._has_preserver then
        inst.components.preserver:SetPerishRateMultiplier(inst._perish_rate_multiplier)
      else
        inst:RemoveComponent('preserver')
      end
    end
  end)
end)
