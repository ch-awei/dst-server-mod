local assets = {}

local function fn()
  local inst = CreateEntity()

  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddSoundEmitter()
  inst.entity:AddLight()
  inst.entity:AddNetwork()

  inst.AnimState:SetBank('bundle')
  inst.AnimState:SetBuild('bundle')
  inst.AnimState:PlayAnimation('unwrap')

  inst:AddTag('FX')
  inst:AddTag('NOCLICK')

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  inst.persists = false
  inst:ListenForEvent('animover', inst.Remove)

  return inst
end

return Prefab('seal_lamp_fx', fn, assets)
