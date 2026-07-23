# 项目交接文档 —— Godot 4 Undertale 风格叙事引擎

> **项目名称**: 动画/event系统代办  
> **引擎版本**: Godot 4.6  
> **核心目标**: 构建一个数据驱动的 Undertale 风格叙事引擎，用 .tres Resource 定义对话树，支持选项系统、旗帜路由、特效应答、门传送、相机分离式 UI。

---

## 1. PROJECT OVERVIEW —— 项目概述

该项目是一个 **Godot 4.6** 的 Undertale 风格 2D 叙事 RPG 引擎。核心理念是 **"最小正交组件"（minimum orthogonal components）**：每个组件只做一件事，通过组合实现复杂行为。

### 核心架构

```
┌─────────────────────────────────────────────────────┐
│                    项目管理方式                        │
│ 一切行为由 .tres Resource 定义（Dialogue/DialogueGroup） │
│ 对话路由由标志系统（Flags）+ ID 链驱动                   │
│ 无需写代码即可创作对话树                                │
└─────────────────────────────────────────────────────┘
```

**数据流**: `.tres Resource` → `npc_data.gd` / `zone_trigger_data.gd` → `Global.dialogue_broadcast` → 下一个 Group → `dialogue_manager.gd` 渲染

---

## 2. KEY FILE MAP —— 核心文件地图

### 2.1 对话系统核心（dialogue_script/）

| 文件路径 | class_name | 功能 | 关键 @export 字段 |
|----------|-----------|------|------------------|
| `dialogue_script/dialogue.gd` | `Dialogue` | 单句对话 Resource | `content`, `avatar`, `avatar_right`, `character_name`, `typing_sound`, `typing_speed`, `text_color`, `text_font`, `effect: Array[EffectData]`, `persist_effects`, `silent`, `position_up`, `can_skip`, `auto_continue`, `can_act`, `stay_duration`, `hide_end_hint`, `effect_sound` |
| `dialogue_script/dialogue_group.gd` | `DialogueGroup` | 对话组 Resource（一组 Dialogue） | `dialogue_list: Array[Dialogue]`, `id`, `next_id`, `require_flag`, `set_flag`, `choices: Array[String]`, `choice_next_ids: Array[String]`, `choice_effect: ChoiceEffectData`, `choice_switch_sound`, `choice_confirm_sound`, `choice_selected_color` |
| `dialogue_script/dialogue_manager.gd` | 无（autoload `DialogueUI`） | 对话 UI 控制器，挂 CanvasLayer | `character_name_text`, `text_box`, `left_avatar`, `right_avatar`, `main_dialogue: DialogueGroup`, `heart_move_duration` |
| `dialogue_script/choice_item.gd` | `ChoiceItem` | 单个选项 UI 组件 | — |
| `dialogue_script/effects_script/effect_data.gd` | `EffectData` | 效果器基类（空 Resource，占位） | — |
| `dialogue_script/effects_script/effect_shake.gd` | `ShakeEffect` | 对话框震动效果 | `magnitude_x`, `magnitude_y`, `count`, `speed` |
| `dialogue_script/effects_script/effect_wobble.gd` | `WobbleEffect` | 对话框摇摆效果 | `rotation`, `count`, `speed`, `decay`, `snap_threshold`, `fierce_return` |
| `dialogue_script/effects_script/effect_ghost.gd` | `RichTextGhost` | BBcode [ghost] 自定义效果（@tool） | — |
| `dialogue_script/effects_script/Choice_effects/choice_effect_data.gd` | `ChoiceEffectData` | 选项动效基类（空 Resource） | — |
| `dialogue_script/effects_script/Choice_effects/choice_slide_effect.gd` | `ChoiceSlideEffect` | 红心滑入效果 | `duration` |
| `dialogue_script/effects_script/Choice_effects/choice_snap_effect.gd` | `ChoiceSnapEffect` | 红心传送滑动效果 | `speed`, `use_ease`, `overshoot`, `overshoot_amount`, `block_input` |
| `dialogue_script/effects_script/Choice_effects/choice_wobbel_effect.gd` | `ChoiceWobbleEffect` | 红心跳动效果 | `magnitude`, `count`, `speed`, `decay` |

