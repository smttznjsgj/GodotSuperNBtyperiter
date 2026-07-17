extends EffectData
class_name ShakeEffect

##横向抖动
@export var magnitude_x: float = 15.0
##竖直方向的抖动。关于抖动，可以把抖动调的很大，速度调慢，就能做出平移对话框的效果
@export var magnitude_y: float = 2.0
##抖动次数
@export var count: int = 3
##抖动速度，越小越快
@export var speed: float = 0.04
