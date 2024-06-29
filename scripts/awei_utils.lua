GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

IsServer = TheNet and TheNet:GetIsServer()
IsClient = TheNet and not TheNet:IsDedicated()

function KillTask(task)
  if task == nil then return end
  task:Cancel()
  task = nil
end

function EndableOneOfMods(ids)
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

function SpiceCaneat(spices)
  for spice, data in pairs(spices) do
    AddPrefabPostInit(spice, function(inst)
      if not TheWorld.ismastersim or inst.components.edible ~= nil then return end
      local edible = inst:AddComponent("edible")
      edible.foodtype = FOODTYPE.GOODIES
      edible.healthvalue = data.healthvalue or TUNING.HEALING_TINY
      edible.sanityvalue = data.sanityvalue or TUNING.SANITY_SUPERTINY
      if type(data.oneatenfn) == 'function' then
        local _oneatenfn = edible.oneaten or function()end
        inst.components.edible.oneaten = function(inst, eater)
          _oneatenfn(inst, eater)
          data.oneatenfn(inst, eater)
        end
      end
    end)
  end
end

AddPlayerPostInit(function(inst)
  if not TheWorld.ismastersim then return end
  inst:AddTag('compassbearer')
  inst:AddTag('maprevealer')
  inst:AddComponent('maprevealer')
  if inst.components.maprevealable ~= nil then
    inst.components.maprevealable:AddRevealSource(inst, 'compassbearer')
  end
end)

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

function SetNumberFormat(num, n)
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
