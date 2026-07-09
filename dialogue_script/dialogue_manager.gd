extends Control

@export_group("UI")
@export var character_name_text : Label
@export var text_box : RichTextLabel
@export var left_avatar: TextureRect
@export var right_avatar : TextureRect

@onready var typing_audio: AudioStreamPlayer = $TypingAudio
@onready var dialogue_box: HBoxContainer = $container/DialogueBox

@onready var end_hint: Label = %end_hint
@onready var container: Control = $container

@onready var shake_audio: AudioStreamPlayer = $ShakeAudio
@onready var choice_audio: AudioStreamPlayer = $ChoiceAudio
@onready var choice_items: Array[ChoiceItem] = [
	$container/Choicecontainer/Item0,
	$container/Choicecontainer/Item1,
	$container/Choicecontainer/Item2,
	$container/Choicecontainer/Item3
]
@onready var choice_marker: Control = $container/Choicecontainer/Marker
@onready var visual_marker: Control = $container/Choicecontainer/visualmarker

var choices_active: bool = false
var current_choice_index: int = 0
var choices_first_nav: bool = true
var heart_tween: Tween
## SnapEffect 追踪红心屏幕坐标，用于滑动传送的起点
var _heart_global_tracker: Vector2 = Vector2.ZERO
@export var heart_move_duration: float = 0.08

@export_group("dialogue")
@export var main_dialogue :DialogueGroup

@export_group("Advanced")


signal dialogue_finished
signal dialogue_continue#给选项功能用的

var default_typing_sound : AudioStream = preload("res://素材/声音/SND_TXT1.wav")
var current_typing_sound : AudioStream
var typing_tween : Tween
var dialogue_index : int = 0
var blink_tween: Tween
var effect_tween : Tween
var persistent_effect_running: bool = false

