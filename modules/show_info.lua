GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

local SetNet = function(inst, key, value)
  if inst.NET_MAP[key] ~= nil then
    inst.NET_MAP[key]:set(value)
  end
end

local GetNet = function(inst, key)
  if inst.NET_MAP[key] ~= nil then
    return inst.NET_MAP[key]:value() or nil
  end
  return nil
end

local RegisterEventListeners = function(inst)
  local cs = inst and inst.components or nil

  if not inst or not inst:IsValid() or not cs then
    return inst
  end

  if cs.health then
    local fn_health = function(target)
      SetNet(target, "health", FormatNumber(SafeGet(target, "components.health.currenthealth", 0), 1))
    end
    fn_health(inst)
    inst:ListenForEvent("healthdelta", fn_health)
  end
  
  if cs.combat then
    SetNet(inst, "damage", FormatNumber(SafeGet(cs.combat, "defaultdamage", 0), 2))
    local percent = FormatNumber(SafeGet(cs.combat, "playerdamagepercent", 0), 2)
    if percent > 0 then
      SetNet(inst, "damage_more", FormatNumber(percent * 100, 2) .. "%")
    end
  end
  
  if cs.temperature then
    local fn_temperature = function(target)
      SetNet(target, "temperature", FormatNumber(SafeGet(target, "components.temperature.current", TUNING.STARTING_TEMP), 2))
    end
    fn_temperature(inst)
    inst:ListenForEvent("temperaturedelta", fn_temperature)
  end
  
  if cs.unwrappable then
    local content_info = {}
    local bundle_items = cs.unwrappable.itemdata
    
    if type(bundle_items) == "table" and #bundle_items > 0 then
      for key, item in pairs(bundle_items) do
        local item_name = STRINGS.NAMES[string.upper(item.prefab)] or item.prefab
        local data = item.data or item
        local stack_size = SafeGet(data, "stackable.stack", 1)
        -- 新鲜度
        local perishable_time = SafeGet(data, "perishable.time", 0)
        if perishable_time > 0 then
          item_name = item_name
            .. (stack_size > 1 and " (" or " ")
            .. FormatNumber(perishable_time / TUNING.TOTAL_DAY_TIME, 1)
            .. "d"
            .. (stack_size > 1 and ")" or "")
        end
        -- 耐久度
        local finiteuses_uses = SafeGet(data, "finiteuses.uses", 0)
        if finiteuses_uses > 0 then
          item_name = item_name .. " 󰀏" .. FormatNumber(finiteuses_uses, 1)
        end
        -- 温度
        local temperature_current = SafeGet(data, "temperature.current")
        if temperature_current ~= nil then
          item_name = item_name .. " 󰀈" .. FormatNumber(temperature_current, 1)
        end
        -- 堆叠数量
        if stack_size > 1 then
          item_name = item_name .. " x " .. stack_size
        end

        table.insert(content_info, item_name)
      end
    end
    
    if #content_info > 0 then
      SetNet(inst, "bundle", table.concat(content_info, "\n"))
    end
  end
end

local GenerateDisplayText = function(inst, base_name)
  local name = base_name
  
  if inst:HasTag("_health") and not inst:HasTag("smallcreature") then
    local health = GetNet(inst, "health")
    if NotEmpty(health) and health > 0 then
      name = name .. "\n󰀍" .. FormatNumber(health, 1)
    end
  end
  
  if inst:HasTag("_combat") then
    local damage = GetNet(inst, "damage")
    if NotEmpty(damage) and damage > 0 then
      name = name .. "\n󰀘" .. FormatNumber(damage, 1)
      
      local damage_more = GetNet(inst, "damage_more")
      if NotEmpty(damage_more) then
        name = name .. " (" .. damage_more .. ")"
      end
    end
  end
  
  if inst:HasTag("heatrock") then
    local temperature = GetNet(inst, "temperature")
    if NotEmpty(temperature) then
      name = name .. "\n󰀈" .. FormatNumber(temperature, 1)
    end
  end
  
  if inst:HasTag("unwrappable") then
    local bundle_content = GetNet(inst, "bundle")
    if NotEmpty(bundle_content) then
      name = name .. "\n" .. bundle_content
    end
  end
  
  return name
end

local NotInit = function(inst)
  return IsEndableMods({"666155465", "2189004162"})
    or inst:HasOneOfTags({"NOCLICK", "FX"})
    or not inst:IsValid()
    -- or not (
    --   HasOneOfComponents(inst, {"health", "combat", "temperature", "unwrappable"})
    --   or inst:HasOneOfTags({"_health", "_combat", "heatrock", "unwrappable"})
    -- )
end

AddPrefabPostInitAny(function(inst)
  if NotInit(inst) then return inst end

  inst.NET_MAP = {
    health = net_float(inst.GUID, "NET_CHANGE_health"),
    damage = net_float(inst.GUID, "NET_CHANGE_damage"),
    damage_more = net_string(inst.GUID, "NET_CHANGE_damage_more"),
    temperature = net_float(inst.GUID, "NET_CHANGE_temperature"),
    bundle = net_string(inst.GUID, "NET_CHANGE_bundle")
  }

  inst:DoTaskInTime(0, RegisterEventListeners)

  inst:DoTaskInTime(0.5, function(inst)
    if inst:HasOneOfTags({"_health", "_combat", "heatrock", "unwrappable"}) then
      ResetBasicName(inst, function(str)
        return GenerateDisplayText(inst, str)
      end)
    end
  end)
end)
