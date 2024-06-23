GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

local containers = require('containers')
containers.params['nutrientsgoggleshat'] = {
  widget = {
    slotpos = {Vector3(0, 2, 0)},
    animbank = 'ui_antlionhat_1x1',
    animbuild = 'ui_antlionhat_1x1',
    pos = Vector3(106, 40, 0)
  },
  usespecificslotsforitems = true,
  type = 'hand_inv',
  excludefromcrafting = true,
  itemtestfn = function(container, item, slot)
    return item:HasTag('deployable') and item:HasOneOfTags({'treeseed', 'deployedfarmplant'})
  end
}

AddPrefabPostInit('nutrientsgoggleshat', function(inst)
  inst:AddTag('turfhat')
  if not TheWorld.ismastersim then return end
  if inst.components.container ~= nil then return end
  inst:AddComponent("container")
  inst.components.container:WidgetSetup(inst.prefab)
  inst.components.container.canbeopened = false
  inst:AddComponent("autoplant")
  local _equip = inst.components.equippable.onequipfn or function()end
  inst.components.equippable:SetOnEquip(function(inst, owner)
    _equip(inst, owner)
    if inst.components.autoplant ~= nil and owner.components.locomotor ~= nil then
      inst.components.autoplant:StartPlanting()
    end
    if inst.components.container ~= nil then
      inst.components.container:Open(owner)
    end
  end)
  local _unequip = inst.components.equippable.onunequipfn or function()end
  inst.components.equippable:SetOnUnequip(function(inst, owner)
    _unequip(inst, owner)
    if inst.components.autoplant ~= nil then
      inst.components.autoplant:StopPlanting()
    end
    if inst.components.container ~= nil then
      inst.components.container:Close()
    end
  end)
end)
