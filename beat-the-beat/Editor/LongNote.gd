extends NinePatchRect

class_name LongNote

enum Type{ANNOTATION, SECTION, SPEED}

const ANNOTATION_TEXTURE := preload("res://assets/annotation.png")
const SECTION_TEXTURE := preload("res://assets/section.png")
const SPEED_TEXTURE := preload("res://assets/speed.png")

var _time : float
var _type : Type

static var height : float = 12

func _init(time : float, type : Type) -> void:
	_time = time
	_type = type
	size = Vector2(Gear.width, height)
	position = Vector2(0, size.y)

func _ready() -> void:
	match _type:
		Type.ANNOTATION:
			texture = ANNOTATION_TEXTURE
		Type.SECTION:
			texture = SECTION_TEXTURE
		Type.SPEED:
			texture = SPEED_TEXTURE
	patch_margin_left = 3
	patch_margin_right = 3

func set_time(time : float) -> void:
	_time = time

func get_time() -> float:
	return _time

func get_type() -> Type:
	return _type
