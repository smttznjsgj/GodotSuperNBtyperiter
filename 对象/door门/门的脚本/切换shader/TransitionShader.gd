extends CanvasLayer
class_name TransitionOverlay


@onready var overlay: ColorRect = $Overlay

func show_black() -> void:
	overlay.visible = true

func hide_black() -> void:
	overlay.visible = false
