if IsClient then return end

local spices = {
  spice_garlic = {
    oneatenfn = function(inst, eater)
      eater:AddDebuff('buff_playerabsorption', 'buff_playerabsorption')
    end,
    prefabs = {'buff_playerabsorption'}
  },
  spice_sugar = {
    oneatenfn = function(inst, eater)
      eater:AddDebuff('buff_workeffectiveness', 'buff_workeffectiveness')
    end,
    prefabs = {'buff_workeffectiveness'}
  },
  spice_chili = {
    oneatenfn = function(inst, eater)
      eater:AddDebuff('buff_attack', 'buff_attack')
    end,
    prefabs = {'buff_attack'}
  },
  spice_salt = {}
}

SpiceCaneat(spices)
