GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

table.insert(PrefabFiles, 'seal_lamp')
table.insert(PrefabFiles, 'seal_lamp_fx')

STRINGS.NAMES.SEAL_LAMP = '影月封缚灯'
STRINGS.RECIPE_DESC.SEAL_LAMP = '封住！'
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SEAL_LAMP = '能封住整个世界吗'

STRINGS.SEALLAMPPACKFULL = '封存的物品'
STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.SEALLAMPPACK = { WUFA = '好像没法封住这玩意', USEING = '使用中' }

local list_white = {
  'wormhole',
  'lava_pond',
  'moonbase',
  'sculpture_knighthead',
  'sculpture_rooknose',
  'sculpture_bishophead',
  'statueglommer',
  'oceantreenut',
  'walrus_camp'
}
local prefabs_notpack = {
  'portal',
  'cave_entrance',
  'hermithouse',
  'oasislake',
  'queen',
  'pillar',
  'glommer',
  'toadstool'
}

local function isPrefab(target)
  for _, str in pairs(prefabs_notpack) do
    if target.prefab:find(str) then
      return true
    end
  end
  return false
end

local tags_notpack = {
  '_health',
  'irreplaceable',
  'king',
  'stargate',
  'INLIMBO',
  'NOCLICK',
  'nopackable'
}

GLOBAL.SEAL_LAMP_PACKTEST = function(inst, target)
  for _, prefab in pairs(list_white) do
    if target.prefab == prefab then
      return true
    end
  end
  if AllRecipes[target.prefab] ~= nil and target:HasTag('structure') then
    return true
  end
  return inst:HasTag('seal_lamp')
    and target
    and target:IsValid()
    and not target:IsInLimbo()
    and not isPrefab(target)
    and not target:HasOneOfTags(tags_notpack)
end

local materials = {
  easy = {
    Ingredient('moonglass', 5),
    Ingredient('nightmarefuel', 10)
  },
  default = {
    Ingredient('horrorfuel', 3),
    Ingredient('moonglass_charged', 5)
  },
  difficulty = {
    Ingredient('alterguardianhatshard', 1),
    Ingredient('thurible', 1),
    Ingredient('hermit_cracked_pearl', 1)
  }
}

AddRecipe2(
  'seal_lamp',
  materials[GetModConfigData('mode') or 'default'],
  TECH.SCIENCE_TWO,
  { atlas = 'images/seal_lamp.xml' },
  { 'TOOLS' }
)

local mode = GetModConfigData('magic_seal_lamp')
local _costs = {
  easy = TUNING.SANITY_SUPERTINY,
  default = TUNING.SANITY_SMALL
}
local costs = {
  easy = TUNING.SANITY_TINY,
  default = TUNING.SANITY_HUGE
}

local SEALLAMPPACK = GLOBAL.Action({priority = 99})
SEALLAMPPACK.id = 'SEALLAMPPACK'
SEALLAMPPACK.str = '施法'
SEALLAMPPACK.fn = function(act)
  local target = act.target
  local invobject = act.invobject
  local doer = act.doer
  if target ~= nil then
    local targetpos = target:GetPosition()
    local lamp = SpawnPrefab('seal_lamp_full')
    if lamp and lamp.components.packfull then
      if not lamp.components.packfull:CanPack(target) then
        lamp:Remove()
        return false, 'WUFA'
      end
      if target.components.teleporter ~= nil and target.components.teleporter:IsBusy() then
        lamp:Remove()
        return false, 'USEING'
      end
      lamp.components.packfull:Pack(target)
      if doer and doer.components.inventory then
        doer.components.inventory:GiveItem(lamp)
      else
        lamp.Transform:SetPosition(targetpos:Get())
      end
      if doer.components.sanity then
        local cost = AllRecipes[target.prefab] ~= nil and (_costs[mode] or TUNING.SANITY_LARGE) or (costs[mode] or doer.components.sanity.current)
        doer.components.sanity:DoDelta(-cost)
      end
      if doer and doer.SoundEmitter then
        doer.SoundEmitter:PlaySound('dontstarve/common/staff_dissassemble')
      end
      return true
    end
  end
end

AddAction(SEALLAMPPACK)

AddComponentAction('USEITEM', 'packlamp', function(inst, doer, target, actions)
  if SEAL_LAMP_PACKTEST(inst, target) then
    table.insert(actions, ACTIONS.SEALLAMPPACK)
  end
end)

AddStategraphActionHandler('wilson', ActionHandler(ACTIONS.SEALLAMPPACK, 'dolongaction'))
AddStategraphActionHandler('wilson_client', ActionHandler(ACTIONS.SEALLAMPPACK, 'dolongaction'))