### 2.2 全局系统

| 文件路径 | class_name | 功能 | 关键信号/字段 |
|----------|-----------|------|-------------|
| `global/global.gd` | 无（autoload `Global`） | 全局状态管理 | `can_act: bool`, `player: PlayerData`, `pending_spawn_pos: Vector2`, `flags: Dictionary`, `signal dialogue_broadcast(next_id)`, `signal dialogue_line_reached(group_id, line_index)` |

### 2.3 玩家系统

| 文件路径 | class_name | 功能 | 关键字段 |
|----------|-----------|------|---------|
| `player/player.gd` | `Player` | CharacterBody2D，8 方向移动 | `ray_cast_2d`, `last_direction`, `ray_length`, `SPEED=300` |
| `player/player_data.gd` | `PlayerData` | 玩家数据 Resource | `player_name`, `max_hp`, `current_hp`, `inventory: Array[String]` |
| `player/player_data.tres` | — | 默认玩家数据实例 | player_name="Frisk", max_hp=20, current_hp=20 |

### 2.4 交互对象

| 文件路径 | class_name | 功能 | 关键字段 |
|----------|-----------|------|---------|
| `对象/触发对话的基类/NPC，chest/npc_data.gd` | 无（extends StaticBody2D） | NPC 对话控制器 | `dialogue_groups: Array[DialogueGroup]`, `only_once`, `reward_gold`, `item`, `sound`, `current_group_id` |
| `对象/触发对话的基类/区域监测zone/zone_trigger_data.gd` | 无（extends Area2D） | 区域触发对话（旁白） | `dialogue_groups`, `only_once`, `reward_gold`, `item`, `sound`, `current_group_id` |
| `对象/箱子基类/chest_data.gd` | 无（extends StaticBody2D） | 宝箱 | `sprite`, `first_open_dialogue`, `empty_dialogue`, `only_once`, `reward_gold`, `item`, `sound`, `has_been_opened` |

### 2.5 门系统

| 文件路径 | class_name | 功能 | 关键字段 |
|----------|-----------|------|---------|
| `对象/door门/门的脚本/自动门/autodoor.gd` | 无（extends Area2D） | 自动门（碰撞即传送） | `target_scene`, `spawn_target`, `transition_data` |
| `对象/door门/门的脚本/交互门/interactdoor.gd` | 无（extends Area2D） | 交互门（按交互键传送） | `target_scene`, `spawn_target`, `transition_data` |
| `对象/door门/门的脚本/切换shader/SceneTransition.gd` | 无（autoload `SceneTransition`，CanvasLayer） | 场景切换管理器 | `fade_time`, `color`, `SFX_OPEN`, `SFX_CLOSE` |
| `对象/door门/门的脚本/切换shader/transition_data.gd` | `TransitionData` | 过渡数据 Resource | `open_sound`, `close_sound`, `fade_time`, `color`, `type` (FADE/SHADER), `shader_material` |
| `对象/door门/门的脚本/切换shader/TransitionShader.gd` | `TransitionOverlay`（autoload `Transition`，CanvasLayer） | 黑屏叠加层 | — |

### 2.6 project.godot 自动加载（Autoloads）

```ini
DialogueUI   ="*uid://b6xwb5u6e2vll"    # dialogue_manager.gd — 对话 UI
Global       ="*uid://ckh6730jdqbqm"    # global.gd — 全局状态
Transition   ="*uid://dohm0tjb1jcje"    # TransitionShader.gd — 黑屏叠加
SceneTransition="*uid://bqvywx71sjjkb"  # SceneTransition.gd — 场景切换
```

### 2.7 场景与预制体

