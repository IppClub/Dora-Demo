# 归灯 · Returning Home（Dora TypeScript 版）

这是对随附 Unity 项目 `ReturningHome30` 的完整 Dora 引擎复刻与扩展。三章地图、守卫巡逻路线、潜行规则、收集物、青灯检查点、结算与声音反馈均来自原项目设计；汉服橘猫、三章合批场景、音效、中文字体和封面直接复用原资源。Unity YAML 网格的顶点色与坐标通过 `tools/export_assets.py` 无损读取并转成 Dora 可加载的 glTF 资源。

## 内容

- 三个剧情章节：门庭夜雨、回廊迷灯、归灯祠堂
- 2 / 3 / 4 名纸人守卫及原版四点巡逻路线
- 视锥、持续警觉、墙与屏风遮挡、轻步和响铃诱敌
- 每章三枚灯印、三枚铜钱、青灯检查点和朱门出口
- 生命、被捕回退、暂停、胜负结算、章节解锁、星级和最佳成绩持久化
- 每日挑战、90 秒长夜守灯、全收集旧物三个扩展玩法入口
- 键盘、触控虚拟摇杆和手柄输入；小地图与警戒 HUD

## 操作

- `WASD` / 方向键 / 左摇杆：移动
- `Shift` / 手柄左肩键 / 轻步按钮：切换轻步
- `Space` / 手柄 A / 响铃按钮：响铃诱敌
- `Esc` / 手柄 Start：暂停或继续
- `O`：开关声音
- 开场与结算界面可直接触摸按钮操作；键盘数字键也可选择章节或挑战
- `Enter` / `Space`：键盘确认结算

## 构建与运行

```sh
dora cli build -p /Users/Jin/Workspace/Dora/3D-Adv-Game/Dora --lang ts
dora cli run -p /Users/Jin/Workspace/Dora/3D-Adv-Game/Dora --entry init.lua
```

`preview.lua` 会直接打开第一章，便于画面检查；`validate.lua` 会检查全部地图尺寸、关键物件数量和巡逻数据结构。运行前应确保只有一个 Dora 引擎实例监听 `8866`，以免 Web IDE 连接到错误实例。

## 资源重建

```sh
/Applications/Blender.app/Contents/MacOS/Blender --background --python tools/export_assets.py
```

脚本会输出猫动画、场景批处理模型与玩法物件到 `Assets/Model`。章节墙体和地面按完整 Unity 网格合批，以避免大量独立模型提交导致移动 GPU 压力。
