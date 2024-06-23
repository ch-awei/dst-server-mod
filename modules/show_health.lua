if EndableOneOfMods({'666155465', '2189004162'}) then return end

AddPrefabPostInitAny(function(inst)
  if inst:HasOneOfTags({'NOCLICK', 'FX'}) then return end
  inst._net_health = net_float(inst.GUID, 'showinfo_health')
  if IsServer then
    local fn = function(inst)
      inst._net_health:set(inst.components.health and inst.components.health.currenthealth or 0)
    end
    inst:DoTaskInTime(0, function(inst)
      if not inst:HasTag('_health') or inst:HasTag('smallcreature') then
        return
      end
      fn(inst)
      inst:ListenForEvent('healthdelta', fn)
    end)
    return
  end
  inst:DoTaskInTime(0, function(inst)
    if not inst:HasTag('_health') or inst:HasTag('smallcreature') then
      return
    end
    ResetBasicName(inst, function(str)
      local h = inst._net_health ~= nil and inst._net_health:value() or 0
      if h > 0 then
        return str .. '\n󰀍' .. SetNumberFormat(h, 1)
      end
    end)
  end)
end)