| 文件 | 说明 |
|------|------|
| `scene/test_room.tscn` | 主测试场景（设为默认启动） |
| `scene/Aroom.tscn` | A 房间场景 |
| `player/player.tscn` | 玩家预制体 |
| `对象/触发对话的基类/NPC，chest/npc.tscn` | NPC 预制体（StaticBody2D + npc_data.gd） |
| `对象/触发对话的基类/区域监测zone/zone_trigger.tscn` | 区域触发器预制体 |
| `对象/箱子基类/chest.tscn` | 宝箱预制体 |
| `对象/door门/门的脚本/自动门/autodoor.tscn` | 自动门预制体 |
| `对象/door门/门的脚本/交互门/interactdoor.tscn` | 交互门预制体 |
| `对象/door门/门的脚本/切换shader/canvas_layer.tscn` | CanvasLayer 切换预制体 |
| `对象/door门/门的脚本/切换shader/黑屏过渡效果.tscn` | Transition autoload 场景 |
| `dialogue_script/DialogueUI.tscn` | DialogueUI autoload 场景 |
| `dialogue_script/ChoiceItem.tscn` | 单个选项 UI 预制体 |

### 2.8 对话资源文件（dialogues/）

所有 `.tres` 都是 `DialogueGroup` 实例。关键示例：
- `toriel_test0.tres` / `toriel_test1.tres` — 正向羊妈对话试写
- `leave_ruins_end.tres` — 羊妈拒绝离别完整长对话（23 句）
- `四个选项的对话.tres` — 四选项示例
- `choice_demo_*.tres` — 选项系统完整演示链（intro → snap_free → snap_blocked → wobble → end）
- `bbcode_demo.tres` — Godot RichTextLabel 内置 BBCode 全效果演示
- `羊妈测试对话/new_resource*.tres` — 羊妈选项分支对话树

---

## 3. ARCHITECTURE PATTERNS —— 架构模式

### 3.1 "最小正交组件" 哲学

每个类只负责极小范围的功能，通过组合而非继承来实现复杂性：

- `Dialogue` = 一句对话（文本 + 头像 + 效果）
- `DialogueGroup` = 一组对话 + 路由（id/next_id/choices/flags）
- `npc_data.gd` = ID 匹配器 + interact() 入口
- `zone_trigger_data.gd` = 碰撞检测 + ID 匹配器
- `dialogue_manager.gd` = 纯渲染器（打字机 + 效果 + 选项 UI）

### 3.2 旗帜系统（Flags）

**存储位置**: `Global.flags: Dictionary`（全局字典）

**设置旗帜**（`set_flag`）:
```gdscript
# 在 dialogue_group.gd 中定义
@export var set_flag: String = ""
# 多个旗帜用英文半角逗号分隔： "flag1,flag2,flag3"
# dialogue_manager.gd 在 _finish_dialogue() 中调用：
Global.set_flag(main_dialogue.set_flag)
```

**检查旗帜**（`require_flag`）:
```gdscript
# 在 dialogue_group.gd 中定义
@export var require_flag: String = ""
# 多个旗帜用英文半角逗号分隔，全为 true 才通过（AND 逻辑）
# npc_data.gd 和 zone_trigger_data.gd 的 _on_broadcast() 中：
func _check_flags(flag_str: String) -> bool:
	if flag_str == "":
		return true
	for f in flag_str.split(","):
		if not Global.has_flag(f.strip_edges()):
			return false
	return true
```

**旗帜路由逻辑**: 当 `Global.dialogue_broadcast.emit(next_id)` 发射时，所有监听该信号的 NPC/Zone 都会收到。它们各自查找自己 `dialogue_groups` 数组中 ID 匹配且 `require_flag` 通过的那个 Group。**只有匹配到的那一个对象会响应**，其他对象静默忽略。

### 3.3 ID 链系统

```
┌──────────────────────────────────────────────────────┐
│  Group "A1" ──next_id──▶ Group "B2" ──next_id──▶ ... │
│                choices ──▶ Group "C1"                 │
│                choices ──▶ Group "D1"                 │
└──────────────────────────────────────────────────────┘
```

**路由流程**:
1. 玩家交互 NPC → `npc_data.interact()` → `DialogueUI.start_dialogue(group)`
2. 对话结束后 → `_finish_dialogue()` → `Global.dialogue_broadcast.emit(main_dialogue.next_id)`
3. 对话有选项时 → 选项前先显示 `_show_choices()` → 确认后 `_confirm_choice()` → `Global.dialogue_broadcast.emit(choice_next_ids[index])`
4. 所有监听者（同一 NPC 的 `_on_broadcast` 回调）收到信号 → `_find_group(next_id)` → 若在自己的 `dialogue_groups` 中找到，则更新 `current_group_id`

