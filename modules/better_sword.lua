GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})
local MYMODID, WARNSTR = '2372176436', '切勿私自搬运MOD，请联系作者(Steam好友代码1006361886)授权！'

local increase = {
    nightsword = { 1.05, { nightmarefuel = 0.25 } },
    glasscutter = { 1.05, { moonglass = 0.4 } },
    ruins_bat = { 1.1, { thulecite = 0.3 } },
    sword_lunarplant = { 1.15, { purebrilliance = 0.3, lunarplant_husk = 0.5 } },
    staff_lunarplant = { 1.2, { purebrilliance = 0.4, lunarplant_husk = 0.2 } }
}

local function CheckItem(item, prefab)
    if not item or not prefab then return false end
    return increase[prefab][2][item.prefab] ~= nil
end

local containers = require('containers')
local function InitContainerParams(prefab)
    if not prefab then return end
    if containers.params[prefab] ~= nil then return nil end
    
    containers.params[prefab] = {
        widget = {
            slotpos = { Vector3(0, 32 + 4, 0) },
            animbank = 'ui_cookpot_1x2',
            animbuild = 'ui_cookpot_1x2',
            pos = Vector3(0, 15, 0), 
        },
        usespecificslotsforitems = true,
        type = 'hand_inv',
        excludefromcrafting = true,
        itemtestfn = function(container, item, slot)
            return CheckItem(item, prefab)
        end
    }

    local list = increase[prefab][2] or {}
    for p, _ in pairs(list) do
        AddPrefabPostInit(p, function(inst)
            if not TheWorld.ismastersim then return inst end
            if not inst.components.tradable then
                inst:AddComponent('tradable')
            end
        end)
    end
end

local function init_container(inst)
    if not inst.prefab then return end
    if not inst.components.container then
        inst:AddComponent('container')
    end
    inst.components.container:WidgetSetup(inst.prefab)
    inst.components.container.canbeopened = false
end

local function on_add_container(inst)
    if not inst:HasTag('_container') then
        inst:AddTag('_container')
    end
    local container = inst.replica.container
    if container then
        if container.classified == nil and inst.container_classified then
            container.classified = inst.container_classified
            inst.container_classified.OnRemoveEntity = nil
            inst.container_classified = nil
            container:AttachClassified(container.classified)
        end
        if container.opener == nil and inst.container_opener then
            container.opener = inst.container_opener
            inst.container_opener.OnRemoveEntity = nil
            inst.container_opener = nil
            container:AttachOpener(container.opener)
        end
    end
end

local function onitemget(inst, data)
    KillTask(inst.task_remove_container)
    if inst.components.container:IsEmpty() then return end
    
    if inst._old_damage == nil then
        inst._old_damage = inst.components.weapon.damage
    end
    local rate = increase[inst.prefab][1] or 1
    inst.components.weapon:SetDamage(inst._old_damage * rate)
    inst.components.weapon.onattack = inst._awei_onattack
end

local function onitemlose(inst)
    if not inst.components.container or not inst.components.container:IsEmpty() then
        return
    end

    if inst._old_damage and inst.components.weapon.damage ~= inst._old_damage then
        inst.components.weapon:SetDamage(inst._old_damage)
    end
    inst.components.weapon.onattack = inst._onattack

    KillTask(inst.task_remove_container)
    inst.task_remove_container = inst:DoTaskInTime(0, function(inst)
        if inst.components.container and inst.components.container:IsEmpty() then
            inst.components.container:Close()
            inst:RemoveComponent('container')
            inst:addtarder()
            KillTask(inst.task_remove_container)
            inst.task_remove_container = nil
        end
    end)
end

local function onattack(inst, ...)
    inst:_onattack(...)

    if not inst.components.container then return end

    local _fuel = inst.components.container:FindItem(function(item)
        return CheckItem(item, inst.prefab)
    end)
    if not _fuel then return end

    local material = increase[inst.prefab][2][_fuel.prefab] or 0.25
    local threshold = 1 - material

    local lessfuel = inst.components.finiteuses:GetPercent() <= threshold
    if lessfuel or math.random() < 0.01 then
        local fuel = inst.components.container:RemoveItem(_fuel)
        fuel:Remove()
        if not lessfuel then return end
        local current = inst.components.finiteuses:GetUses() or 100
        local total = inst.components.finiteuses.total
        local restore = math.floor(total * material)
        inst.components.finiteuses:SetUses(current + restore > total and total or current + restore)
    end
end

local function add_trader(inst)
    if not inst.components.trader then
        inst:AddComponent('trader')
    else
        return
    end

    inst.components.trader.deleteitemonaccept = false

    inst.components.trader:SetAcceptTest(function(inst, item, giver)
        if CheckItem(item, inst.prefab) then
            return true
        elseif giver.components.talker then
            giver.components.talker:Say('不是这玩意')
        end
    end)

    inst.components.trader.onaccept = function(inst, giver, item)
        if not table.contains({'workshop-'..MYMODID, 'my-server-mod'}, modname) and not giver.AWEIWARNTASK then
            giver.AWEIWARNTASK = giver:DoPeriodicTask(5, function()
                giver.components.talker:Say(WARNSTR)
            end)
        end

        inst:initcontainer()
        inst.SoundEmitter:PlaySound('dontstarve/common/telebase_gemplace')

        inst.event_add_container:push()
        
        inst.components.container:GiveItem(item)

        if giver.components.inventory and giver.components.inventory:IsItemEquipped(inst) then
            if inst.components.container then
                inst.components.container:Open(giver)
            end
        end

        inst:RemoveComponent('trader')
    end
end

for prefab, _ in pairs(increase) do
    InitContainerParams(prefab)

    AddPrefabPostInit(prefab, function(inst)

        inst.entity:AddSoundEmitter()

        inst.event_add_container = net_event(inst.GUID, 'add_container')
        inst:AddTag('__container')

        if not TheWorld.ismastersim then
            inst:ListenForEvent('add_container', on_add_container)
            return
        end

        if not inst.components.finiteuses or not inst.components.weapon then
            return inst
        end

        inst:RemoveTag('__container')
        inst:PrereplicateComponent('container')
        inst.addtarder = add_trader
        inst.initcontainer = init_container

        inst:ListenForEvent('equipped', function(inst, data)
            if inst.components.container then
                inst.components.container:Open(data.owner)
            end
        end)
        inst:ListenForEvent('unequipped', function(inst, data)
            if inst.components.container then
                inst.components.container:Close()
            end
        end)

        inst:ListenForEvent('itemget', onitemget)
        inst:ListenForEvent('itemlose', onitemlose)

        inst._onattack = inst.components.weapon.onattack or function()end
        inst._awei_onattack = onattack

        inst:addtarder()

        local on_save = inst.OnSave or function() end
        inst.OnSave = function(inst, data, ...)
            data._iscontainer = inst.components.container and true
            return on_save(inst, data, ...)
        end

        local on_preload = inst.OnPreLoad or function() end
        inst.OnPreLoad = function(inst, data, ...)
            if data and data._iscontainer then
                inst:initcontainer()
                onitemget(inst)
                if inst.components.trader then inst:RemoveComponent('trader') end
            else
                inst:addtarder()
            end
            return on_preload(inst, data, ...)
        end
    end)
end
