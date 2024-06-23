local AutoPlant = Class(function(self, inst)
  assert(inst.components.container ~= nil, 'AutoPlant requires the Container component')
  self.inst = inst
  self.repeat_plant_delay = TUNING.AUTOTERRAFORMER_REPEAT_DELAY
  self.container = inst.components.container
end)

function AutoPlant:FinishPlat()
  if self.onfinishplantfn ~= nil then
    self.onfinishplantfn(self.inst)
  end
end

local function getPoints(_type, _x, _z)
  if type(_x) ~= 'number' or type(_z) ~= 'number' then
    return nil
  end
  local points
  if _type == 'tree' then
    points = {
      { x = _x - 1, z = _z - 1 },
      { x = _x + 1, z = _z - 1 },
      { x = _x - 1, z = _z + 1 },
      { x = _x + 1, z = _z + 1 }
    }
  elseif _type == 'farmplant' then
    local spacing = 4 / 3
    points = {
      { x = _x - spacing, z = _z - spacing },
      { x = _x, z = _z - spacing },
      { x = _x + spacing, z = _z - spacing },
      { x = _x - spacing, z = _z },
      { x = _x, z = _z },
      { x = _x + spacing, z = _z },
      { x = _x - spacing, z = _z + spacing },
      { x = _x, z = _z + spacing },
      { x = _x + spacing, z = _z + spacing }
    }
  end
  return points
end

function AutoPlant:autoReplenish(_prefab, flag)
  if not self.container:IsEmpty() then
    return false
  end
  local inventory = self.owner.components.inventory
  if not inventory then
    return false
  end
  local find = function(item)
    return item.prefab == _prefab
  end
  local inv_item, c_item
  local _inv_item = inventory:FindItem(find)
  if _inv_item then
    inv_item = inventory:RemoveItemBySlot(inventory:GetItemSlot(_inv_item))
  end
  if not inv_item then
    for c, _ in pairs(inventory.opencontainers or self.owner.replica.inventory:GetOpenContainers() or {}) do
      local _container = c and c.components.container or nil
      if _container and _container ~= self.container then
        local _c_item = _container:FindItem(find)
        if _c_item then
          c_item = _container:RemoveItemBySlot(_container:GetItemSlot(_c_item))
        end
        if c_item then
          break
        end
      end
    end
  end
  local replenishment = inv_item or c_item or nil
  if replenishment and self.container:GiveItem(replenishment) then
    if flag then
      return true, self:DoPlant()
    else
      return true
    end
  end
  return false
end

function AutoPlant:DoPlant()
  local item = self.container:GetItemInSlot(1)
  if not item then
    return false
  end

  local plant_num = 0

  local points = getPoints(item:HasTag('deployedfarmplant') and 'farmplant' or 'tree', self.last_x, self.last_z)
  if type(points) ~= 'table' then
    return false
  end
  if not self._has_plantkin then
    self.owner:AddTag('plantkin')
  end
  local _prefab = item.prefab
  for i, point in ipairs(points) do
    local pt = Vector3(point.x, 0, point.z)
    local _item = self.container:GetItemInSlot(1)
    if not _item then
      local has_item, result = self:autoReplenish(_prefab, true)
      if has_item then
        return result
      else
        break
      end
    elseif _item.components.deployable:CanDeploy(pt, nil, self.owner, 0) then
      local _plant = self.container:RemoveItem(_item)
      local result = _plant.components.deployable:Deploy(pt, self.owner)
      if result then
        plant_num = plant_num + 1
        self:FinishPlat()
      else
        self.container:GiveItem(_plant)
      end
    end
  end
  if not self._has_plantkin then
    self.owner:RemoveTag('plantkin')
  end
  if self.container:IsEmpty() then
    self:autoReplenish(_prefab)
  end
  return plant_num ~= 0
end

function AutoPlant:StartPlanting()
  self.last_x, self.last_z, self.repeat_delay = nil, nil, nil
  self.owner = self.inst.components.inventoryitem:GetGrandOwner()
  self._has_plantkin = self.owner:HasTag('plantkin')
  self.inst:StartUpdatingComponent(self)
end

function AutoPlant:StopPlanting()
  self.inst:StopUpdatingComponent(self)
end

function AutoPlant:OnUpdate(dt)
  local px, py, pz = self.inst.Transform:GetWorldPosition()
  local x, y, z = TheWorld.Map:GetTileCenterPoint(px, py, pz)

  if self.repeat_delay ~= nil then
    self.repeat_delay = math.max(self.repeat_delay - dt, 0)
  end

  if (self.last_x == nil and self.last_z == nil) or (self.last_x ~= x or self.last_z ~= z) or
    (self.last_x == x and self.last_z == z and self.repeat_delay == 0) then
    self.last_x, self.last_z = x, z

    self.repeat_delay = nil
    local repeat_plant = self:DoPlant()
    if repeat_plant then
      self.repeat_delay = self.repeat_plant_delay
    end
  end
end

return AutoPlant
