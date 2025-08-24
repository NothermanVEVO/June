extends NinePatchRect

class_name LongNote

enum Type{ANNOTATION, SECTION, SPEED}

const ANNOTATION_TEXTURE := preload("res://assets/annotation.png")
const SECTION_TEXTURE := preload("res://assets/section.png")
const SPEED_TEXTURE := preload("res://assets/speed.png")

@onready var _long_note_info_scene : PackedScene = preload("res://Editor/LongNoteInfo.tscn")
var _long_note_info : LongNoteInfo

var _time : float
var _type : Type

static var height : float = 12

func _init(time : float, type : Type) -> void:
	_time = time
	_type = type
	size = Vector2(Gear.width, height)
	position = Vector2(0, size.y)

func _ready() -> void:
	_long_note_info = _long_note_info_scene.instantiate()
	_long_note_info.set_type(_type)
	add_child(_long_note_info)
	
	match _type:
		Type.ANNOTATION:
			texture = ANNOTATION_TEXTURE
		Type.SECTION:
			texture = SECTION_TEXTURE
		Type.SPEED:
			texture = SPEED_TEXTURE
	patch_margin_left = 3
	patch_margin_right = 3

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Inspect Note") and get_global_rect().has_point(get_global_mouse_position()):
		_long_note_info.display.call_deferred(true)

func set_time(time : float) -> void:
	_time = time

func get_time() -> float:
	return _time

func get_type() -> Type:
	return _type
