extends Resource
class_name TransitionData

enum TransitionType { FADE, SHADER }

@export var open_sound: AudioStream
@export var close_sound: AudioStream
@export var fade_time: float = 0.35
@export var color: Color = Color.BLACK
@export var type: TransitionType = TransitionType.FADE
@export var shader_material: ShaderMaterial
