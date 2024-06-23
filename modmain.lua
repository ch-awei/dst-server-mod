PrefabFiles = {}
Assets = {}

modimport('scripts/awei_utils.lua')

local list_configuration = {
  'auto_stack',
  'fish_stack',
  'more_recipes',
  'deploy_anywhere',
  'beef_bell',
  'eye_turret',
  'pocket_watch',
  'spice_caneat',
  'some_befresh',
  'houndstooth_blowpipe',
  'bomb_lunarplant',
  'container_upgradeable',

  'finder',
  'show_health',
  'better_sword',
  'hat_nutrientsgoggles',
  'dragonfly_chest_collect',
  'container_befresh',
  'versatile',
  'more_books',
  'magic_seal_lamp',

  'modify_legion',
  'modify_medal'
}

for _, v in ipairs(list_configuration) do
  if GetModConfigData(v) then
    modimport('modules/' .. v .. '.lua')
  end
end

if GetModConfigData('trap_starfish_cd') and TUNING.STARFISH_TRAP_NOTDAY_RESET ~= nil then
  TUNING.STARFISH_TRAP_NOTDAY_RESET.BASE = GetModConfigData('trap_starfish_cd')
end
