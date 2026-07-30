extends Area2D
##目标场景的文件地址

@export_group("Animation")
@export var open_sprite_anim : String = "open"
@export var close_sprite_anim :String = "close"
@export var open_normal_anim : String = ""
@export var close_normal_anim: String = ""
@export var idle_anim: String = ""
@export_group("Normal")
@export_file("*.tscn") var target_scene: String = ""
##目标门的出生坐标。一定要注意不是当前门的出生坐标！！！！！！！
@export var spawn_target: String = ""
##进出门的数据
@export var transition_data: TransitionData
##出门动画,一定要注意！！一定要注意！！一定要注意！！这是给玩家从这个门出去的门的出门动画！！！不是当前门的动画！！！别搞错了！！！！！
@export_enum("idle_forward", "idle_back", "idle_left", "idle_right") var player_exit_animation: String = "idle_forward"
##自动门：true=碰撞触发，false=按交互键触发
@export var auto_trigger: bool = true
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_sprite_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_sprite_2d_2: AnimatedSprite2D = $AnimatedSprite2D2

var _busy: bool = false

func _ready() -> void:
	if auto_trigger:
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if _busy or target_scene == "":
		return
	_busy = true
	Global.can_act = false
	Global.pending_exit_animation = player_exit_animation
	_play_door_open_animations()
	SceneTransition.go_to(target_scene, spawn_target, transition_data)

func _unhandled_input(event: InputEvent) -> void:
	if auto_trigger:
		return
	if _busy:
		return
	if not event.is_action_pressed("interact"):
		return
	if not is_player_near():
		return
	_busy = true
	Global.can_act = false
	Global.pending_exit_animation = player_exit_animation
	_play_door_open_animations()
	SceneTransition.go_to(target_scene, spawn_target, transition_data)

func is_player_near() -> bool:
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false
	
func _play_door_open_animations() -> void:
	if open_sprite_anim != "" and has_node("AnimatedSprite2D"):
		animation_sprite_player.play(open_sprite_anim)
	if open_normal_anim != "" and has_node("AnimationPlayer"):
		animation_player.play(open_normal_anim)
func _play_door_close_animations() -> void:
	if close_sprite_anim != "" and has_node("AnimatedSprite2D"):
		animation_sprite_player.play(close_sprite_anim)
		if idle_anim != "":
			animation_sprite_player.animation_finished.connect(_play_idle, CONNECT_ONE_SHOT)
	if close_normal_anim != "" and has_node("AnimationPlayer"):
		animation_player.play(close_normal_anim)
		if idle_anim != "":
			animation_player.animation_finished.connect(_play_idle, CONNECT_ONE_SHOT)
func _play_idle(_name: StringName = &"") -> void:
	if idle_anim != "" and has_node("AnimatedSprite2D") and animation_sprite_player.animation != idle_anim:
		animation_sprite_player.play(idle_anim)
