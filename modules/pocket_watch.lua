local _fn_cast_pocketwatch = ACTIONS.CAST_POCKETWATCH.fn
ACTIONS.CAST_POCKETWATCH.fn = function(act)
  local caster = act.doer
  if caster:HasTag("pocketwatchcaster") then
    return _fn_cast_pocketwatch(act)
  end
  if caster ~= nil and caster:HasTag("character") and act.invobject ~= nil then
    if caster.components.hunger then
      caster.components.hunger:DoDelta(-TUNING.HEALING_MEDSMALL)
    end
    if caster.components.sanity then
      caster.components.sanity:DoDelta(-TUNING.SANITY_TINY)
    end
    return act.invobject.components.pocketwatch:CastSpell(caster, act.target, act:GetActionPoint())
  end
end

local watch_useable = { "pocketwatch_recall", "pocketwatch_portal" }

AddComponentAction("USEITEM", "pocketwatch", function(inst, doer, target, actions)
  if inst:HasTag("pocketwatch_inactive") and (
      doer:HasTag("pocketwatchcaster")
      or table.contains(watch_useable, inst.prefab)
    )
    and inst.pocketwatch_CanTarget ~= nil
    and inst:pocketwatch_CanTarget(doer, target)
  then
    if not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) or inst:HasTag("pocketwatch_mountedcast") then
      table.insert(actions, ACTIONS.CAST_POCKETWATCH)
    end
  end
end)

AddComponentAction("INVENTORY", "pocketwatch", function(inst, doer, actions)
  if inst:HasTag("pocketwatch_inactive")
    and (
      doer:HasTag("pocketwatchcaster")
      or table.contains(watch_useable, inst.prefab)
    )
    and inst:HasTag("pocketwatch_castfrominventory")
  then
    if not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) or inst:HasTag("pocketwatch_mountedcast") then
      table.insert(actions, ACTIONS.CAST_POCKETWATCH)
    end
  end
end)
