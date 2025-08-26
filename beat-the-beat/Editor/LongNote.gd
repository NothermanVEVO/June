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

var annotation : String = ""
var section : String = ""
var speed : float = 0.0

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
	
	_long_note_info.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Inspect Note") and get_global_rect().has_point(get_global_mouse_position()):
		_long_note_info.display.call_deferred(not _long_note_info.visible)
	if _long_note_info.visible:
		_long_note_info.global_position = global_position + get_global_rect().size / 2 - _long_note_info.size / 2

func set_time(time : float) -> void:
	_time = time

func get_time() -> float:
	return _time

func get_type() -> Type:
	return _type

func set_annotation(note : String) -> void:
	_long_note_info.set_annotation(note)

func set_section(name : String) -> void:
	_long_note_info.set_section(name)

func set_speed(speed : float) -> void:
	_long_note_info.set_speed(speed)

func get_annotation() -> String:
	return _long_note_info.get_annotation()

func get_section() -> String:
	return _long_note_info.get_section()

func get_speed() -> float:
	return _long_note_info.get_speed()
