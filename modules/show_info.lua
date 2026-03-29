GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

local init_net = function(inst, name)
  inst['ShowInfo_net_' .. name] = net_float(inst.GUID, 'ShowInfo_' .. name)--, 'ShowInfo_' .. name .. '_changed')
end
local init_net_str = function(inst, name)
  inst['ShowInfo_net_' .. name] = net_string(inst.GUID, 'ShowInfo_' .. name)--, 'ShowInfo_' .. name .. '_changed')
end
local set_net = function(inst, name, value)
  if inst['ShowInfo_net_' .. name] ~= nil then
    inst['ShowInfo_net_' .. name]:set(value)
  end
end
local get_net = function(inst, name)
  if inst['ShowInfo_net_' .. name] ~= nil then
    return inst['ShowInfo_net_' .. name]:value() or nil
  end
  return nil
end

AddPrefabPostInitAny(function(inst)
  if IsEndableMods({'666155465', '2189004162'}) then return end
  if inst:HasOneOfTags({'NOCLICK', 'FX'}) then return end

  -- if inst:HasTag('_health') then end
  init_net(inst, 'health')
  init_net(inst, 'damage')
  init_net_str(inst, 'damage_more')
  -- if inst:HasTag('heatrock') then end
  init_net(inst, 'temperature')
  -- if inst:HasTag('weapon') then end
  -- init_net(inst, 'weapon')
  init_net_str(inst, 'finiteuses')

  inst:DoTaskInTime(0, function(inst)
    if inst.components.health then
      local fn_health = function(inst)
        set_net(inst, 'health', inst.components.health and inst.components.health.currenthealth or 0)
      end
      fn_health(inst)
      inst:ListenForEvent('healthdelta', fn_health)
    end
    if inst.components.combat then
      set_net(inst, 'damage', inst.components.combat.defaultdamage or 0)
      local percent = inst.components.combat.playerdamagepercent or 0
      if percent > 0 then
        set_net(inst, 'damage_more', FormatNumber(percent * 100, 1) .. '%')
      end
    end
    if inst.components.weapon then
      local fn_weapon = function(inst)
        set_net(inst, 'damage', inst.components.weapon.damage or 0)
      end
      fn_weapon(inst)
      local planardamage = inst.components.planardamage and inst.components.planardamage.basedamage or 0
      if planardamage and planardamage > 0 then
        set_net(inst, 'damage_more', '+' .. planardamage)
      end
      if inst.components.perishable then
        inst:ListenForEvent('perishchange', fn_weapon)
      end
    end
    if inst.components.temperature then
      local fn_temperature = function(inst)
        set_net(inst, 'temperature', inst.components.temperature and inst.components.temperature.current or TUNING.STARTING_TEMP)
      end
      fn_temperature(inst)
      inst:ListenForEvent('temperaturedelta', fn_temperature)
    end
    if inst.components.finiteuses then
      local fn_finiteuses = function(inst)
        set_net(inst, 'finiteuses', FormatNumber(inst.components.finiteuses:GetUses() or 0, 2) .. '/' .. (inst.components.finiteuses.total or 0))
      end
      fn_finiteuses(inst)
      inst:ListenForEvent('percentusedchange', fn_finiteuses)
    end
  end)

  inst:DoTaskInTime(1, function(inst)
    if not inst:HasOneOfTags({'_health', '_combat', 'weapon', 'heatrock'}) then
      return inst
    end
    ResetBasicName(inst, function(str)
      local name = str
      if inst:HasTag('_health') and not inst:HasTag('smallcreature') then
        local health = get_net(inst, 'health') or 0
        if health > 0 then
          name = name .. '\n󰀍' .. FormatNumber(health, 1)
        end
      end
      if inst:HasOneOfTags('_combat', 'weapon') then
        local damage = get_net(inst, 'damage') or 0
        if damage and damage > 0 then
          name = name .. '\n󰀘' .. FormatNumber(damage, 1)
        end
        local damage_more = get_net(inst, 'damage_more') or nil
        if damage_more and damage_more ~= '' then
          if damage and damage > 0 then
            name = name .. ' (' .. damage_more .. ')'
          else
            name = name .. '\n󰀘' .. damage_more
          end
        end
        local finiteuses = get_net(inst, 'finiteuses')
        if finiteuses and finiteuses ~= '' then
          name = name .. (((damage and damage > 0) or (damage_more and damage_more ~= '')) and ' ' or '\n') .. '󰀏' .. finiteuses
        end
      end
      if inst:HasTag('heatrock') then
        local temperature = get_net(inst, 'temperature') or nil
        if temperature ~= nil then
          name = name .. '\n󰀈' .. FormatNumber(temperature, 1)
        end
      end
      return name
    end)
  end)
end)
