for _, prefab in pairs({'pondeel', 'pondfish'}) do
  AddPrefabPostInit(prefab, function(inst)
    if not TheWorld.ismastersim then return end
    if not inst.components.stackable then
      inst:AddComponent('stackable')
      if GetModConfigData('fish_stack') then
        inst.components.stackable.maxsize = TUNING['STACK_SIZE_' .. GetModConfigData('fish_stack')]
      end
    end
  end)
end