**关键设计**: ID 在所有 NPC 之间是全局共享的，但每个对象只在自己的 `dialogue_groups` 数组中查找。这允许多个 NPC 有重叠的 ID 命名空间——因为 broadcast 后只有包含该 ID 的对象会响应。

**选项的 `next_id` 惩罚机制**: 如果选项页面从未导航（`choices_first_nav == true`）就按了确认键，不会选择任何选项分支，而是走 `group.next_id` 作为惩罚路线。这在 `_confirm_choice()` 第 345-351 行实现。

### 3.4 环境叙事五件套（per-Dialogue narration switches）

以下五个字段定义在 `Dialogue` Resource 中，共同协作实现环境叙事：

| 字段 | 默认值 | 作用 | 协作关系 |
|------|--------|------|---------|
| `position_up` | `false` | 对话框移到屏幕顶部 | `_move_ui_to_top()` / `_move_ui_to_bottom()`，发送 `dialogue_line_reached` 信号 |
| `can_act` | `false` | 这句对话期间玩家能否移动 | `Global.can_act = dialogue.can_act`（在 `display_next_dialogue` 第 156 行） |
| `stay_duration` | `0.0` | 对话结束后的强制停留时间 | 与 `can_skip=false` 强制绑定；`_stay_active` 标志驱动 `_process` 计时器 |
| `can_skip` | `true` | 打字过程中能否跳过快进 | 若 `false`，打字过程中的交互键被忽略（第 135-136 行） |
| `auto_continue` | `false` | 打字完成后自动推进下一句 | `_stay_auto_advance` 控制；`stay_duration>0` 时优先级更高 |
| `hide_end_hint` | `false` | 隐藏句末闪烁小光标 | 配合 `stay_duration` 使用更佳 |
| `silent` | `false` | 不显示对话框，不播放打字声 | 必须配合其他字段使用；目前 emit `dialogue_line_reached` 但不显示 UI |

---

## 4. IMPLEMENTATION TRICKS —— 实现细节与踩坑经验

### 4.1 CanvasLayer 解决方案

**问题**: 相机（Camera2D）移动时对话框 UI 跟着抖动。

**解决**: 在 `DialogueUI.tscn` 中，整个 UI 容器挂在了 `CanvasLayer` 节点下（`$CanvasLayer/container/...`），使得 UI 脱离相机坐标系，不受相机移动影响。

**重要**: `dialogue_manager.gd` 在所有 `@onready` 引用中都用了 `$CanvasLayer/container/...` 路径。文件中保留了原始引用（无 CanvasLayer 时的 `$container/...`）作为注释，用 Ctrl+K 切换。

### 4.2 container.visible vs self.visible

**关键区别**: 
- `self.visible = false` 会导致整个节点（包括子节点）不再接收 `_unhandled_input`，对话推进中断。
- `container.visible = false` 只隐藏 UI 面板，节点本身仍在接收输入。

**在代码中的体现**:
- `_ready()` 中：`container.visible = false`（初始隐藏 UI，但不阻止 autoload 节点存活）
- `_finish_dialogue()` 第 280 行：`container.visible = false`（对话结束影藏 UI）
- `start_dialogue()` 第 538 行：`container.visible = true`（对话开始显示 UI）
- `_unhandled_input()` 第 576 行：`if not container.visible: return`（UI 不可见时忽略输入）

### 4.3 _stay_active 计时器

**作用**: 实现 `stay_duration` 的对话强制停留。

**实现**（dialogue_manager.gd 第 554-562 行）:
```gdscript
func _process(delta: float) -> void:
	if not _stay_active:
		return
	_stay_timer += delta
	if _stay_timer >= _stay_duration:
		_stay_active = false
		if _stay_auto_advance:
			display_next_dialogue()
```

- 当 `stay_duration > 0` 时，打字完成后设置 `_stay_active = true`，`_stay_timer = 0`
- `_process` 每帧累加计时器
- 到时间后标志复位，若 `auto_continue=true` 则自动推进
- **期间交互键被 `_stay_active` 挡在 `_unhandled_input` 第 591 行**

