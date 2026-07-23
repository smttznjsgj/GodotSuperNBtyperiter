extends Resource
class_name Action

## 匹配哪个 DialogueGroup 的 id
@export var dialogue_id: String = ""
## 匹配第几句对话（从 0 开始）
@export var line_index: int = 0
## 给该对话加上，填AnimationPlayer 中的动画名称
@export var animation_name: String = ""
