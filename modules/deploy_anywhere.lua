GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

local cfg = GetModConfigData("deploy_anywhere") or 0

if table.contains({1, 3}, cfg) then
  for _, v in pairs(AllRecipes) do
    if v.min_spacing and v.min_spacing > 0 then
      v.min_spacing = 0
    end
  end
end

AddPrefabPostInitAny(function(inst)
  if table.contains({2, 3}, cfg) and inst.components.deployable ~= nil and inst.components.deployable.mode ~= DEPLOYMODE.CUSTOM
    and not inst.components.fertilizer and not inst:HasTag('boatbuilder') then
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.NONE)
  end
end)
