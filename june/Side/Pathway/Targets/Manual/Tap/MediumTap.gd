extends Tap

class_name MediumTap

enum Variants {ONE, TWO}

var _variant : Variants

func _init(start_time : float, path_type : Path.Types, variant : Variants) -> void:
	super._init(start_time, path_type)
	set_variant(variant)

func set_variant(variant : Variants) -> void:
	_variant = variant
	
	match variant:
		Variants.ONE:
			texture = SideEditorTexture.MEDIUM_1_TEXTURE
		Variants.TWO:
			texture = SideEditorTexture.MEDIUM_2_TEXTURE

func get_variant() -> Variants:
	return _variant
