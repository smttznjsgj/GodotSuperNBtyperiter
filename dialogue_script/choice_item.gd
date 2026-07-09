extends Control
class_name ChoiceItem

@onready var heart: TextureRect = $Heart
@onready var label: Label = $Text

var normal_color: Color = Color.WHITE
var selected_color: Color = Color(1.0, 0.85, 0.0)

func set_text(t: String) -> void:
	label.text = t

func set_selected(sel: bool) -> void:
	heart.visible = sel
	label.modulate = selected_color if sel else normal_color

func set_colors(normal: Color, selected: Color) -> void:
	normal_color = normal
	selected_color = selected
	label.modulate = selected_color if heart.visible else normal_color

func get_center() -> Vector2:
	return global_position + size / 2.0
