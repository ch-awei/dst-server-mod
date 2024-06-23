GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

local mod_ids = {'666155465', '2189004162'}
local tags_ignore = {'NOCLICK', 'INLIMBO', 'FX'}

AddPrefabPostInitAny(function(inst)
  if EndableOneOfMods(mod_ids) or inst:HasOneOfTags(tags_ignore) then return end
  inst.net_awei_finder = net_string(inst.GUID, 'awei_finder', 'awei_finder_dirty')
  inst.net_awei_finder:set('')
  if not TheWorld.ismastersim then
    inst:ListenForEvent('awei_finder_dirty', function(inst)
      local uid = ThePlayer and ThePlayer.userid
      if not inst.AnimState or not uid then
        return
      end
      local str = inst.net_awei_finder:value()
      inst.AnimState:SetAddColour(0, #str >= #uid and string.find(str, uid) and 0.3 or 0, 0, 1)
    end)
  end
end)

local function SetNet(inst, data)
  if not inst.net_awei_finder then return end
  inst.net_awei_finder:set(data)
end
AddModRPCHandler('AWEI_SERVER_MOD', 'FINDER', function(player, prefab)
  local x, y, z = player.Transform:GetWorldPosition()
  local ents = TheSim:FindEntities(x, y, z, prefab and 50 or 100, {'_container'}, tags_ignore)
  for _, inst in pairs(ents) do
    local str = inst.net_awei_finder:value()
    local uid = player.userid .. ';'
    local has = string.find(str, uid)
    if prefab and inst.components.container and inst.components.container:Has(prefab, 1) then
      if not has then
        SetNet(inst, #str > 0 and (str .. uid) or uid)
      end
    elseif #str > 0 and has then
      SetNet(inst, string.gsub(str, uid, ''))
    end
  end
end)

if IsServer then return end

local function SendRPC(inst, prefab, autoclear)
  if not inst or table.contains({'gift', 'bundle'}, prefab) then
    return
  end
  KillTask(inst.task_awei_finder)
  if prefab then
    SendModRPCToServer(MOD_RPC.AWEI_SERVER_MOD.FINDER, prefab)
    inst.task_awei_finder = inst:DoPeriodicTask(1, function(inst)
      SendModRPCToServer(MOD_RPC.AWEI_SERVER_MOD.FINDER)
      SendModRPCToServer(MOD_RPC.AWEI_SERVER_MOD.FINDER, prefab)
    end)
    if autoclear then
      KillTask(inst.task_awei_autoclear)
      inst.task_awei_autoclear = inst:DoTaskInTime(1, function()
        KillTask(inst.task_awei_finder)
        SendModRPCToServer(MOD_RPC.AWEI_SERVER_MOD.FINDER)
      end)
    end
  else
    SendModRPCToServer(MOD_RPC.AWEI_SERVER_MOD.FINDER)
  end
end

AddPrefabPostInit('inventory_classified', function(inst)
  if EndableOneOfMods(mod_ids) then return end
  inst:ListenForEvent('activedirty', function(inst)
    local _active = inst._active:value()
    SendRPC(inst, _active and _active.prefab or nil)
  end)
end)

local ingredientui = require('widgets/ingredientui')
local _OnGainFocus = ingredientui.OnGainFocus or function()end
function ingredientui:OnGainFocus(...)
  if EndableOneOfMods(mod_ids) then
    return _OnGainFocus(self, ...)
  end
  local prefab = self.ing and self.ing.texture and self.ing.texture:match('[^/]+$'):gsub('%.tex$', '') or nil
  local player = self.parent and self.parent.parent and self.parent.parent.owner
  if player ~= nil then SendRPC(player, prefab, true) end
  return _OnGainFocus(self, ...)
end
