GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

local cfg = GetModConfigData("deploy_anywhere") or false

if table.contains({1, 3}, cfg) then
  for k, v in pairs(AllRecipes) do
    if v.build_distance and v.build_distance > 0 then
      AllRecipes[k].build_distance = 0
    end
    if v.min_spacing and v.min_spacing > 0 then
      AllRecipes[k].min_spacing = 0
    end
  end
end

if not cfg then return end

local not_modes = {DEPLOYMODE.CUSTOM, DEPLOYMODE.WATER, DEPLOYMODE.TURF}
local not_tags = {'boatbuilder', 'fertilizer'}
AddPrefabPostInitAny(function(inst)
  if inst.deploy_smart_radius and inst.deploy_smart_radius > 0 then
    inst.deploy_smart_radius = 0
  end
  if inst.deploy_extra_spacing and inst.deploy_extra_spacing > 0 then
    inst.deploy_extra_spacing = 0
  end
  local d = inst.components.deployable
  if table.contains({2, 3}, cfg) and d ~= nil then
    if inst:HasOneOfTags(not_tags) or table.contains(not_modes, d.mode) then
      return
    end
    d.spacing = DEPLOYSPACING.NONE or 0
  end
end)
