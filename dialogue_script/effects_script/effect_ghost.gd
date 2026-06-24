@tool
extends RichTextEffect
class_name RichTextGhost

var bbcode = "ghost"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed := char_fx.env.get("freq", 5.0) as float
	var span := char_fx.env.get("span", 10.0) as float
	
	var alpha := sin(char_fx.elapsed_time * speed + (char_fx.glyph_index / span)) * 0.5 + 0.5
	char_fx.color.a *= alpha
	return true
