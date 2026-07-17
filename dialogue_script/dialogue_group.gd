extends Resource
class_name DialogueGroup
##这是对由单句对话组成的对话组组，把你想让这个NPC说的某一组对话写在这里，
@export var dialogue_list : Array[Dialogue]
##ID系统，将不同对话组串起来。这个是这个对话组自己的ID，什么类型都可以，数字，英文，中文，标点符号，只要是符号就能当做id来用。请注意，ID系统具有全局作用，尽量用复杂的ID来写对话流。如：sans_雪原_炸雪A1
@export var id: String = ""
##本对话组结束之后，导引到下一个对应ID的对话组。你可以让该对话自己ID和导引到的ID一样，这样你反复对话一直都是同样的对话。但是请注意，如果其他对话组结束后导引到的新ID，若在本对象内有对应新ID的对话组，则会打破刚刚说的自我导引循环。这不是设计问题。因为对话树就是这么复杂。另外，不同对话组可以使用同样的ID，但是一组对话的ID只能封装一个，一组对话不能有多个ID。你可以写几个一样的对话副本，安上去不同ID，就让相同的对话具有不同的ID，但是这样有点脱裤子放屁。。
@export var next_id: String = ""


@export_group("Flags and Event")
##旗帜锁，只有先触发有flag的对话，锁才能打开，可以套上多把锁，用逗号分隔开就好","，注意是英文的半角逗号
##旗帜系统，分流作用，在关键剧情的时候可以打上旗帜来标注，相当于一把钥匙与一把锁
@export var require_flag: String = ""
##旗帜钥匙，可以设置任何旗帜，可以设置多个旗帜，用逗号分隔开就好","，注意是英文的半角逗号
@export var set_flag: String = ""
##选项系统
@export_group("Choices")
##填进去你想要的选项文本内容即可。上限是四个选项，不要多加了，每个选项有自己的位置，组里面序号对应的位置为：0（1）左，（2）1右，（3）2上，（4）3下。如果只想让上下有选项，把左右的选项空下就会自动隐藏。
@export var choices: Array[String] = []
##选项系统和刚刚的ID系统是一致的，选项ID从上下的顺序是和上面你填选项的顺序是一致的。选了选项后，导引到对应选项ID的对话组。没有选项不填即可
@export var choice_next_ids: Array[String] = []
##红心选项切换的动画效果。做了三个预设
##不要选第一个EffectData，这是个用来占位的空资源类，本身没有任何效果，还会有不可修复的bug，请选后面的有具体名字的效果
@export var choice_effect: ChoiceEffectData
##选项切换的音效
@export var choice_switch_sound: AudioStream = preload("res://素材/声音/snd_squeak.wav")
##确认的音效
@export var choice_confirm_sound: AudioStream = preload("res://素材/声音/snd_select.wav")
##选中的颜色
@export var choice_selected_color: Color = Color(1.0, 1.0, 0.0, 1.0)
