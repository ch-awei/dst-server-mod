require "util/index.lua"

local list_configuration = {
  "auto_stack",
  "compass",
  "deploy_anywhere",
  "pocket_watch",
  "container_upgradeable",
  "finder",
  "show_info",
  "dragonfly_chest_collect",
  "hat_nutrientsgoggles",
  "more_recipes",

  "modify_legion",
  "modify_medal"
}

for _, v in ipairs(list_configuration) do
  if GetModConfigData(v) then
    modimport("modules/" .. v .. ".lua")
  end
end
