local assets = {Asset('ANIM', 'anim/more_books.zip')}

local function mergeTable(...)
  local res = {}
  for _, t in pairs({...}) do
    if type(t) == 'table' then
      for i, val in pairs(t) do
        if not table.contains(res, val) then
          table.insert(res, val)
        end
      end
    end
  end
  return res
end

local function KillTask(task)
  if task == nil then return end
  task:Cancel()
  task = nil
end

local function pick(target, doer)
  if target.components.pickable and target.components.pickable:CanBePicked() then
    if not target:HasTag('flower') or target:HasTag('bush_l_f') then
      local drop = false
      if target.components.pickable.droppicked then
        drop = true
        target.components.pickable.droppicked = false
      end
      target.components.pickable:Pick(doer)
      if drop then
        target.components.pickable.droppicked = true
      end
    end
  end
  if target.components.harvestable and target.components.harvestable:CanBeHarvested() then
    target.components.harvestable:Harvest(doer)
  end
  if target.components.stewer and target.components.stewer:IsDone() then
    target.components.stewer:Harvest(doer)
  end
  if target.components.dryer and target.components.dryer:IsDone() then
    target.components.dryer:Harvest(doer)
  end
end

local function perusefn(inst, reader)
  if reader.components.talker then
    reader.components.talker:Say('这是甚么玩意儿')
  end
  return true
end

local function removeItem(item, len)
  if not len or len < 30 then
    SpawnPrefab('sand_puff').Transform:SetPosition(item.Transform:GetWorldPosition())
  end
  item:Remove()
end

local function spawnItems(prefab, num)
  local item, items = SpawnPrefab(prefab), {}
  local maxsize = item.components.stackable and item.components.stackable.maxsize or 1
  if num <= maxsize then
    item.components.stackable:SetStackSize(num)
    table.insert(items, item)
  else
    local _result = math.floor(num / maxsize)
    local _residue = num - _result * maxsize
    for i = 1, _result do
      local _item = SpawnPrefab(prefab)
      _item.components.stackable:SetStackSize(maxsize)
      table.insert(items, _item)
    end
    if _residue > 0 then
      local _item = SpawnPrefab(prefab)
      _item.components.stackable:SetStackSize(_residue)
      table.insert(items, _item)
    end
  end
  return items
end

local function giveItems(player, prefab, num, pos, on_floor)
  if not player or not prefab or not num then
    return
  end
  local inventory = player.components.inventory
  local items = spawnItems(prefab, num)
  for i, item in ipairs(items) do
    if inventory and not on_floor then
      inventory:GiveItem(item, nil, pos or Vector3(player.Transform:GetWorldPosition()))
    else
      local x, y, z
      if on_floor and pos then
        x, y, z = pos.x, 0, pos.z
      else
        x, y, z = player.Transform:GetWorldPosition()
      end
      item.Transform:SetPosition(x, y, z)
    end
  end
end

local function setMoisture(inst)
  if not inst then
    return nil
  end
  KillTask(inst._task_awei_moisture)
  inst._task_awei_moisture_loop = nil
  if not inst.components.moisture then
    inst:AddComponent('moisture')
  end
  local fn = function(inst)
    local _moisture = inst.components.moisture
    if _moisture:GetMoisture() < _moisture:GetMaxMoisture() then
      _moisture:DoDelta(_moisture:GetMaxMoisture() or 100)
    end
    local _loop = inst._task_awei_moisture_loop
    inst._task_awei_moisture_loop = type(_loop) == 'number' and (_loop + 1) or 0
    if inst._task_awei_moisture_loop > 60 then
      KillTask(inst._task_awei_moisture)
    end
  end
  fn(inst)
  inst._task_awei_moisture = inst:DoPeriodicTask(5, fn)
  inst:ListenForEvent('death', function(inst)
    KillTask(inst._task_awei_moisture)
  end)
end

local tags_ignore = {'INLIMBO', 'FX', 'NOCLICK'}
local present_prefabs = {
  lightbulb = true,
  foliage = true
}

