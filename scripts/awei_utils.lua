GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

local IsServer = TheNet and TheNet:GetIsServer()
local IsClient = TheNet and not TheNet:IsDedicated()

function IsEmpty(target)
  return target == nil or target == ""
end

function NotEmpty(target)
  return not IsEmpty(target)
end

-- [[
function SafeGet(target, path, default)
  local success, result = pcall(function()
    for i, key in pairs(string.split(path, '.')) do
      target = target[key]
    end
    return target ~= nil and target or default
  end)
  return success and result or default
end

function HasValues(map, keys)
  local success, result = pcall(function()
    for _, key in pairs(keys) do
      if IsEmpty(map[key]) then
        return false
      end
    end
    return true
  end)
  return success and result or false
end

function HasOneValue(map, keys)
  local success, result = pcall(function()
    for _, key in pairs(keys) do
      if NotEmpty(map[key]) then
        return true
      end
    end
    return false
  end)
  return success and result or false
end -- ]]

--[[
function HasValues(map, keys)
  if type(map) ~= 'table'
    or #map == 0
    or type(keys) ~= 'table'
    or #keys == 0
  then
    return false
  end
  for _, key in pairs(keys) do
    if IsEmpty(map[key]) then
      return false
    end
  end
  return true
end

function HasOneValue(map, keys)
  if type(map) ~= 'table'
    or #map == 0
    or type(keys) ~= 'table'
    or #keys == 0
  then
    return false
  end
  for _, key in pairs(keys) do
    if NotEmpty(map[key]) then
      return true
    end
  end
  return false
end

function SafeGet(target, path, default)
  if IsEmpty(target) or type(path) ~= 'string' then
    return default
  end
  local keys = string.split(path, '.')
  for i, key in pairs(keys)  do
    -- print(key, "==>", type(target) == "table" and target[key] or target)
    if i < #keys and type(target) ~= "table" then
      return default
    end
    if i == #keys and type(target) ~= "table" then
      return target ~= nil and target or default
    end
    target = target[key]
  end
  return target ~= nil and target or default
end -- ]]

function HasOneOfComponents(inst, cs)
  return HasOneValue(inst.components or {}, cs)
end

function KillTask(task)
  if task == nil then return end
  task:Cancel()
  task = nil
end

function IsEndableMods(ids)
  if type(ids) ~= 'table' then
    return KnownModIndex:IsModEnabled('workshop-' .. ids)
  end
  for _, id in pairs(ids) do
    if KnownModIndex:IsModEnabled('workshop-' .. id) then
      return true
    end
  end
  return false
end

GLOBAL['awei_deploy'] = function(param)
  if not ThePlayer then return end
  local x, y, z = ThePlayer.Transform:GetWorldPosition()
  for _, v in pairs(TheSim:FindEntities(x, y, z, 2, nil, {'FX', 'NOCLICK', 'player'})) do
    if v.Physics and (param or not v.components.health) then
      v.Physics:SetActive(false)
    end
    if v.components.deployable ~= nil then
      v.components.deployable:SetDeploySpacing(DEPLOYSPACING.NONE)
    end
  end
end

if IsClient then
  AddClientModRPCHandler('AWEI_SERVER_MOD', 'DEPLOY_ANYWHERE', awei_place)
end
if IsServer then
  AddClientModRPCHandler('AWEI_SERVER_MOD', 'DEPLOY_ANYWHERE', function(params)
  end)
end
GLOBAL['awei_place'] = function(param)
  param = param or 0
  for _, v in pairs(AllRecipes) do
    if v.min_spacing and v.min_spacing ~= param then
      v.min_spacing = param
    end
  end
  if IsServer and TheNet:GetUserID() ~= nil then
    SendModRPCToClient(CLIENT_MOD_RPC.AWEI_SERVER_MOD.DEPLOY_ANYWHERE, TheNet:GetUserID(), param)
  end
end

function FormatNumber(num, n)
  local int, f = math.modf(num)
  if not n then return math.ceil(num) end
  if n < 2 and f < 0.1 then return int end
  return int + tonumber(string.format('%.' .. n .. 'f', f))
end

function ResetBasicName(inst, fn_rename)
  local _name = type(inst.GetBasicDisplayName) == 'function' and inst:GetBasicDisplayName() or nil
  if type(fn_rename) ~= 'function' or type(_name) ~= 'string' or string.find(_name, 'MISSING NAME') then
    return
  end
  inst.GetBasicDisplayName = function()
    return fn_rename(_name) or _name
  end
end