func display_next_dialogue() -> void:
	end_hint.modulate.a = 0.0
	if blink_tween and blink_tween.is_running():
		blink_tween.kill()
	
	if effect_tween and effect_tween.is_running() and not persistent_effect_running:
		effect_tween.kill()
		persistent_effect_running = false
		var settle = get_tree().create_tween()
		settle.set_ease(Tween.EASE_OUT)
		settle.set_trans(Tween.TRANS_ELASTIC)
		settle.tween_property(container, "position:x", 0.0, 0.5)
		settle.parallel().tween_property(container, "position:y", 0.0, 0.5)
		settle.parallel().tween_property(container, "rotation_degrees", 0.0, 0.5)
		settle.tween_callback(display_next_dialogue)
		return
	
	#if dialogue_index >= len(main_dialogue.dialogue_list):
		#if effect_tween and effect_tween.is_running():
			#effect_tween.kill()
		#persistent_effect_running = false
		#container.position = Vector2.ZERO
		#container.rotation_degrees = 0.0
		#Global.can_act = true
		#visible = false
		#Global.set_flag(main_dialogue.set_flag)
		#Global.dialogue_broadcast.emit(main_dialogue.next_id)
		#dialogue_finished.emit()
		#return万一改错了用这个
	
	if dialogue_index >= len(main_dialogue.dialogue_list):
		if effect_tween and effect_tween.is_running():
			effect_tween.kill()
		if not main_dialogue.choices.is_empty():
			_show_choices(main_dialogue)
			return
		_finish_dialogue()
		return
	var dialogue := main_dialogue.dialogue_list[dialogue_index]
	var processed_content = dialogue.content.replace("{name}", Global.player.player_name)
	
	if typing_tween and typing_tween.is_running():
		if not dialogue.can_skip:
			return
		var dead_tween = typing_tween
		typing_tween = null
		dead_tween.kill()
		text_box.clear()
		text_box.push_color(dialogue.text_color)
		text_box.push_font(dialogue.text_font)
		text_box.append_text(processed_content)
		text_box.visible_characters = -1
		end_hint.modulate.a = 1.0
		blink_tween = get_tree().create_tween().set_loops()
		blink_tween.tween_property(end_hint, "modulate:a", 0.2, 0.4)
		blink_tween.tween_property(end_hint, "modulate:a", 1.0, 0.4)
		if not persistent_effect_running and effect_tween and effect_tween.is_running():
			dialogue_index += 1
			return
		dialogue_index += 1
		return
	else:
		character_name_text.text = dialogue.character_name
		current_typing_sound = dialogue.typing_sound if dialogue.typing_sound else default_typing_sound
		
		if effect_tween and effect_tween.is_running() and not dialogue.effect.is_empty():
			effect_tween.kill()
			persistent_effect_running = false
		
		if dialogue.effect_sound:
			shake_audio.stream = dialogue.effect_sound
			shake_audio.play()
		
		for ef in dialogue.effect:
			var box = container
			var ox = box.position.x
			var oy = box.position.y
			
			if ef is ShakeEffect:
				var sh = ef as ShakeEffect
				effect_tween = get_tree().create_tween()
				for i in sh.count:
					var shake_sign = 1 if i % 2 == 0 else -1
					effect_tween.tween_property(box, "position:x", ox + sh.magnitude_x * shake_sign, sh.speed)
					effect_tween.tween_property(box, "position:y", oy + sh.magnitude_y * shake_sign, sh.speed)
				effect_tween.tween_property(box, "position:x", ox, sh.speed)
				effect_tween.tween_property(box, "position:y", oy, sh.speed)
			elif ef is WobbleEffect:
				var wo = ef as WobbleEffect
				persistent_effect_running = dialogue.persist_effects
				container.pivot_offset = dialogue_box.position + dialogue_box.size / 2.0
				effect_tween = get_tree().create_tween()
				for i in wo.count:
					var amplitude = wo.rotation * pow(wo.decay, i)
					if amplitude < wo.snap_threshold:
						break
					var wob_sign = 1 if i % 2 == 0 else -1
					effect_tween.tween_property(container, "rotation_degrees", amplitude * wob_sign, wo.speed) \
						.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
				effect_tween.tween_callback(func():
					if wo.fierce_return:
						var st = get_tree().create_tween()
						st.set_ease(Tween.EASE_OUT)
						st.set_trans(Tween.TRANS_ELASTIC)
						st.tween_property(container, "position:x", 0.0, 0.5)
						st.parallel().tween_property(container, "position:y", 0.0, 0.5)
						st.parallel().tween_property(container, "rotation_degrees", 0.0, 0.5)
					else:
						var st = get_tree().create_tween()
						st.set_ease(Tween.EASE_OUT)
						st.set_trans(Tween.TRANS_SINE)
						st.tween_property(container, "rotation_degrees", 0.0, wo.speed * 1.5)
				)
		
		typing_tween = get_tree().create_tween()
		text_box.clear()
		text_box.push_color(dialogue.text_color)
		text_box.push_font(dialogue.text_font)
		text_box.append_text(processed_content)
		var visible_text := _strip_bbcode(processed_content)
		text_box.visible_characters = 0
		
		for i in range(visible_text.length()):
			var idx := i + 1
			typing_tween.tween_callback(func():
				text_box.visible_characters = idx
				if current_typing_sound:
					typing_audio.stream = current_typing_sound
					typing_audio.play()
			).set_delay(dialogue.typing_speed)
			var ch := visible_text[i]
			if ch in [".", "!", "?", "。", "！", "？"]:
				typing_tween.tween_interval(0.4)
			elif ch in [",", "，", ";", "；", ":", "："]:
				typing_tween.tween_interval(0.15)
		typing_tween.tween_callback(func():
			dialogue_index += 1
			if dialogue.auto_continue:
				end_hint.modulate.a = 0.0
				var next := get_tree().create_tween()
				next.tween_interval(0.15)
				next.tween_callback(display_next_dialogue)
			else:
				end_hint.modulate.a = 1.0
				blink_tween = get_tree().create_tween().set_loops()
				blink_tween.tween_property(end_hint, "modulate:a", 0.2, 0.4)
				blink_tween.tween_property(end_hint, "modulate:a", 1.0, 0.4)
		)
		
		if dialogue.show_on_left:
			left_avatar.texture = dialogue.avatar
			right_avatar.texture = null
		else:
			right_avatar.texture = dialogue.avatar
			left_avatar.texture = null
			
	#
#func _finish_dialogue() -> void:
	#persistent_effect_running = false
	#container.position = Vector2.ZERO
	#container.rotation_degrees = 0.0
	#Global.set_flag(main_dialogue.set_flag)
	#Global.dialogue_broadcast.emit(main_dialogue.next_id)
	#Global.can_act = true
	#visible = false
	#dialogue_finished.emit()

func _finish_dialogue(skip_broadcast: bool = false) -> void:
	persistent_effect_running = false
	container.position = Vector2.ZERO
	container.rotation_degrees = 0.0
	Global.set_flag(main_dialogue.set_flag)
	if not skip_broadcast:
		Global.dialogue_broadcast.emit(main_dialogue.next_id)
	Global.can_act = true
	visible = false
	dialogue_finished.emit()
