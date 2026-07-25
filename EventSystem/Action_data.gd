extends Resource
class_name Action
## 动画由哪个节点播放
enum PlayerNode { NORMAL_ANIMATION_PLAYER, SPRITE_ANIMATIONPLAYER }
## 匹配哪个 DialogueGroup 的 id
@export var dialogue_id: String = ""
## 匹配第几句对话（从 0 开始）
@export var line_index: int = 0
##动画播放节点的类型，1.常规动画：大小变化，位移等；2.精灵图动画
@export var player_node: PlayerNode = PlayerNode.NORMAL_ANIMATION_PLAYER
## AnimationPlayer 或 AnimatedSprite2D 中的动画名称
## 给该对话加上，填AnimationPlayer 中的动画名称
@export var animation_name: String = ""
