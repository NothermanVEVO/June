extends NinePatchRect

class_name LongNote

enum Type{ANNOTATION, SECTION, SPEED, FADE}

const ANNOTATION_TEXTURE := preload("res://assets/annotation.png")
const SECTION_TEXTURE := preload("res://assets/section.png")
const SPEED_TEXTURE := preload("res://assets/speed.png")
const FADE_TEXTURE := preload("res://assets/fade.png")

const _LONG_NOTE_INFO_SCENE : PackedScene = preload("res://Editor/LongNoteInfo.tscn")
var _long_note_info : LongNoteInfo

var _shader_material = ShaderMaterial.new()

var _is_valid : bool = true ## CAN BE TRUE BECAUSE IT CAN'T BE PLACED IN THE SAME TIME POS
var _is_selected : bool

var _time : float
var _type : Type

static var height : float = 12

var annotation : String = ""
var section : String = ""
var speed : float = 1.0
var fade : bool = false

signal value_changed

func _init(time : float, type : Type) -> void:
	_time = time
	_type = type
	size = Vector2(Gear.width, height)
	position = Vector2(0, size.y)

func _ready() -> void:
	match _type:
		Type.ANNOTATION:
			texture = ANNOTATION_TEXTURE
			set_annotation(annotation)
		Type.SECTION:
			texture = SECTION_TEXTURE
			set_section(section)
		Type.SPEED:
			texture = SPEED_TEXTURE
			set_speed(speed)
		Type.FADE:
			texture = FADE_TEXTURE
			set_fade(fade)
	patch_margin_left = 3
	patch_margin_right = 3
	
	_long_note_info = _LONG_NOTE_INFO_SCENE.instantiate()
	_long_note_info.set_type(_type)
	add_child(_long_note_info)
	_long_note_info.set_annotation(annotation)
	_long_note_info.set_section(section)
	_long_note_info.set_speed(speed)
	_long_note_info.set_fade(fade)
	_long_note_info.visible = false
	#tree_entered.connect(func(): _long_note_info.display(false)) # TODO
	
	_shader_material.shader = Global.HIGHLIGHT_SHADER
	
	_long_note_info.annotation_value_changed.connect(_annotation_value_changed)
	_long_note_info.section_value_changed.connect(_section_value_changed)
	_long_note_info.speed_value_changed.connect(_speed_value_changed)
	_long_note_info.fade_value_changed.connect(_fade_value_changed)
	
	z_index = 1

func _process(delta: float) -> void:
	_long_note_info.global_position = global_position + get_global_rect().size / 2 - _long_note_info.size / 2
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
	annotation = note
	if _long_note_info:
		_long_note_info.set_annotation(note)

func set_section(title : String) -> void:
	section = title
	if _long_note_info:
		_long_note_info.set_section(title)

@warning_ignore("shadowed_variable")
func set_speed(speed : float) -> void:
	self.speed = speed
	if _long_note_info:
		_long_note_info.set_speed(speed)

@warning_ignore("shadowed_variable")
func set_fade(fade : bool) -> void:
	self.fade = fade
	if _long_note_info:
		_long_note_info.set_fade(fade)

func get_annotation() -> String:
	return annotation

func get_section() -> String:
	return section

func get_speed() -> float:
	return speed

func get_fade() -> bool:
	return fade

func _annotation_value_changed() -> void:
	annotation = _long_note_info.get_annotation()
	value_changed.emit()

func _section_value_changed() -> void:
	section = _long_note_info.get_section()
	value_changed.emit()

func _speed_value_changed() -> void:
	speed = _long_note_info.get_speed()
	value_changed.emit()

func _fade_value_changed() -> void:
	fade = _long_note_info.get_fade()
	value_changed.emit()

func _set_highlight(highlight : bool) -> void:
	if highlight:
		material = _shader_material
	else:
		material = null

func set_selected_highlight(selected : bool) -> void:
	_is_selected = selected
	_set_highlight(selected)
	if selected:
		if _is_valid:
			_shader_material.set_shader_parameter("shade_color", Vector4(1.0, 1.0, 1.0, 0.5))
		else:
			_shader_material.set_shader_parameter("shade_color", Vector4(1.0, 0.4, 0.4, 0.5))
	elif not _is_valid:
		set_invalid_highlight(true)

func set_invalid_highlight(is_invalid : bool) -> void:
	_is_valid = not is_invalid
	_set_highlight(is_invalid)
	if is_invalid and not _is_selected:
			_shader_material.set_shader_parameter("shade_color", Vector4(1.0, 0.1, 0.1, 0.5))
	elif _is_selected:
		set_selected_highlight(true)

func to_resource() -> LongNoteResource:
	var value : String = annotation if _type == Type.ANNOTATION else section if _type == Type.SECTION else str(speed) if _type == Type.SPEED else str(fade)
	return LongNoteResource.new(_time, _type, value, _is_valid, _is_selected)
