extends Tap

class_name LightTap

const _LIGHT_1_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/light 1.png")
const _LIGHT_2_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/light 2.png")
const _LIGHT_3_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/light 3.png")

enum Variants {ONE, TWO, THREE}

var _variant : Variants

func _init(start_time : float, path_type : Path.Types, variant : Variants) -> void:
	super._init(start_time, path_type)
	set_variant(variant)

func set_variant(variant : Variants) -> void:
	_variant = variant
	
	match variant:
		Variants.ONE:
			texture = _LIGHT_1_TEXTURE
		Variants.TWO:
			texture = _LIGHT_2_TEXTURE
		Variants.THREE:
			texture = _LIGHT_3_TEXTURE

func get_variant() -> Variants:
	return _variant
