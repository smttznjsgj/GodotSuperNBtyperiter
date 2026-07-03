extends ChoiceEffectData
class_name ChoiceSnapEffect

## 滑动速度，单位：像素/秒。距离越远耗时越长，保持匀速
@export var speed: float = 400.0
## 关闭 = 匀速直线，开启 = EASE_OUT 缓动，起步快收脚柔
@export var use_ease: bool = true
## 关闭 = 精确停在目标位置，开启 = 冲过头再弹回来（惯性）
@export var overshoot: bool = false
@export var overshoot_amount: float = 5.0
## 开启后 tween 期间方向键无效，红心必须滑到位才能继续操作
@export var block_input: bool = false
