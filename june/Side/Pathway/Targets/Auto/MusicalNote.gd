extends AutoTarget

class_name MusicalNote

enum Variants {ONE, TWO}

var _variant : Variants

func _init(start_time : float, path_type : Path.Types, variant : Variants) -> void:
	super._init(start_time, path_type)
	set_variant(variant)

func set_variant(variant : Variants) -> void:
	_variant = variant
	
	match variant:
		Variants.ONE:
			texture = SideEditor.NOTE_1_TEXTURE
		Variants.TWO:
			texture = SideEditor.NOTE_2_TEXTURE

func get_variant() -> Variants:
	return _variant

func collide() -> void:
	print("ganhei pontos de nota")