### 4.4 NPC 守卫（防止对话期间再次触发）

**位置**: `npc_data.gd` 第 21 行和 `zone_trigger_data.gd` 第 25-26 行：
```gdscript
if DialogueUI.container.visible:
	return
```
这阻止了在对话进行中通过碰撞（zone_trigger）或再次按交互键（NPC）重复触发对话。

### 4.5 门声时机技巧

**场景**: 玩家从 A 房间通过门传送到 B 房间。

**流程**:
1. 门触发 → `SceneTransition.go_to(target_scene, spawn_target, transition_data)`
2. `SceneTransition` 先渐变到黑屏 → 播放关门声 → `change_scene_to_file` → 渐变恢复 → 播放开门声
3. `_on_scene_changed()` 回调中：找到玩家节点 → **直接设置 `player.global_position = marker.global_position`**

**关键设计**: `Global.pending_spawn_pos` 现在**几乎不用**了。原来设计是通过 `Global.pending_spawn_pos` 传递位置，但现在 `SceneTransition._on_scene_changed()` 直接操作 player 的 global_position。不过 `player.gd` 的 `_ready()` 仍保留了检查：
```gdscript
if Global.pending_spawn_pos != Vector2.ZERO:
	global_position = Global.pending_spawn_pos
	Global.pending_spawn_pos = Vector2.ZERO
```
这个分支目前不会被触发到，因为 `SceneTransition` 在场景切换完成后才设置位置，远早于 `player._ready()` 执行完毕。但如果需要更复杂的 spawn 逻辑，这个变量可以作为 flag 使用。

### 4.6 对话广播信号流

```
npc_data.interact()
  → DialogueUI.start_dialogue(group)
  → display_next_dialogue() 循环播放 dialogue_list
  → 如果有选项 → _show_choices() → 等待玩家输入 → _confirm_choice()
	→ Global.dialogue_broadcast.emit(choice_next_ids[index])
  → 否则 → _finish_dialogue()
	→ Global.dialogue_broadcast.emit(next_id)
  → 同一 NPC 的 _on_broadcast() 监听到信号
	→ 查找下一个匹配 ID 的 Group → 更新 current_group_id
```

### 4.7 选项的空白确认

**文件**: `dialogue_manager.gd` 第 343-351 行

如果选项 never navigated（`choices_first_nav == true`）且 `next_id != ""`，则空白确认会：
1. 不选择任何选项
2. 直接走 `group.next_id` 作为惩罚路线
3. 发射 `dialogue_broadcast`
4. Emit `dialogue_continue`

这是一个"不选也是一种选择"的设计。

---

## 5. CURRENT STATE —— 当前已完成功能

### ✅ 已实现

1. **对话系统** — 打字机效果、BBCode 全部效果（粗斜下划、颜色、字号、字体切换、shake/wave/tornado/rainbow/pulse/fade/ghost/dropcap/align）、头像（左右）、说话者名字
2. **选项系统** — 2~4 选项、红心动效（Slide/Snap/Wobble）、方向导航、确认音效
3. **环境叙事** — `position_up`（顶部对话框）、`can_act`、`stay_duration`、`can_skip`、`auto_continue`、`hide_end_hint`、`silent`
4. **对话框效果器** — Shake（震动）、Wobble（摇摆）、`persist_effects`（效果跨句延续）
5. **旗帜系统** — `set_flag` / `require_flag`（逗号分隔 AND 逻辑）
6. **ID 链系统** — `id` / `next_id` / `choice_next_ids` + `Global.dialogue_broadcast`
7. **门传送** — 自动门（碰撞）和交互门（按键），黑屏渐变过渡，spawn 位置匹配
8. **CanvasLayer UI** — 对话框脱离相机，不受相机移动影响
9. **silent 对话分支** — 已发 `dialogue_line_reached` 信号（底层已通），UI 正确隐藏
10. **Global.dialogue_line_reached 信号** — 每次 dialogue 的 line_index 到达时发射

---

