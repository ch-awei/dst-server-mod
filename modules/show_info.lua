GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

local NetMap = require("util/net_map")
local KEY_NET = NetMap.key or KEY_NET_MAP

local RegisterEventListeners = function(inst)
  local cs = inst and inst.components or nil

  if not inst or not inst:IsValid() or not cs then
    return inst
  end

  if cs.combat and cs.health then
    local fn_health = function(target)
      inst[KEY_NET]:Set("health", FormatNumber(SafeGet(target, "components.health.currenthealth", 0), 1))
    end
    fn_health(inst)
    inst:ListenForEvent("healthdelta", fn_health)
    local damage = FormatNumber(SafeGet(cs.combat, "defaultdamage", 0), 2)
    if damage > 0 then
      local percent = FormatNumber(SafeGet(cs.combat, "playerdamagepercent", 0), 2)
      if percent > 0 then
        damage = damage .. " (" .. FormatNumber(percent * 100, 2) .. "%)"
      end
      inst[KEY_NET]:Set("damage", tostring(damage))
    end
  end
  
  if cs.heater and cs.temperature then
    local fn_temperature = function(target)
      inst[KEY_NET]:Set("temperature", FormatNumber(SafeGet(target, "components.temperature.current", TUNING.STARTING_TEMP), 2))
    end
    fn_temperature(inst)
    inst:ListenForEvent("temperaturedelta", fn_temperature)
  end
  
  if cs.unwrappable then
    local content_info = {}
    local bundle_items = cs.unwrappable.itemdata
    
    if type(bundle_items) == "table" and #bundle_items > 0 then
      for key, item in ipairs(bundle_items) do
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
      inst[KEY_NET]:Set("bundle_content", table.concat(content_info, "\n"))
    end
  end
end

local GenerateDisplayText = function(inst, base_name)
  local name = base_name
  
  if inst:HasTag("_health") and not inst:HasTag("smallcreature") then
    local health = inst[KEY_NET]:Get("health")
    if NotEmpty(health) and health > 0 then
      name = name .. "\n󰀍" .. FormatNumber(health, 1)
    end
  end
  
  if inst:HasTag("_combat") then
    local damage = inst[KEY_NET]:Get("damage")
    if NotEmpty(damage) then
      name = name .. "\n󰀘" .. damage
    end
  end
  
  if inst:HasTag("heatrock") then
    local temperature = inst[KEY_NET]:Get("temperature")
    if NotEmpty(temperature) then
      name = name .. "\n󰀈" .. FormatNumber(temperature, 1)
    end
  end
  
  if inst:HasTag("unwrappable") then
    local bundle_content = inst[KEY_NET]:Get("bundle_content")
    if NotEmpty(bundle_content) then
      name = name .. "\n" .. bundle_content
    end
  end
  
  return name
end

AddPrefabPostInitAny(function(inst)
  if IsEndableMods({"666155465", "2189004162"})
    or inst:HasOneOfTags({"NOCLICK", "FX"})
    or not inst:IsValid()
  then return inst end

  if not inst[KEY_NET] then
    inst[KEY_NET] = NetMap(inst, KEY_NET)
  end
  inst[KEY_NET]:AddByMap({
    health = net_float,
    damage = net_string,
    temperature = net_float,
    bundle_content = net_string,
  })

  inst:DoTaskInTime(0, RegisterEventListeners)

  inst:DoTaskInTime(0.5, function(inst)
    if inst:HasOneOfTags({"_health", "_combat", "heatrock", "unwrappable"}) then
      ResetBasicName(inst, function(str)
        return GenerateDisplayText(inst, str)
      end)
    end
  end)
end)
