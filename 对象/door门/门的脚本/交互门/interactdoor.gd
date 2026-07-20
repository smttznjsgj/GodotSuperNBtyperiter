extends Area2D

@export_file("*.tscn") var target_scene : String = ""
@export var spawn_target : String = ""
@export var transition_data: TransitionData
var _trigger = false
func _unhandled_input(event: InputEvent) -> void:
	if _trigger == true :
		return
	if not event.is_action_pressed("interact"):
		return
	if not is_player_near():
		return
	await SceneTransition.go_to(target_scene,spawn_target,transition_data)
		
		

func is_player_near():
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false
