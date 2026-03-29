modimport('scripts/awei_utils.lua')

local list_configuration = {
  'auto_stack',
  'compass',
  'more_recipes',
  'deploy_anywhere',
  'pocket_watch',
  'container_upgradeable',
  'finder',
  'show_info',
  'dragonfly_chest_collect',
  'hat_nutrientsgoggles',

  'modify_legion',
  'modify_medal'
}

for _, v in ipairs(list_configuration) do
  if GetModConfigData(v) then
    modimport('modules/' .. v .. '.lua')
  end
end
