GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})

local mode = GetModConfigData('more_recipes')
local multiple = type(mode) == 'number' and mode or 1

AddRecipe2(
  'moonstorm_static_item',
  {
    Ingredient('moonglass_charged', 5 * multiple),
    Ingredient('moonstorm_spark', 3 * multiple)
  },
  TECH.SCIENCE_TWO,
  { no_deconstruction = true },
  { 'REFINE' }
)

AddRecipe2(
  'messagebottleempty',
  { Ingredient('moonglass', 3 * multiple) },
  TECH.SCIENCE_TWO,
  { builder_tag = 'heatresistant' },
  { 'REFINE', 'CHARACTER' }
)
