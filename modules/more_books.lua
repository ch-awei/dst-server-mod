GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

table.insert(PrefabFiles, 'more_books')

local recipes = {
  harvest = {
    str = { '致无厌者', '《懒狗的自我修养》再版。', '就是因为有这种东西，肥宅才会被人误会！' },
    ingredients = {
      Ingredient('papyrus', 2),
      Ingredient('lureplantbulb', 1)
    }
  },
  artisan = {
    str = { '永恒资本论', '终于变成自己曾经讨厌的模样。', '抵制资本的行为只发生在自己变成资本家之前' },
    ingredients = {
      Ingredient('book_harvest', 1, 'images/book_harvest.xml'),
      Ingredient('waxwelljournal', 1),
      Ingredient('sewing_tape', 4)
    }
  },
  livestock = {
    str = { '游牧眠歌', '牛牛怎么你了！', '我劝你小子不要不了解魔法而妄下定论' },
    ingredients = {
      Ingredient('book_sleep', 1),
      Ingredient('razor', 1),
      Ingredient('beefalohat', 1)
    }
  },
  present = {
    str = { '虚妄之华', '我受够这些繁文缛节了！', '力量的形态千变万化，魔法与魔法之间亦有区别' },
    ingredients = {
      Ingredient('papyrus', 2),
      Ingredient('foliage', 15),
      Ingredient('petals', 15),
      Ingredient('succulent_picked', 15)
    }
  },
  battle = {
    str = { '雨中斗舞', '你违反了魔法斗殴管控法！', '你们不要再打了！要打就去练舞室打！' },
    ingredients = {
      Ingredient('book_rain', 1),
      Ingredient('frogfishbowl', 3),
      Ingredient('voltgoatjelly', 5)
    }
  }
}

local assets = {}
for k, v in pairs(recipes) do
  local name = 'book_' .. k
  local atlas = 'images/' .. name .. '.xml'
  table.insert(assets, Asset('ATLAS', atlas))
  AddRecipe2(
    name,
    v.ingredients,
    TECH.BOOKCRAFT_ONE,
    { builder_tag = 'bookbuilder', atlas = atlas },
    { 'CHARACTER' }
  )
  local _name = string.upper(name)
  STRINGS.NAMES[_name] = v.str[1]
  STRINGS.RECIPE_DESC[_name] = v.str[2]
  STRINGS.CHARACTERS.GENERIC.DESCRIBE[_name] = v.str[3]
end

AddPrefabPostInit('marbleshrub', function(inst)
  if not TheWorld.ismastersim then return end
  if not inst:HasTag('silviculture') then
    inst:AddTag('silviculture')
  end
  if inst.components.growable ~= nil then
    inst.components.growable.magicgrowable = true
    if not inst.components.simplemagicgrower then
      inst:AddComponent('simplemagicgrower')
    end
    inst.components.simplemagicgrower:SetLastStage(#inst.components.growable.stages or 3)
  end
end)
