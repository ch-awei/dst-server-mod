AddPrefabPostInit("eyeturret", function(inst)
  if not inst.components.machine then
    inst:AddComponent("machine")
  end
  inst.components.machine.turnonfn = function(inst)
    inst.on = true
    inst:Remove()
    GLOBAL.SpawnPrefab("eyeturret_item").Transform:SetPosition(inst.Transform:GetWorldPosition())
  end

  if inst and inst.components and inst.components.lootdropper then
    inst.components.lootdropper:AddRandomLoot("eyeturret_item", 1)
    inst.components.lootdropper.numrandomloot = 1
  end
end)