local books = {
  {
    name = 'artisan',
    uses = TUNING.BOOK_USES_SMALL,
    read_sanity = -TUNING.SANITY_HUGE,
    fn = function(inst, reader)
      local x, y, z = reader.Transform:GetWorldPosition()
      local ents = TheSim:FindEntities(x, y, z, 36, {'_inventoryitem', '_stackable'},
        mergeTable(tags_ignore, {'_health', 'structure'}))
      local len_ents = #ents
      if len_ents == 0 then
        return false, '周围没有可炼化的物品'
      end
      local refine = {
        log = 'boards',
        cutgrass = 'rope',
        cutreeds = 'papyrus',
        marble = 'marblebean'
      }
      local refine_num = {
        log = 4,
        cutgrass = 3,
        cutreeds = 4
      }
      local result = {}
      local residue = {}
      local last_item_pos = {}
      for _, item in pairs(ents) do
        local _p = item.prefab
        if refine[_p] ~= nil then
          last_item_pos[_p] = Vector3(item.Transform:GetWorldPosition())
          local n = item.components.stackable and item.components.stackable:StackSize() or 1
          if type(residue[_p]) == 'number' and residue[_p] > 0 then
            n = n + residue[_p]
            residue[_p] = nil
          end
          local _num = refine_num[_p] or 1
          local _result = math.floor(n / _num)
          if _result > 0 then
            if type(result[_p]) ~= 'number' then
              result[_p] = 0
            end
            result[_p] = result[_p] + _result
            giveItems(reader, refine[_p], _result, last_item_pos[_p])
          end
          local _residue = n - _result * _num
          if _residue > 0 then
            residue[_p] = _residue
          end
          removeItem(item, len_ents)
        end
      end
      for _p, _num in pairs(residue) do
        giveItems(reader, _p, _num, last_item_pos[_p], true)
      end
      local total = 0
      for _p, _num in pairs(result) do
        total = total + _num
      end
      if total == 0 then
        return false, '周围没有可炼化的物品'
      end
      return true
    end
  }, {
    name = 'harvest',
    uses = TUNING.BOOK_USES_LARGE,
    read_sanity = -TUNING.SANITY_LARGE,
    fn = function(inst, reader)
      if not reader:HasTag('player') or reader.components.inventory == nil then
        return false
      end
      local x, y, z = reader.Transform:GetWorldPosition()
      local ents = TheSim:FindEntities(x, y, z, 30, nil, mergeTable(tags_ignore, {'_health'}))
      if #ents == 0 then
        return false, '没有可收获的物品'
      end
      for _, v in pairs(ents) do
        if v ~= nil then
          pick(v, reader)
        end
      end
      return true
    end
  }, {
    name = 'livestock',
    uses = TUNING.BOOK_USES_LARGE,
    read_sanity = -TUNING.SANITY_MEDLARGE,
    fn = function(inst, reader)
      local x, y, z = reader.Transform:GetWorldPosition()
      local ents = TheSim:FindEntities(x, y, z, 30, {'beefalo'}, tags_ignore)
      if #ents == 0 then
        return false, '没有可操作的牛牛'
      end
      local _num = 0
      for _, v in pairs(ents) do
        if v.components.beard ~= nil and v.components.beard.bits ~= 0
        and (not v.components.domesticatable or v.components.domesticatable.domestication < 0.05) and
          not (v.components.freezable ~= nil and v.components.freezable:IsFrozen()) and
          not (v.components.pinnable ~= nil and v.components.pinnable:IsStuck()) and
          not (v.components.fossilizable ~= nil and v.components.fossilizable:IsFossilized()) then
          _num = _num + 1
          local ismount, mount
          if v.components.rider ~= nil then
            ismount = v.components.rider:IsRiding()
            mount = v.components.rider:GetMount()
          end
          if mount ~= nil then
            mount:PushEvent("ridersleep", {
              sleepiness = 10,
              sleeptime = 20
            })
          end
          if v.components.sleeper ~= nil then
            v.components.sleeper:AddSleepiness(10, 20)
          elseif v.components.grogginess ~= nil then
            v.components.grogginess:AddGrogginess(10, 20)
          else
            v:PushEvent("knockedout")
          end
          local fx = SpawnPrefab(ismount and "fx_book_sleep_mount" or "fx_book_sleep")
          fx.Transform:SetPosition(v.Transform:GetWorldPosition())
          fx.Transform:SetRotation(v.Transform:GetRotation())
          v:StartThread(function()
            Sleep(1)
            v.components.beard:Shave(reader)
          end)
        end
      end
      if _num == 0 then
        return false, '没有可操作的牛牛'
      end
      inst:StartThread(function()
        Sleep(2)
        local _list = TheSim:FindEntities(x, y, z, 30, {'_inventoryitem', '_stackable'},
          mergeTable(tags_ignore, {'_health', 'structure'}))
        for i, v in ipairs(_list) do
          if v.prefab == 'beefalowool' then
            Sleep(0.1)
            if reader.components.inventory then
              reader.components.inventory:GiveItem(v, nil, Vector3(v.Transform:GetWorldPosition()))
            else
              v.Transform:SetPosition(reader.Transform:GetWorldPosition())
            end
          end
        end
      end)
      return true
    end
  }, {
    name = 'present',
    uses = TUNING.BOOK_USES_SMALL,
    read_sanity = -TUNING.SANITY_SMALL,
    fn = function(inst, reader)
      local x, y, z = reader.Transform:GetWorldPosition()
      local ents = TheSim:FindEntities(x, y, z, 30, {'_stackable', '_inventoryitem'},
        mergeTable(tags_ignore, {'_health', 'structure'}))
      if #ents == 0 then
        return false, '没有找到相关物品'
      end
      local total = 0
      for _, v in pairs(ents) do
        if present_prefabs[v.prefab] then
          total = total + (v.components.stackable and v.components.stackable.stacksize or 1)
          removeItem(v, #ents)
        end
      end
      if total == 0 then
        return false, '没有找到相关物品'
      end
      giveItems(reader, 'petals', total)
      return true
    end
  }, {
    name = 'battle',
    uses = TUNING.BOOK_USES_LARGE,
    read_sanity = -TUNING.SANITY_LARGE,
    fn = function(inst, reader)
      local x, y, z = reader.Transform:GetWorldPosition()
      local _ignore = mergeTable(tags_ignore, {'structure', '_stackable', '_inventoryitem'})
      local _has_one = {'player', 'epic', 'largecreature'}
      local ents = TheSim:FindEntities(x, y, z, 30, {'_health'}, _ignore)
      if #ents == 0 then
        return false, '没有找到相关生物'
      end
      for _, v in pairs(ents) do
        if v:HasTag('player') then
          v:AddDebuff("buff_attack", "buff_attack")
          v:AddDebuff("buff_electricattack", "buff_electricattack")
          v:AddDebuff("buff_moistureimmunity", "buff_moistureimmunity")
        elseif v:HasOneOfTags({'epic', 'largecreature'}) then
          setMoisture(v)
        end
      end
      return true
    end
  }
}

local function MakeBook(def)
  local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("more_books")
    inst.AnimState:SetBuild("more_books")
    inst.AnimState:PlayAnimation(def.name)
    MakeInventoryFloatable(inst, "med", nil, 0.75)
    inst:AddTag("book")
    inst:AddTag("bookcabinet_item")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
      return inst
    end
    inst:AddComponent("inspectable")
    inst:AddComponent("book")
    inst.components.book:SetOnRead(def.fn)
    inst.components.book:SetOnPeruse(def.perusefn or perusefn)
    inst.components.book:SetReadSanity(def.read_sanity or -TUNING.SANITY_LARGE)
    inst.components.book:SetPeruseSanity(def.peruse_sanity or TUNING.SANITY_LARGE)
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = 'images/book_' .. def.name .. '.xml'
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(def.uses or TUNING.BOOK_USES_SMALL)
    inst.components.finiteuses:SetUses(def.uses or TUNING.BOOK_USES_SMALL)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunch(inst)
    return inst
  end
  return Prefab('book_' .. def.name, fn, assets)
end

local ret = {}

for i, v in ipairs(books) do
  table.insert(assets, Asset('ATLAS', 'images/book_' .. v.name .. '.xml'))
  table.insert(ret, MakeBook(v))
end

books = nil

return unpack(ret)