func _show_choices(group: DialogueGroup) -> void:
	if heart_tween and heart_tween.is_running():
		heart_tween.kill()
		# 杀 tween 瞬间读当前位置，覆盖追踪器，下一次滑动从这里起跑
		for item in choice_items:
			if item.heart.visible:
				_heart_global_tracker = item.heart.global_position
				break
	text_box.clear()
	choices_active = true
	for i in choice_items.size():
		if i < group.choices.size() and group.choices[i] != "":
			choice_items[i].set_text(group.choices[i])
			choice_items[i].set_colors(Color.WHITE, group.choice_selected_color)
			choice_items[i].visible = true
		else:
			choice_items[i].visible = false

	# 选一个可见项做初始选中：离 marker 最近的
	current_choice_index = 0
	var best_dist := INF
	var marker_center := _get_marker_center()
	for i in choice_items.size():
		if choice_items[i].visible:
			var d := choice_items[i].get_center().distance_to(marker_center)
			if d < best_dist:
				best_dist = d
				current_choice_index = i

	# 数可见项：单选项直接出红心，多项等第一次导航
	var visible_count := 0
	for item in choice_items:
		if item.visible:
			visible_count += 1
	if visible_count <= 1:
		choices_first_nav = false
		choice_items[current_choice_index].set_selected(true)
		_update_heart_position(choice_items[current_choice_index])
	else:
		choices_first_nav = true
		var effect := group.choice_effect
		if effect is ChoiceSnapEffect:
			_heart_global_tracker = visual_marker.global_position + visual_marker.size / 2.0
			_place_heart_on(choice_items[current_choice_index])
			choice_items[current_choice_index].heart.visible = true
			choice_items[current_choice_index].heart.position = _heart_global_tracker - choice_items[current_choice_index].global_position

func _get_marker_center() -> Vector2:
	return choice_marker.global_position + choice_marker.size / 2.0

func _hide_choices() -> void:
	if heart_tween and heart_tween.is_running():
		heart_tween.kill()
	for item in choice_items:
		item.visible = false
		item.set_selected(false)
func _confirm_choice() -> void:
	var group := main_dialogue
	# 空白确认：从未导航就按了回车 → 走 next_id 惩罚对话
	if choices_first_nav and group.next_id != "":
		_hide_choices()
		choices_active = false
		Global.set_flag(group.set_flag)
		Global.dialogue_broadcast.emit(group.next_id)
		dialogue_continue.emit()
		return
	var index := current_choice_index
	_hide_choices()
	choices_active = false
	choice_audio.stream = main_dialogue.choice_confirm_sound
	choice_audio.play()
	Global.set_flag(group.set_flag)
	if index < group.choice_next_ids.size() and group.choice_next_ids[index] != "":
		Global.dialogue_broadcast.emit(group.choice_next_ids[index])
	dialogue_continue.emit()
func _place_heart_on(item: ChoiceItem) -> void:
	# Heart 绝对定位到该项文字左侧
	var hw := item.heart.size.x
	item.heart.position = Vector2(item.label.position.x - hw - 8.0, item.label.position.y + item.label.size.y / 2.0 - item.heart.size.y / 2.0)



func _update_heart_position(target: ChoiceItem) -> void:
	if heart_tween and heart_tween.is_running():
		heart_tween.kill()
	
	var effect := main_dialogue.choice_effect
	
	if effect == null:
		_place_heart_on(target)
		_heart_global_tracker = target.heart.global_position
		return
	
	if effect is ChoiceSlideEffect:
		var slide := effect as ChoiceSlideEffect
		var dur := slide.duration if slide.duration > 0.0 else 0.01
		_place_heart_on(target)
		var to_pos := Vector2(target.heart.position)
		_heart_global_tracker = target.heart.global_position
		target.heart.position = Vector2(to_pos.x + target.heart.size.x + 8.0, to_pos.y)
		heart_tween = create_tween()
		heart_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		heart_tween.tween_property(target.heart, "position", to_pos, dur)
	elif effect is ChoiceSnapEffect:
		var snap := effect as ChoiceSnapEffect
		_place_heart_on(target)
		var to_global := target.heart.global_position
		# 首次出现无动画
		if _heart_global_tracker == Vector2.ZERO:
			_heart_global_tracker = to_global
			return
		var from_global := _heart_global_tracker
		_heart_global_tracker = to_global
		if from_global == to_global:
			return
		# 把 from_global 换算到 target 本地坐标，再 tween
		var target_base := target.global_position
		var local_from := from_global - target_base
		var local_to := to_global - target_base
		target.heart.position = local_from
		var dist := (to_global - from_global).length()
		var dur : float = dist / max(snap.speed, 1.0) if snap.speed > 0.0 else 0.12
		heart_tween = create_tween()
		if snap.use_ease:
			heart_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		else:
			heart_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
		if snap.overshoot:
			var sign := 1 if local_to.x > local_from.x else -1
			var peak := Vector2(local_to.x + snap.overshoot_amount * sign, local_to.y)
			heart_tween.tween_property(target.heart, "position", peak, dur * 0.7)
			heart_tween.tween_property(target.heart, "position", local_to, dur * 0.3)
		else:
			heart_tween.tween_property(target.heart, "position", local_to, dur)
	elif effect is ChoiceWobbleEffect:
		var wo := effect as ChoiceWobbleEffect
		_place_heart_on(target)
		var base_x := target.heart.position.x
		_heart_global_tracker = target.heart.global_position
		heart_tween = create_tween()
		for i in wo.count:
			var sign := 1 if i % 2 == 0 else -1
			var amp := wo.magnitude * pow(wo.decay, i)
			if amp < 0.3:
				break
			heart_tween.tween_property(target.heart, "position:x", base_x + amp * sign, wo.speed)
			heart_tween.tween_property(target.heart, "position:x", base_x, wo.speed)
