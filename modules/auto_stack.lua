if IsClient then return end

local cfg = GetModConfigData('auto_stack')
local range = type(cfg) == 'number' and cfg or 5
local all_autostack = GetModConfigData('all_autostack')

local tags_ignore = {'not_autostack', 'NOCLICK', 'INLIMBO', 'FX', 'heavy', 'smallcreature', 'lootpump_oncatch', 'lootpump_onflight'}
local prefabs_ignore = {'seeds', 'firecrackers'}

AddComponentPostInit('stackable', function(self, inst)
  if inst:HasOneOfTags(tags_ignore) or table.contains(prefabs_ignore, inst.prefab) then
    return
  end
  if not all_autostack and GetTime() < 1 then
    return inst:AddTag('not_autostack')
  end
  inst.task_awei_autostack = inst:DoTaskInTime(0, function(inst)
    if inst:HasOneOfTags(tags_ignore) then return end
    if inst:IsValid() and not self:IsFull() then
      local x, y, z = inst.Transform:GetWorldPosition()
      local ents = TheSim:FindEntities(x, 0, z, range, {'_stackable'}, tags_ignore)
      for _, item in ipairs(ents) do
        if item:IsValid() and item.components.stackable and not item.components.stackable:IsFull() and
          item.prefab == inst.prefab and item ~= inst and item.skinname == inst.skinname then
          if #ents < 20 then
            SpawnPrefab('sand_puff').Transform:SetPosition(item.Transform:GetWorldPosition())
          end
          self:Put(item)
        end
      end
    end
  end)
  local _Get = self.Get
  self.Get = function(self, ...)
    local inst = _Get(self, ...)
    KillTask(inst.task_awei_autostack)
    return inst
  end
end)
