GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

local NetMap = require("util/net_map")
local KEY_NET = NetMap.key or KEY_NET_MAP

local ignore_mods = {"666155465", "2189004162"}
local ignore_tags = {"NOCLICK", "INLIMBO", "FX"}

local function RegisterEventListeners(inst)
  if not inst.components.container then return end

  local function fn(target)
    local success, result = pcall(function()
      if target.components.container:IsEmpty() then return "" end
      local items = target.components.container:GetAllItems()
      local prefabs = {}
      for i, item in ipairs(items) do
        local prefab = item.prefab or nil
        if NotEmpty(prefab) and not table.contains(prefabs, prefab) then
          table.insert(prefabs, prefab)
        end
      end
      return #prefabs > 0 and table.concat(prefabs, ";") or ""
    end)
    if success then
      inst[KEY_NET]:Set("container_content", result)
    end
  end

  inst:ListenForEvent("dropitem", fn)
  inst:ListenForEvent("itemget", fn)
  inst:ListenForEvent("itemlose", fn)
end

AddPrefabPostInitAny(function(inst)
  if IsEndableMods(ignore_mods)
    or not inst
    or not inst:IsValid()
    or inst:HasOneOfTags(ignore_tags)
  then return end

  if not inst[KEY_NET] then
    inst[KEY_NET] = NetMap(inst, KEY_NET)
  end
  inst[KEY_NET]:Add("container_content")

  if TheWorld.ismastersim then
    inst:DoTaskInTime(0, RegisterEventListeners)
  end
end)

local function HandleLight(inst, light)
  if not inst.AnimState then return end

  inst.AnimState:SetAddColour(0, light, 0, 1)
  KillTask(inst.task_finder_clear)
  if light ~= 0 then
    inst.task_finder_clear = inst:DoTaskInTime(1, function()
      inst.AnimState:SetAddColour(0, 0, 0, 0)
    end)
  end
end

local function HandleFind(prefab)
  local success, result = pcall(function()
    local x, y, z = ThePlayer.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, prefab and 50 or 100, nil, ignore_tags)
    for i, ent in ipairs(ents) do
      if not prefab then
        HandleLight(ent, 0)
      elseif ent:HasTag("_container") then
        local content = ent[KEY_NET]:Get("container_content") or ""
        HandleLight(ent, string.find(content, prefab) and 0.3 or 0)
        -- HandleLight(ent, ent.replica.container:Has(prefab, 1) and 0.3 or 0)
      elseif ent:HasTag("_inventoryitem") then
        HandleLight(ent, ent.prefab == prefab and 0.1 or 0)
      end
    end
  end)
end

AddPrefabPostInit("inventory_classified", function(inst)
  if IsEndableMods(ignore_mods) or IS_SERVER then return end
  inst:ListenForEvent("activedirty", function(target)
    local _active = target._active:value()
    local prefab = _active and _active.prefab or nil
    KillTask(target.task_finder)
    if prefab then
      HandleFind(prefab)
      target.task_finder = target:DoPeriodicTask(0.5, function()
        HandleFind(prefab)
      end)
    else
      HandleFind()
    end
  end)
end)

local ingredientui = require("widgets/ingredientui")
local _OnGainFocus = ingredientui.OnGainFocus or function()end
function ingredientui:OnGainFocus(...)
  if IsEndableMods(ignore_mods) then
    return _OnGainFocus(self, ...)
  end
  local target = self.ing and self.ing.texture
  local prefab = type(target) == "string" and target:match("[^/]+$"):gsub("%.tex$", "") or nil
  HandleFind(prefab)
  return _OnGainFocus(self, ...)
end
