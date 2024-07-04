name = 'awei server mod'
author = 'awei'
description = [[
  学习写MOD时写了些比较变态的功能，每个功能都有说明和单独开关

  切勿开启功能相同的MOD！切勿开启功能相同的MOD！切勿开启功能相同的MOD！

  最好别开带[测]选项，崩档我可不管！

  2024.07.04 更新日志：
    修复部分物品不能无间隔放置问题

  2024.06.29 更新日志：
    新增自动堆叠是否全部堆叠选项
    已删：狗牙吹箭无限容量
    将删：武器增强

]]

version = '2024.07.04'
api_version = 0xa
priority = -999999

dst_compatible = true
all_clients_require_mod = true

icon_atlas = 'modicon.xml'
icon = 'modicon.tex'

local function SetOption(d, data, hover)
  return { description = d or '禁用', data = data or (d and true or false), hover = hover }
end
local function AddConfig(label, name, hover, options, default)
  return {
    label = label or '',
    name = name or '',
    hover = hover or '',
    options = options and options or name and {SetOption(), SetOption('启用')} or {SetOption('')},
    default = default or false
  }
end

configuration_options = {
  AddConfig('原版修改'),
  AddConfig('自动堆叠', 'auto_stack', nil, {
    SetOption(nil, nil, '什么都不发生'),
    SetOption('小范围', 4, '半径1格地皮'),
    SetOption('中范围', 16, '半径4格地皮'),
    SetOption('大范围', 32, '半径8格地皮')
  }),
  AddConfig('[新]全部自动堆叠', 'all_autostack', '此项生效于上一项\n世界加载的物品也自动堆叠,否则只自动堆叠世界加载之后产生的物品'),
  AddConfig('淡水鱼堆叠', 'fish_stack', '淡水鱼和鳗鱼可以堆叠', {
    SetOption(nil, nil,'什么都不发生'),
    SetOption('20堆叠', 'MEDITEM'),
    SetOption('40堆叠', 'SMALLITEM')
  }),
  AddConfig('无间隔', 'deploy_anywhere', nil, {
    SetOption(nil, nil,'什么都不发生'),
    SetOption('仅建筑', 1),
    SetOption('仅种植/放置', 2),
    SetOption('两者都', 3)
  }),
  AddConfig('牛铃铛', 'beef_bell', '牛铃铛可以像岩浆虫牙一样包起来'),
  AddConfig('眼塔可拆', 'eye_turret', '可右键眼球塔回收\n被摧毁时返还一个眼球塔'),
  AddConfig('海星CD', 'trap_starfish_cd', nil, {
    SetOption(nil, nil, '什么都不发生'),
    SetOption('较快', 30, '30s'),
    SetOption('很快', 15, '15s'),
    SetOption('灰常快', 5, '5s，这个别轻易尝试')
  }),
  AddConfig('部分保鲜', 'some_befresh', '保鲜: 鸟笼、骨灰盒、种子袋、蘑菇灯、盐盒、饭盒，牛不消耗舔盐器\n哈奇内第一个(非哈奇第一格)能让其发光的物品暂停腐烂'),
  AddConfig('溯源表', 'pocket_watch', '其他人可消耗少量饥饿和san使用溯源表'),
  AddConfig('buff粉可吃', 'spice_caneat', '大厨的buff粉末可直接吃以获得buff'),
  AddConfig('无限亮茄炸弹', 'bomb_lunarplant', '在投掷炸弹2秒后会回到手上\n拆家预警！'),
  AddConfig('[测]弹性容器', 'container_upgradeable', '所有容器均可以升级999+，包括模组的容器'),

  AddConfig('拓展功能'),
  AddConfig('Finder', 'finder', '鼠标拿东西时含有同类物品的箱子高亮，找东西用的\n服务器启用《ShowMe》或《insight》时失效'),
  AddConfig('[测]生物显血', 'show_health', '鼠标显示非小型生物血量\n服务器启用《ShowMe》或《insight》时失效'),
  AddConfig('容器保鲜', 'container_befresh', '若容器内含有启迪之冠碎片, 则该容器会获得保鲜能力'),
  AddConfig('[删]武器增强', 'better_sword', '下个本版删除'),
  AddConfig('高级耕作帽', 'hat_nutrientsgoggles', '高级耕作帽可以放种子[农作物种子、树木种子、大理石豆]进行播种'),
  AddConfig('龙蝇箱收集', 'dragonfly_chest_collect', '龙蝇箱子第一格有懒人护符则在关箱子或加载世界时收集后面紧接的第一格物品\n护符耐久不足且箱子内有噩梦燃料则会自动为护符添燃', {
    SetOption(nil, nil, '什么都不发生'),
    SetOption('小范围', 12, '半径2格地皮'),
    SetOption('大范围', 40, '半径10格地皮，人物的加载范围(常说的一个屏幕)'),
    SetOption('全图', 3000)
  }),
  AddConfig('更多能力', 'versatile', '为玩家添加更多能力\n若启用《能力勋章》则失效'),
  AddConfig('更多配方', 'more_recipes', '添加约束静电[精炼]、空瓶子[精炼/人物(仅薇洛)]等配方', {
    SetOption(nil, nil, '什么都不发生'),
    SetOption('一般', 2),
    SetOption('简单', 1, '材料减半')
  }),
  AddConfig('更多书籍', 'more_books', '添加《收获之书》《工匠之书》《畜牧之书》《馈赠之书》《战斗之书》\n大理石可用造林学催熟'),
  AddConfig('Magic Seal Lamp', 'magic_seal_lamp', '私人定制，不建议开启', {
    SetOption(nil, nil, '什么都不发生'),
    SetOption('简单', 'easy'),
    SetOption('一般', 'default'),
    SetOption('困难', 'difficulty')
  }),

  AddConfig('其他MOD修改'),
  AddConfig('棱镜', 'modify_legion', '蔷薇花、蹄莲花、兰草花可以放入盐盒'),
  AddConfig('勋章', 'modify_medal', '智能陷阱冷却时间为1s、buff粉末可直接吃以获得buff\n红晶锅快速烹饪')
}
