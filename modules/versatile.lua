GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

local tags = {
  'clockmaker',
  'expertchef',
  'fastbuilder',
  'fastpicker',
  'woodcutter',
  'balloonomancer',
  'pyromaniac',
  'reader',
  'bookbuilder',
  'valkyrie',
  'handyperson',
  'masterchef',
  'professionalchef',
  'merm_builder',
}
local cpts = { 'reader' }

local function AddTags(player)
  if player:HasTag('_init_versatile') then
    return player:StopWatchingWorldState('cycles', AddTags)
  end
  for i, tag in pairs(tags) do
    if not player:HasTag(tag) then
      player:AddTag(tag)
      if tag == 'bookbuilder'
        and player.components.builder.science_bonus < 1
        and player.replica.builder
        and player.replica.builder.classified ~= nil
      then
        player.components.builder.science_bonus = 1
      end
    end
  end
  for i, c in pairs(cpts) do
    if not player.components[c] then
      player:AddComponent(c)
    end
  end
  player:PushEvent('refreshcrafting')
  player:AddTag('_init_versatile')
end

AddPlayerPostInit(function(player)
  if EndableOneOfMods({ '1909182187' }) then return end
  if not TheWorld.ismastersim then return end
  player:DoTaskInTime(0, AddTags)
  player:WatchWorldState('cycles', AddTags)
end)

AddComponentPostInit('stewer', function(self)
  self.cooktimemult = 0.1
end)

local function ChangeAction(action, fn)
  AddStategraphActionHandler("wilson", ActionHandler(action, fn))
  AddStategraphActionHandler("wilson_client", ActionHandler(action, fn))
end

ChangeAction(ACTIONS.HARVEST, function(inst, action)
  return inst:HasTag('fastpicker') and 'doshortaction'
    or inst:HasTag('quagmire_fasthands') and 'domediumaction'
    or 'dolongaction'
end)
