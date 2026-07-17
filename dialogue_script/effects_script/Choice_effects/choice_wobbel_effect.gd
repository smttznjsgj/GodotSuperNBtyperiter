extends ChoiceEffectData
class_name ChoiceWobbleEffect

##滑过去会左右抖动的动画效果
@export var magnitude: float = 6.0
##抖动次数
@export var count: int = 4
##数字越小越快
@export var speed: float = 0.04
##衰减幅度，0是不衰减，数字越大衰减越狠
@export_range(0.0, 1.0, 0.01) var decay: float = 0.5
