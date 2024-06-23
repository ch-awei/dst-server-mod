if IsClient then return end

local range = GetModConfigData('dragonfly_chest_collect')

local prefab_ignore = {'gift', 'bundle', 'myth_bundle'}
local tags_ignore = {'NOCLICK', 'INLIMBO', 'FX', 'heavy', 'smallcreature', 'lootpump_oncatch', 'lootpump_onflight'}

local function fn(inst)
  local container = inst.components.container
  if container:IsFull() then return end
  local orangeamulet = container:GetItemInSlot(1)
  local finiteuses = orangeamulet and orangeamulet.prefab == 'orangeamulet' and orangeamulet.components.finiteuses or nil
  if not finiteuses then return end

  local target = nil
  for i = 2, container:GetNumSlots() do
    local item = container:GetItemInSlot(i)
    if item and not table.contains(prefab_ignore, item.prefab) then
      target = item.prefab
      break
    end
  end
  if not target then return end

  local x, y, z = inst.Transform:GetWorldPosition()
  local ents = TheSim:FindEntities(x, 0, z, range, {'_inventoryitem'}, tags_ignore)
  for _, v in pairs(ents) do
    if container:IsFull() then return end
    local fuel = finiteuses.current or 0
    if fuel > 0 and v and v.entity:IsValid() and v.entity:IsVisible() and not table.contains(prefab_ignore, v.prefab) and
      v.components.inventoryitem and v.prefab == target then
      local size = v.components.stackable and v.components.stackable.stacksize or 1
      if size >= fuel then
        local nightmarefuel = container:FindItem(function(item)
          return item.prefab == 'nightmarefuel'
        end)
        if nightmarefuel then
          local _fuel = container:RemoveItem(nightmarefuel)
          finiteuses:Repair(_fuel.components.repairer.finiteusesrepairvalue)
          _fuel:Remove()
        else
          return
        end
      end
      finiteuses:Use(size)
      container:GiveItem(v)
    end
  end
end

AddPrefabPostInit('dragonflychest', function(inst)
  if not TheWorld.ismastersim or not inst.components.container then
    return inst
  end
  local _onclosefn = inst.components.container.onclosefn or function()end
  inst.components.container.onclosefn = function(inst, ...)
    inst.task_awei_collect = inst:DoTaskInTime(0, fn)
    return _onclosefn(inst, ...)
  end
  local _onopenfn = inst.components.container.onopenfn or function()end
  inst.components.container.onopenfn = function(inst, ...)
    KillTask(inst.task_awei_collect)
    return _onopenfn(inst, ...)
  end
  local _OnLoad = inst.OnLoad or function()end
  inst.OnLoad = function(inst, ...)
    inst:DoTaskInTime(0, fn)
    return _OnLoad(inst, ...)
  end
end)
