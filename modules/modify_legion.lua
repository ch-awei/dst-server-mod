for _, v in pairs({'rose', 'lily', 'orchid'}) do
  AddPrefabPostInit('petals_' .. v, function(inst)
    if not TheWorld.ismastersim then return end
    if not inst:HasTag('saltbox_valid') then
      inst:AddTag('saltbox_valid')
    end
  end)
end
