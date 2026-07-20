extends Area2D

@export_file("*.tscn") var target_scene: String = ""
@export var spawn_target: String = ""
@export var transition_data: TransitionData

var _busy: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if _busy or target_scene == "":
		return
	_busy = true
	SceneTransition.go_to(target_scene, spawn_target, transition_data)
