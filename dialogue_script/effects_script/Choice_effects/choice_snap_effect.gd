extends ChoiceEffectData
class_name ChoiceSnapEffect

## 滑动速度，单位：像素/秒。数字越大越快。
@export var speed: float = 2000.0
## 简单滑动还是来点惯性。默认简单滑动，就是没有任何惯性体现。但是速度这么快，要不要惯性都行，我感觉这个效果挺鸡肋的。
@export var use_ease: bool = true
## 关闭 = 精确停在目标位置，开启 = 冲过头再弹回来（惯性），得打开use_ease才能看见这个的效果
@export var overshoot: bool = false
##冲过头的幅度
@export var overshoot_amount: float = 5.0
## 开启后 tween 期间方向键无效，红心必须滑到位才能继续操作
@export var block_input: bool = false
