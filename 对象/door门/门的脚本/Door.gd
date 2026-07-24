extends Area2D
##目标场景的文件地址
@export_file("*.tscn") var target_scene: String = ""
##目标门的出生坐标。一定要注意不是当前门的出生坐标！！！！！！！
@export var spawn_target: String = ""
##进出门的数据
@export var transition_data: TransitionData
##出门动画,一定要注意！！一定要注意！！一定要注意！！这是给从这个门出去的门的出门动画！！！不是当前门的动画！！！别搞错了！！！！！
@export_enum("idle_forward", "idle_back", "idle_left", "idle_right") var exit_animation: String = "idle_forward"
##自动门：true=碰撞触发，false=按交互键触发
@export var auto_trigger: bool = true

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
	Global.pending_exit_animation = exit_animation
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
	Global.pending_exit_animation = exit_animation
	SceneTransition.go_to(target_scene, spawn_target, transition_data)

func is_player_near() -> bool:
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false
