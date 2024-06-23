local assets = {
  Asset('ANIM', 'anim/seal_lamp.zip'),
  Asset('ATLAS', 'images/seal_lamp.xml'),
  Asset('IMAGE', 'images/seal_lamp.tex'),
  Asset('ATLAS', 'images/seal_lamp_full.xml'),
  Asset('IMAGE', 'images/seal_lamp_full.tex')
}

local function ondeploy(inst, pt, deployer)
  if inst.components.packfull then
    inst.components.packfull:Unpack(pt)
    inst:Remove()
  end
end

local function get_name(inst)
  return #inst._name:value() > 0 and '受缚混沌：' .. inst._name:value() or STRINGS.SEALLAMPFULL
end

local function fn()
  local inst = CreateEntity()

  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddSoundEmitter()
  inst.entity:AddNetwork()

  MakeInventoryPhysics(inst)

  inst.AnimState:SetBank('seal_lamp')
  inst.AnimState:SetBuild('seal_lamp')
  inst.AnimState:PlayAnimation('idle')

  inst:AddTag('seal_lamp')

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  inst:AddComponent('inspectable')

  inst:AddComponent('packlamp')

  inst:AddComponent('inventoryitem')
  inst.components.inventoryitem.atlasname = 'images/seal_lamp.xml'

  MakeMediumPropagator(inst)

  return inst
end

local function fullfn()
  local inst = CreateEntity()

  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddSoundEmitter()
  inst.entity:AddNetwork()

  MakeInventoryPhysics(inst)

  inst.AnimState:SetBank('seal_lamp')
  inst.AnimState:SetBuild('seal_lamp')
  inst.AnimState:PlayAnimation('full')

  inst:AddTag('seal_lamp_full')
  inst:AddTag('nopackable')

  inst._name = net_string(inst.GUID, 'seal_lamp_full._name')

  inst.displaynamefn = get_name

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  inst:AddComponent('inspectable')

  inst:AddComponent('packfull')

  inst:AddComponent('deployable')
  inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.NONE)
  inst.components.deployable.ondeploy = ondeploy

  inst:AddComponent('inventoryitem')
  inst.components.inventoryitem.atlasname = 'images/seal_lamp_full.xml'

  MakeMediumPropagator(inst)
  MakeHauntableLaunchAndSmash(inst)

  return inst
end

local function buildfullfn()
  local inst = CreateEntity()

  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddSoundEmitter()
  inst.entity:AddNetwork()

  MakeInventoryPhysics(inst)

  inst.AnimState:SetBank('seal_lamp')
  inst.AnimState:SetBuild('seal_lamp')
  inst.AnimState:PlayAnimation('full')

  inst:AddTag('seal_lamp_full')
  inst:AddTag('nopackable')

  inst._name = net_string(inst.GUID, 'seal_lamp_build._name')

  inst.displaynamefn = get_name

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  inst:AddComponent('inspectable')

  inst:AddComponent('packfull')

  inst:AddComponent('deployable')
  inst.components.deployable.ondeploy = ondeploy

  inst:AddComponent('inventoryitem')
  inst.components.inventoryitem.atlasname = 'images/seal_lamp_full.xml'

  MakeHauntableLaunchAndSmash(inst)

  MakeMediumPropagator(inst)

  return inst
end

return Prefab('seal_lamp', fn, assets), Prefab('seal_lamp_full', fullfn, assets),
  Prefab('seal_lamp_buildfull', buildfullfn, assets),
  MakePlacer('seal_lamp_full_placer', 'seal_lamp_full', 'seal_lamp_full', 'place'),
  MakePlacer('seal_lamp_buildfull_placer', 'seal_lamp_full', 'seal_lamp_full', 'place')
