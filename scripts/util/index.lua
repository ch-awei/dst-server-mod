GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

IS_SERVER = TheNet and TheNet:GetIsServer()
SPACE_NAME = modname or "awei-server-mod"
KEY_NET_MAP = SPACE_NAME .. "_net-map"

function IsEmpty(target)
  return target == nil or target == ""
end

function NotEmpty(target)
  return not IsEmpty(target)
end

function SafeGet(target, path, default)
  local success, result = pcall(function()
    for i, key in ipairs(string.split(path, ".")) do
      target = target[key]
    end
    return target ~= nil and target or default
  end)
  return success and result or default
end

function FormatNumber(num, n)
  local success, result = pcall(function()
    local int, f = math.modf(num)
    if not n then return math.ceil(num) end
    if n < 2 and f < 0.1 then return int end
    return int + tonumber(string.format("%." .. n .. "f", f))
  end)
  return success and result or num
end

function MapHasAllValue(map, keys)
  local success, result = pcall(function()
    for i, key in ipairs(keys) do
      if IsEmpty(map[key]) then
        return false
      end
    end
    return true
  end)
  return success and result or false
end

function MapHasOneValue(map, keys)
  local success, result = pcall(function()
    for i, key in ipairs(keys) do
      if NotEmpty(map[key]) then
        return true
      end
    end
    return false
  end)
  return success and result or false
end

function HasOneOfComponents(inst, cs)
  return MapHasOneValue(inst.components or {}, cs)
end

function KillTask(task)
  return pcall(function()
    task:Cancel()
    task = nil
  end)
end

function IsEndableMods(ids)
  local success, result = pcall(function()
    if type(ids) ~= "table" then
      return KnownModIndex:IsModEnabled("workshop-" .. ids)
    end
    for i, id in ipairs(ids) do
      if KnownModIndex:IsModEnabled("workshop-" .. id) then
        return true
      end
    end
    return false
  end)
  return success and result or false
end

function ResetBasicName(inst, fn_rename)
  local _name = type(inst.GetBasicDisplayName) == "function" and inst:GetBasicDisplayName() or nil
  if type(fn_rename) ~= "function" or type(_name) ~= "string" or string.find(_name, "MISSING NAME") then
    return
  end
  inst.GetBasicDisplayName = function()
    return fn_rename(_name) or _name
  end
end

GLOBAL["deploy_anywhere"] = function(param)
  if not ThePlayer then return end
  local x, y, z = ThePlayer.Transform:GetWorldPosition()
  for i, v in ipairs(TheSim:FindEntities(x, y, z, 2, {"deployable"}, {"FX", "NOCLICK", "player"})) do
    if v.Physics and (param or not v.components.health) then
      v.Physics:SetActive(false)
    end
    if v.components.deployable ~= nil then
      v.components.deployable:SetDeploySpacing(DEPLOYSPACING.NONE)
    end
  end
end
GLOBAL["place_anywhere"] = function(param)
  param = param or 0
  for k, v in pairs(AllRecipes) do
    if v.build_distance and v.build_distance ~= param then
      AllRecipes[k].build_distance = param
    end
    if v.min_spacing and v.min_spacing ~= param then
      AllRecipes[k].min_spacing = param
    end
  end
  if IS_SERVER and TheNet:GetUserID() ~= nil then
    SendModRPCToClient(CLIENT_MOD_RPC[SPACE_NAME].DEPLOY_ANYWHERE, TheNet:GetUserID(), param)
  end
end
AddClientModRPCHandler(SPACE_NAME, "DEPLOY_ANYWHERE", place_anywhere)
