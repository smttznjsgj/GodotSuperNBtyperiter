extends Resource
class_name DialogueGroup

@export var dialogue_list : Array[Dialogue]

@export var id: String = ""
@export var next_id: String = ""
#
#@export_group("Narration旁白叙事")
#@export var position_top: bool = false
#@export var can_act : bool = false

@export_group("Flags and Event")
@export var require_flag: String = ""
@export var set_flag: String = ""
@export_group("Choices")
@export var choices: Array[String] = []
@export var choice_next_ids: Array[String] = []
@export var choice_effect: ChoiceEffectData
@export var choice_switch_sound: AudioStream = preload("res://素材/声音/snd_squeak.wav")
@export var choice_confirm_sound: AudioStream = preload("res://素材/声音/snd_select.wav")
@export var choice_selected_color: Color = Color(1.0, 1.0, 0.0, 1.0)
