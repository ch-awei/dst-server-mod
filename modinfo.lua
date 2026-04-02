name = "ServerMod"
author = "awei"

version = "2025.04.26"
description = [[
  别开带[测]选项！

  最近更新：删除了许多不想维护的功能

]]

api_version = 0xa
priority = -999999

dst_compatible = true
all_clients_require_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

local function SetOption(d, data, hover)
  return {
    description = d or "禁用",
    data = data or (d and true or false),
    hover = hover
  }
end
local function AddConfig(label, name, hover, options, default)
  return {
    label = label or "",
    name = name or "",
    hover = hover or "",
    options = options and options or name and {SetOption(), SetOption("启用")} or {SetOption("")},
    default = default or false
  }
end

configuration_options = {
  AddConfig("原版修改"),
  AddConfig("自动堆叠", "auto_stack", nil, {
    SetOption(nil, nil, "什么都不发生"),
    SetOption("小范围", 4, "半径1格地皮"),
    SetOption("中范围", 16, "半径4格地皮"),
    SetOption("大范围", 32, "半径8格地皮")
  }),
  AddConfig("全部堆叠", "all_autostack", "此项生效于上一项\n世界加载的物品也自动堆叠,否则只自动堆叠世界加载之后产生的物品"),
  AddConfig("极简定位", "compass", "仅显示队友位置"),
  AddConfig("无间隔", "deploy_anywhere", nil, {
    SetOption(nil, nil,"什么都不发生"),
    SetOption("仅建筑", 1),
    SetOption("仅种植/放置", 2),
    SetOption("两者都", 3)
  }),
  AddConfig("公共溯源表", "pocket_watch", "其他人可消耗少量饥饿和san使用溯源表"),
  AddConfig("弹性容器", "container_upgradeable", "所有容器均可以升级999+，包括模组的容器"),
  AddConfig("Finder", "finder", "鼠标拿东西时含有同类物品的箱子高亮，找东西用的\n服务器启用《ShowMe》或《insight》时失效"),
  AddConfig("[测]信息显示", "show_info", "显示物品部分信息\n服务器启用《ShowMe》或《insight》时失效"),
  AddConfig(
    "[删]龙蝇箱收集",
    "dragonfly_chest_collect",
    "龙蝇箱子第一格有懒人护符则在关箱子或加载世界时收集后面紧接的第一格物品\n护符耐久不足且箱子内有噩梦燃料则会自动为护符添燃",
    {
      SetOption(nil, nil, "什么都不发生"),
      SetOption("小范围", 12, "半径2格地皮"),
      SetOption("大范围", 40, "半径10格地皮, 人物的加载范围(常说的一个屏幕)"),
      SetOption("全图", 3000)
    }
  ),
  AddConfig("高级耕作帽", "hat_nutrientsgoggles", "高级耕作帽可以放种子[农作物种子、树木种子、大理石豆]进行播种"),
  AddConfig("更多配方", "more_recipes", "添加约束静电[精炼]、陀螺传导核心[精炼]、空瓶子[精炼/人物(仅薇洛)]等配方", {
    SetOption(nil, nil, "什么都不发生"),
    SetOption("一般", 2),
    SetOption("简单", 1, "材料减半")
  }),

  AddConfig("其他MOD修改"),
  AddConfig("棱镜", "modify_legion", "蔷薇花、蹄莲花、兰草花可以放入盐盒"),
  AddConfig("勋章", "modify_medal", "智能陷阱冷却时间为1s、红晶锅快速烹饪")
}
