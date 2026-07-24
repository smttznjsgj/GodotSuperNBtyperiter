class_name Player
extends CharacterBody2D
##初始动画判断朝向，设置了一些常用的
@export_enum("idle_forward", "idle_back", "idle_left", "idle_right")  var start_anim: String = "idle_forward"
##特殊起始动画，若其不为空，则顶替掉上面的四个选项的start_anim
@export var special_start_anim: String = ""
@export_group("NormalAction")
@export var idle : Array[String]
@export_group("DialogueAction")
@export var ActionGroup : Array[Action] 


@onready var ray_cast_2d: RayCast2D = $Raycast2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var last_direction := Vector2.RIGHT
var ray_length: int = 45
var _anim_locked: bool = true
var _current_anim: String = "idle_forward"
const SPEED = 300.0

func _physics_process(delta: float) -> void:
	if not Global.can_act:
		return
	
	var input_dir :=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	if input_dir != Vector2.ZERO:
		_anim_locked = false
		last_direction = input_dir
		ray_cast_2d.target_position = input_dir * ray_length
		_current_anim = _get_direction_name("move_")
	elif _anim_locked :
		pass
	else:
		_current_anim = _get_direction_name("idle_")
	if _current_anim != animated_sprite.animation:
		animated_sprite.play(_current_anim)
	var direction_x := Input.get_axis("ui_left", "ui_right")
	var direction_y := Input.get_axis("ui_up", "ui_down")
	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if direction_y:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y,0,SPEED)
		
	move_and_slide()

func _input(event: InputEvent) -> void:
	if not Global.can_act :
		return
	
	if event.is_action_pressed("interact"):
		print("act!")
		if ray_cast_2d.is_colliding():
			var target = ray_cast_2d.get_collider()
			if target is Area2D:
				target = target.get_parent()
			if target.has_method("interact"):
				target.interact()
				get_viewport().set_input_as_handled()
func _get_direction_name(prefix: String) -> String:
	if abs(last_direction.x) > abs(last_direction.y):
		return prefix + ("left" if last_direction.x < 0 else "right")
	else:
		return prefix + ("back" if last_direction.y < 0 else "forward")
func _ready() -> void:
	if special_start_anim != "":
		start_anim = special_start_anim
	if Global.pending_exit_animation and Global.pending_exit_animation != "idle_forward":
		_current_anim = Global.pending_exit_animation
	else:
		_current_anim = start_anim
	animated_sprite.play(_current_anim)
	_anim_locked = true
	Global.pending_exit_animation = "idle_forward"
	Global.dialogue_line_reached.connect(_on_line_reached)
	add_to_group("player")
	print("spawn pos: ", Global.pending_spawn_pos)
	if Global.pending_spawn_pos != Vector2.ZERO:
		global_position = Global.pending_spawn_pos
		Global.pending_spawn_pos = Vector2.ZERO
	
func _on_line_reached(group_id: String, line_index: int) -> void:
	for action in ActionGroup:
		if action.dialogue_id == group_id and action.line_index == line_index:
			if action.animation_name != "" and has_node("AnimationPlayer"):
				animation_player.play(action.animation_name)









#
