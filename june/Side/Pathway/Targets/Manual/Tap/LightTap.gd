extends Tap

class_name LightTap

enum Variants {ONE, TWO, THREE}

var _variant : Variants

func _init(start_time : float, path_type : Path.Types, variant : Variants) -> void:
	super._init(start_time, path_type)
	set_variant(variant)

func set_variant(variant : Variants) -> void:
	_variant = variant
	
	match variant:
		Variants.ONE:
			texture = SideEditor.LIGHT_1_TEXTURE
		Variants.TWO:
			texture = SideEditor.LIGHT_2_TEXTURE
		Variants.THREE:
			texture = SideEditor.LIGHT_3_TEXTURE

func get_variant() -> Variants:
	return _variant