func _navigate_direction(direction: Vector2) -> void:
	var effect := main_dialogue.choice_effect
	if effect is ChoiceSnapEffect and (effect as ChoiceSnapEffect).block_input and heart_tween and heart_tween.is_running():
		return
	var current := choice_items[current_choice_index]
	var cur_center := current.get_center()

	var best_index := -1
	var best_score := -INF

	for i in choice_items.size():
		if not choice_items[i].visible or i == current_choice_index:
			continue
		var target_center := choice_items[i].get_center()
		var delta := target_center - cur_center
		var dist := delta.length()
		if dist < 0.01:
			continue

		var dir_norm := delta.normalized()
		var dot_result := dir_norm.dot(direction)

		if dot_result <= 0.0:
			continue

		var score := dot_result - dist * 0.0001
		if score > best_score:
			best_score = score
			best_index = i

	if best_index != -1:
		if choices_first_nav:
			choices_first_nav = false
			choice_items[current_choice_index].set_selected(false)
			current_choice_index = best_index
			choice_items[current_choice_index].set_selected(true)
			_update_heart_position(choice_items[current_choice_index])
		else:
			var old := choice_items[current_choice_index]
			_heart_global_tracker = old.heart.global_position
			old.set_selected(false)
			current_choice_index = best_index
			var next_item := choice_items[current_choice_index]
			next_item.set_selected(true)
			_update_heart_position(next_item)
		choice_audio.stream = main_dialogue.choice_switch_sound
		choice_audio.play()
	elif choices_first_nav:
		# 方向无候选但红心未出 → 直接在当前项上显示
		choices_first_nav = false
		choice_items[current_choice_index].set_selected(true)
		_update_heart_position(choice_items[current_choice_index])
		choice_audio.stream = main_dialogue.choice_switch_sound
		choice_audio.play()

#func _on_choice_pressed(index: int) -> void:
	#_hide_choices()
	#choices_active = false
	#var group := main_dialogue
	#Global.set_flag(group.set_flag)
	#var next_id_to_broadcast := ""
	#if index < group.choice_next_ids.size():
		#next_id_to_broadcast = group.choice_next_ids[index]
	#if next_id_to_broadcast != "":
		#Global.dialogue_broadcast.emit(next_id_to_broadcast)
	#
	#_finish_dialogue(true)
func _strip_bbcode(text: String) -> String:
	var result := ""
	var in_tag := false
	for ch in text:
		if ch == "[":
			in_tag = true
			continue
		if ch == "]":
			in_tag = false
			continue
		if not in_tag:
			result += ch
	return result




func _ready() -> void:
	visible = false
	current_typing_sound = default_typing_sound
	for item in choice_items:
		item.visible = false
		item.set_selected(false)
	
func start_dialogue(group: DialogueGroup) -> void:
	if typing_tween and typing_tween.is_running():
		typing_tween.kill()
	typing_tween = null
	if effect_tween and effect_tween.is_running():
		effect_tween.kill()
	if blink_tween and blink_tween.is_running():
		blink_tween.kill()
	persistent_effect_running = false
	container.position = Vector2.ZERO
	container.rotation_degrees = 0.0
	main_dialogue = group
	dialogue_index = 0
	current_choice_index = 0
	visible = true
	Global.can_act = false
	display_next_dialogue()

















func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if choices_active:
		if event.is_action_pressed("ui_left"):
			_navigate_direction(Vector2.LEFT)
		elif event.is_action_pressed("ui_right"):
			_navigate_direction(Vector2.RIGHT)
		elif event.is_action_pressed("ui_up"):
			_navigate_direction(Vector2.UP)
		elif event.is_action_pressed("ui_down"):
			_navigate_direction(Vector2.DOWN)
		elif event.is_action_pressed("interact"):
			_confirm_choice()
		return
	if event.is_action_pressed("interact"):
		display_next_dialogue()
	

#kkk



		