## 6. IMMEDIATE TODO —— 立即待办（优先级排序）

### 🔴 P0: silent 对话完整实现（现在只差一步）

**背景**: `silent = true` 的 Dialogue 已经在 `display_next_dialogue()` 第 114-126 行有分支：
```gdscript
if dialogue.silent:
	Global.dialogue_line_reached.emit(main_dialogue.id, dialogue_index)
	Global.can_act = dialogue.can_act
	dialogue_index += 1
	if dialogue.stay_duration > 0.0:
		_stay_active = true
		_stay_timer = 0.0
		_stay_duration = dialogue.stay_duration
		_stay_auto_advance = true
	else:
		await get_tree().create_timer(0.1).timeout
		display_next_dialogue()
	return
```

**缺什么**: 没有对象监听 `dialogue_line_reached` 信号。需要在需要响应的 NPC/Zone 中添加 handler。

**需要改动**:
1. **`npc_data.gd`** — 在 `_ready()` 中添加：`Global.dialogue_line_reached.connect(_on_line_reached)`
2. **`zone_trigger_data.gd`** — 同上
3. **新增 `_on_line_reached(group_id: String, line_index: int)` 回调** — 在此回调中执行事件（如移动 NPC、播放动画等）

**silent 对话的完整语义**: silent 对话仍然推进 index、检查 stay_duration、控制 can_act、并最终走 `_finish_dialogue()`。它只是不显示 UI 而已。这意味着可以用 silent 对话组来定义"纯事件序列"。

---

### 🔴 P1: only_once NPC 实现

**当前状态**: `npc_data.gd` 有 `only_once: bool = false` 字段，但 `_on_dialogue_finished()` 中没有使用它。

**改动**: 在 `npc_data.gd` 的 `_on_dialogue_finished()` 中添加 4 行：
```gdscript
func _on_dialogue_finished() -> void:
	if only_once:
		# 防止再次交互：移除碰撞检测或禁用交互
		queue_free()  # 或 set_process(false) + hide()
		return
	if DialogueUI.dialogue_continue.is_connected(_on_dialogue_continue):
		DialogueUI.dialogue_continue.disconnect(_on_dialogue_continue)
```

同样在 `zone_trigger_data.gd` 的 `_on_dialogue_finished()` 中添加。

---

### 🔴 P2: EventTrigger Resource（新 .tres 类型）

**设计**: 创建一个新 Resource 类 `EventTrigger`，用于定义"对话到达某句时触发的事件"。

```gdscript
# 新文件: dialogue_script/event_trigger.gd
extends Resource
class_name EventTrigger

enum Action { NONE, MOVE_NPC, PLAY_ANIM, PLAY_SOUND, SET_FLAG, TELEPORT_PLAYER }

@export var dialogue_id: String = ""       # 哪个对话组的 ID
@export var line_index: int = 0           # 哪一句对话触发
@export var action: Action = Action.NONE  # 触发什么动作
@export var target_node_path: NodePath    # 目标节点
@export var extra_data: String = ""       # 额外数据（如移动目标坐标）
```

---

### 🔴 P3: NPC EventTrigger[] 数组 + _on_line_reached handler

在 `npc_data.gd` 和 `zone_trigger_data.gd` 中添加：
```gdscript
@export var event_triggers: Array[EventTrigger] = []

func _on_line_reached(group_id: String, line_index: int) -> void:
	for trigger in event_triggers:
		if trigger.dialogue_id == group_id and trigger.line_index == line_index:
			_execute_trigger(trigger)
```

---

### 🟡 P4: BGM autoload

创建 `global/bgm.gd`，注册为 autoload `BGM`：
- `play(track)` / `stop()` / `fade_to(track, duration)`
- 在 `project.godot` [autoload] 中添加

---

### 🟡 P5: Player 四方向行走动画

`player.gd` 目前无动画逻辑。需要：
- 根据 `last_direction` 切换 Sprite2D 纹理/sprite sheet
- 添加 `AnimatedSprite2D` 或通过代码切换 frame

---

### 🟡 P6: Player 背包/状态 UI

