extends StaticBody2D
#NPC，复杂的箱子用这个
@export_group("Normal")

@export var dialogue_groups : Array[DialogueGroup]
##勾选后改为区域碰撞触发（旁白用），不勾选则按交互键触发
@export var use_zone_trigger: bool = false

@export_group("Advanced")
@export var only_once :bool = false
@export var reward_gold : int
@export var item : Array
@export var sound : Resource

@export_group("NormalAction")
@export var start_sprite_anim : String
@export var start_normal_anim : String
@export_group("DialogueAction")
@export var ActionGroup : Array[Action] 

var current_group_id: String = ""

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_sprite_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast_area: Area2D = $raycast_area_blue
@onready var zone_area: Area2D = $zone_trigger_white

func _ready() -> void:
	if dialogue_groups.size() > 0:
		current_group_id = dialogue_groups[0].id
	Global.dialogue_broadcast.connect(_on_broadcast)
	Global.dialogue_line_reached.connect(_on_line_reached)
	if use_zone_trigger:
		raycast_area.monitoring = false
		zone_area.monitoring = true
		zone_area.body_entered.connect(_on_body_entered)
	else:
		zone_area.monitoring = false
	if start_sprite_anim != "":
		animation_sprite_player.play(start_sprite_anim)
	if start_normal_anim != "":
		animation_player.play(start_normal_anim)
func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	var group := _find_group(current_group_id)
	if group:
		DialogueUI.start_dialogue(group)
		DialogueUI.dialogue_finished.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
		DialogueUI.dialogue_continue.connect(_on_dialogue_continue, CONNECT_ONE_SHOT)
func interact() -> void:
	if use_zone_trigger:
		return
	if DialogueUI.container.visible:
		return
	var group := _find_group(current_group_id)
	if group:
		DialogueUI.start_dialogue(group)
		DialogueUI.dialogue_finished.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
		DialogueUI.dialogue_continue.connect(_on_dialogue_continue, CONNECT_ONE_SHOT)
func _on_dialogue_finished() -> void:
	if only_once:
		queue_free()
		return
	if DialogueUI.dialogue_continue.is_connected(_on_dialogue_continue):
		DialogueUI.dialogue_continue.disconnect(_on_dialogue_continue)
func _on_dialogue_continue() -> void:
	var group := _find_group(current_group_id)
	if group:
		DialogueUI.dialogue_continue.connect(_on_dialogue_continue, CONNECT_ONE_SHOT)
		DialogueUI.start_dialogue(group)
#func _on_dialogue_finished() -> void:
	#var finished := _find_group(current_group_id)
	#if finished and finished.next_id != "":
		#current_group_id = finished.next_id
		
func _find_group(target_id: String) -> DialogueGroup:
	for g in dialogue_groups:
		if g == null:
			continue
		if g.id == target_id:
			return g
	return null

func _on_broadcast(next_id: String) -> void:
	if next_id == "":
		return
	var group := _find_group(next_id)
	if group and _check_flags(group.require_flag):
		current_group_id = next_id
		
func _check_flags(flag_str: String) -> bool:
	if flag_str == "":
		return true
	for f in flag_str.split(","):
		if not Global.has_flag(f.strip_edges()):
			return false
	return true
func _on_line_reached(group_id: String, line_index: int) -> void:
	for action in ActionGroup:
		if action.dialogue_id == group_id and action.line_index == line_index:
			if action.animation_name == "":
				continue
			match action.player_node:
				Action.PlayerNode.NORMAL_ANIMATION_PLAYER:
					if has_node("AnimationPlayer"):
						animation_player.play(action.animation_name)
				Action.PlayerNode.SPRITE_ANIMATIONPLAYER:
					if has_node("AnimatedSprite2D"):
						animation_sprite_player.play(action.animation_name)
