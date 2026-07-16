extends Resource
class_name Dialogue


@export_multiline var content : String = "* "
@export var avatar : Texture
@export var typing_sound : AudioStream


@export_group("常规Normal")
@export var character_name : String
@export var avatar_right : Texture
@export_group("高级Advanced")
@export var effect_sound: AudioStream
@export var typing_speed : float = 0.05
@export var text_color: Color = Color.WHITE
@export var text_font : Font = preload("res://素材/Fonts/方正像素12.ttf")
@export var effect: Array[EffectData] = []
## 效果跨句延续：true=快进不打断摇晃，false=效果结束后才允许推进下一句，针对效果比较长的对话，如果为false，则在对话结束后按下快进，先归位结束效果。ps.如果想制作那种比较长的效果，请把count调一个雷霆大数，确保其一时半会不会停
@export var persist_effects: bool = false
@export_group("环境叙事")
@export var position_up : bool = false
@export var can_skip: bool = true
@export var auto_continue: bool = false
##如果choice对话前的句子can_act = true，会导致玩选项红心的时候玩家跟着动。是个bug，也可以当做小巧思来灵活运用，所以就不修了。。还有就是因为，在编辑对话的时候尽量避免这种出现在选项之前的can_act = true对话句子。不是什么难事。
@export var can_act: bool = false
##强制和can_skip = false绑定，打开stay_duration一定要打开can_skip = false，
@export var stay_duration: float = 0.0
@export var hide_end_hint: bool = false