创建独立 UI 层（CanvasLayer），显示：
- `Global.player.inventory` 的物品
- HP 条（`current_hp / max_hp`）
- 玩家名称

---

### 🟢 P7: Reward 系统集成

`chest_data.gd` 已经有 `reward_gold` 和 `item: Array` 字段，但 `_on_dialogue_finished()` 中只有硬编码的 `match` 物品。需要：
- 在 `chest_data._on_dialogue_finished()` 中读取 `item` 数组做通用处理
- 同样在 `npc_data.gd`/`zone_trigger_data.gd` 中实现

---

### 🟢 P8: Save 系统

需要实现存档/读档：
- 保存 `Global.flags`、`Global.player` 数据、当前场景和玩家位置
- 使用 Godot 的 `ConfigFile` 或自定义 `.json` 格式

---

### 🟢 P9: WorldTimer + 天气 flags

需要一个全局计时器（游戏内时间），可以驱动天气变化、NPC 出现/消失、昼夜循环等。
- `Global.world_time: float`（游戏内分钟数）
- `Global.weather: String`（"clear"/"rain"/"snow" 等）
- 在 `require_flag` 中可以使用 `"rain,night"` 来限制对话出现时机

---

## 7. CODING CONVENTIONS —— 编码约定

### 必须遵守

1. **中文注释 OK** — 现有代码全用中文注释，继续使用中文。
2. **class_name 全局注册** — 所有 Resource 类都用 `class_name`，方便在 Godot 编辑器的下拉菜单中创建。
3. **.tres Resource 驱动** — 对话数据、玩家数据、过渡数据全部用 `.tres` 文件定义，不硬编码。
4. **不要硬编码路径** — 使用 `@export` + Inspector 赋值，不使用 `preload("res://...")` 传递数据（`preload` 只用于默认值）。
5. **@export everything** — 所有可配置字段都加 `@export`，让策划/设计师可在编辑器直接修改。
6. **用户偏好自己写代码** — 用户倾向由 AI 提供指导和代码片段，自己动手写。这意味著 AI 应该给出**精确的行号和改动内容**，而非大段重写文件。

### 风格偏好

- 注释用 `##`（文档注释）用于 public 字段，`#` 用于行内说明
- 信号和函数的命名使用 `snake_case`
- 文件组织：按功能分目录（`dialogue_script/`、`player/`、`global/`、`对象/`）
- 预制体 + 脚本分离：`.tscn` + `.gd` 一一对应

---

## 附录 A: Global 信号完整契约

```gdscript
# global.gd
signal dialogue_broadcast(next_id: String)
# 当对话组完成或选项确认时发射
# next_id 是被广播的目标对话组 ID
# 所有 NPC 和 Zone 都会收到，但只有 id 匹配的那个响应

signal dialogue_line_reached(group_id: String, line_index: int)
# 当 Dialogue 的 silent=true 时，或未来需要逐句事件触发时发射
# group_id 是当前 DialogueGroup 的 id
# line_index 是当前 dialogue_list 中的索引（从 0 开始）
```

## 附录 B: 门传送完整数据流

```
门节点 (autodoor/interactdoor)
  → SceneTransition.go_to(target_scene, spawn_target, transition_data)
  → _fade_to_black(data)
  → 播放 open_sound（如果有）
  → get_tree().change_scene_to_file(target_scene)
  → _on_scene_changed() 回调
	→ 找到 player 节点（get_first_node_in_group("player")）
	→ 在新场景中查找 spawn_target 名称的 Marker2D
	→ player.global_position = marker.global_position
	→ player.velocity = Vector2.ZERO
  → _fade_from_black(data)
  → 播放 close_sound（如果有）
```

门节点下的 `Marker2D` 子节点就是 spawn 位置。命名对应关系：
- A 房间的门 → spawn_target = "Troom_spawn_point" → test_room 中 Door2 下的同名 Marker2D
- test_room 的门 → spawn_target = "Aroom_spawn_point" → Aroom 中 Door2 下的同名 Marker2D

---

> **文档生成时间**: 2026-07-23  
> **下次 session 启动建议**: 先阅读本文档 1-3 节理解架构，再从第 6 节选一个 P0/P1 任务开始。
