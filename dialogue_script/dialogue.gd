extends Resource
class_name Dialogue

##打字的文本内容
@export_multiline var content : String = "* "
##左边的头像，不往里面塞图片就是隐藏，最左侧显示，拖进去图片自动开辟位置占位
@export var avatar : Texture
##打字的音效，默认是嘟嘟嘟音效
@export var typing_sound : AudioStream


@export_group("常规Normal")
##说话者的名字，就是个额外的小对话框
@export var character_name : String
##右边的头像，不往里面塞东西就是隐藏
@export var avatar_right : Texture
@export_group("高级Advanced")
##这句对话首次出现的时候的音效
@export var effect_sound: AudioStream
##打字速度，越小越快
@export var typing_speed : float = 0.05
##字体颜色，也可以通过控制符自定义局部字体颜色。这里就不说了
@export var text_color: Color = Color.WHITE
##字体种类，一样可以自定义
@export var text_font : Font = preload("res://素材/Fonts/方正像素12.ttf")
##本句对话的效果器，动画效果
@export var effect: Array[EffectData] = []
## 效果跨句延续：true=快进不打断摇晃，false=效果结束后才允许推进下一句，针对效果比较长的对话，如果为false，则在对话结束后按下快进，先归位结束效果。ps.如果想制作那种比较长的效果，请把count调一个雷霆大数，确保其一时半会不会停
@export var persist_effects: bool = false
@export_group("环境叙事")
##切记一定要搭配后面的使用，记得清空文字内容，或者把打字音效关掉
##对话框整体透明度，0=全透明（不可见但功能正常运行），1=完全不透明（默认）
@export_range(0.0, 1.0, 0.01) var dialogue_opacity: float = 1.0
#让对话框出现在顶部
@export var position_up : bool = false
#能否在对话结束之前跳过，默认可以跳过
@export var can_skip: bool = true
#自动延续，这句对话打完之后是否自动推进
@export var auto_continue: bool = false
##这句对话打出来的时候，玩家是否可以移动与交互。默认是关掉的。不是写那种环境对话或者特殊剧情，千万不要打开！
##这个功能有点牵扯到游戏的底层逻辑，请务必严谨对待该功能，所以作者在这里温馨提醒：
##1.如果你使用了can_act = true,则请操控玩家，把player节点的检测箭头放到空位置，否则会导致交互键没有效果，推进不了对话。实际上这个组内的五个功能这是用来配合区域检测zone_trigger对话触发器使用的，所以请在创作的时候合理分配与规划，从设计层面上避免这些非代码层面的问题。
##2.如果choice对话前的句子can_act = true，会导致玩选项红心的时候玩家跟着动。是个bug，也可以当做小巧思来灵活运用，所以就不修了。。还有就是因为，在编辑对话的时候尽量避免这种出现在选项之前的can_act = true对话句子。不是什么难事。
@export var can_act: bool = false
##对话结束后的延时功能，默认是0.强制和can_skip = false绑定，打开stay_duration一定要打开can_skip = false，不然没啥意义。
@export var stay_duration: float = 0.0
##是否隐藏小光标。
@export var hide_end_hint: bool = false
