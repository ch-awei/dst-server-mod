local function onname(self, name)
  self.inst._name:set(tostring(name))
end
local Packfull = Class(function(self, inst)
  self.inst = inst
  self.canpackfn = nil
  self.package = nil
  self.name = nil
end, nil, {
  name = onname
})

function Packfull:HasPackage()
  return self.package ~= nil
end

function Packfull:DefaultCanPackTest(target)
  return SEAL_LAMP_PACKTEST(self.inst, target)
end

function Packfull:CanPack(target)
  return self.inst:IsValid() and not self:HasPackage()
end

local function get_name(target)
  local name = target:GetDisplayName() or (target.components.named and target.components.named.name)
  if not name or name == 'MISSING NAME' then
    return
  end
  local adj = target:GetAdjective()
  if adj then
    name = adj .. ' ' .. name
  end
  if target.components.stackable then
    local size = target.components.stackable:StackSize()
    if size > 1 then
      name = name .. ' x' .. tostring(size)
    end
  end
  return name
end

function Packfull:Pack(target)
  self.package = {
    prefab1 = target:GetSaveRecord()
  }
  if target.components.teleporter and target.components.teleporter.targetTeleporter then
    self.package.prefab2 = target.components.teleporter.targetTeleporter:GetSaveRecord()
    target.components.teleporter.targetTeleporter:Remove()
  end
  self.name = get_name(target)
  target:Remove()
  return true
end

function Packfull:Unpack(pos)
  if self.package ~= nil and self.package.prefab1 ~= nil then
    local target = SpawnSaveRecord(self.package.prefab1)
    if target ~= nil and target:IsValid() then
      if target.Physics ~= nil then
        target.Physics:Teleport(pos:Get())
      else
        target.Transform:SetPosition(pos:Get())
      end
      if target.components.inventoryitem ~= nil then
        target.components.inventoryitem:OnDropped(true, .5)
      end
      SpawnPrefab('seal_lamp_fx').Transform:SetPosition(pos:Get())
    end
    if self.package.prefab2 then
      local prefab2 = SpawnSaveRecord(self.package.prefab2)
      if prefab2 and target.components.teleporter and prefab2.components.teleporter then
        prefab2.components.teleporter:Target(target)
        target.components.teleporter:Target(prefab2)
      end
    end
  end
end

function Packfull:OnSave()
  if self.package then
    return {
      package = self.package,
      name = self.name
    }
  end
end

function Packfull:OnLoad(data)
  if not data then return end
  for i, k in ipairs({'package', 'name'}) do
    if data[k] then
      self[k] = data[k]
    end
  end
end

return Packfull
