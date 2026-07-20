extends CanvasLayer

@export var fade_time  = 0.35
@export var color :Color
@export var SFX_OPEN : AudioStream = preload("res://素材/门声/Farming_Door_Open_Volume_1_1_1.wav")
@export var SFX_CLOSE : AudioStream = preload("res://素材/门声/Farming_Door_Close_Medium_Volume_1_2_1.wav")
var _busy = false
var _spawn_target = ""
var _overlay : ColorRect
func go_to(scene_path: String, spawn_target: String, data: TransitionData) -> void:
	if _busy or scene_path.is_empty():
		return
	_busy = true

	await _fade_to_black(data)
	if data and data.open_sound:
		await _play_stream_and_wait(data.open_sound)

	_spawn_target = spawn_target
	get_tree().change_scene_to_file(scene_path)

	await _fade_from_black(data)
	if data and data.close_sound:
		_play_stream_once(data.close_sound)

	_busy = false

func _play_stream_and_wait(stream: AudioStream):
	if stream == null :
		return
	var player : AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	player.play()
	await player.finished
	player.queue_free()
	
func _play_stream_once(stream: AudioStream):
	if stream == null :
		return
	var player : AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


func _fade_to_black(data: TransitionData):
	var dur = data.fade_time if data else 0.35
	var col = data.color if data else Color.BLACK
	await _fade_alpha(1.0, col, dur)

func _fade_from_black(data: TransitionData):
	var dur = data.fade_time if data else 0.35
	var col = data.color if data else Color.BLACK
	await _fade_alpha(0.0, col, dur)

func _fade_alpha(target_alpha: float, fade_color: Color, duration: float):
	_overlay.color = Color(fade_color.r, fade_color.g, fade_color.b, _overlay.color.a)
	var tween := create_tween()
	tween.tween_property(_overlay, "color:a", target_alpha, duration)
	await tween.finished
func _ready()-> void:
	layer = 100
	_overlay = ColorRect.new()
	_overlay.color = Color(0,0,0,0)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)
	get_tree().scene_changed.connect(_on_scene_changed)
	
func _on_scene_changed():
	var root = get_tree().current_scene
	var player = get_tree().get_first_node_in_group("player")
	if player == null :
		return
	var marker = root.find_child(_spawn_target,true,false)
	if !marker == null :
		player.global_position = marker.global_position
		if player is CharacterBody2D:
			player.velocity = Vector2.ZERO
			
	_spawn_target = ""





#kkk
			
