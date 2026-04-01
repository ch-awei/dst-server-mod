local NetMap = Class(function(self, inst, event_prefix)
  self.inst = inst
  self.map = {}
  self.event_prefix = event_prefix or (modname .. "_net-change-")
end)

function NetMap:Add(key, netvar)
  netvar = netvar or net_string
  self.map[key] = netvar(self.inst.GUID, self.event_prefix .. key)
end

function NetMap:AddByMap(map)
  for key, netvar in pairs(map) do
    self:Add(key, netvar)
  end
end

function NetMap:Set(key, value)
  local success, result = pcall(function()
    self.map[key]:set(value)
  end)
  if not success then
    print(self.inst.name, " Set NetMap failed ==> ", key, result)
  end
  return success
end

function NetMap:Get(key)
  local success, result = pcall(function()
    return self.map[key]:value()
  end)
  return success and result or nil
end

function NetMap:ListenForEvent(key, callback)
  self.inst:ListenForEvent(self.event_prefix .. key, callback)
end

return NetMap
