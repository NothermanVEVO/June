extends Note

class_name NoteEditor

@onready var _note_info_scene : PackedScene = preload("res://Editor/NoteInfo.tscn")
var _note_info : NoteInfo

signal value_changed

func _init(current_time : float) -> void:
	_current_time = current_time
	
	texture = NORMAL_NOTE_BLUE_IMG
	size = Vector2(NoteHolder.width, height)
	position = Vector2(-size / 2)
	z_index = 1

func _ready() -> void:
	_note_info = _note_info_scene.instantiate()
	add_child(_note_info)
	_note_info.visible = false
	_note_info.set_type(NoteInfo.Type.TAP)
	
	_note_info.set_start_time(_current_time)
	
	#_note_info.valid_start_time_text_change.connect(_time_text_changed)
	_note_info.power_changed.connect(_power_changed)
	
	_shader_material.shader = Global.HIGHLIGHT_SHADER
	
	set_selected_highlight(_is_selected)
	set_invalid_highlight(not _is_valid)

func _process(_delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	if get_global_rect().has_point(mouse_pos) and Input.is_action_just_pressed("Inspect Note"):
		_note_info.set_power_value(powered)
		#if _note_info.global_position.y - _note_info.size.y < _min_global_pos_y:
			#_note_info.position = Vector2(get_local_mouse_position().x, get_local_mouse_position().y)
		#else:
			#_note_info.position = Vector2(get_local_mouse_position().x, get_local_mouse_position().y - _note_info.size.y)
		_note_info.position = Vector2(get_local_mouse_position().x, get_local_mouse_position().y - _note_info.size.y)
		_note_info.visible = true
	elif _note_info.visible and not _note_info.get_global_rect().has_point(mouse_pos) and (
			Input.is_action_just_pressed("Add Item") or Input.is_action_just_pressed("Inspect Note")):
		_note_info.visible = false

func _set_highlight(highlight : bool) -> void:
	if highlight:
		material = _shader_material
	else:
		material = null

func set_selected_highlight(selected : bool) -> void:
	_is_selected = selected
	_set_highlight(selected)
	
	if selected:
		z_index = 2
	else:
		z_index = 1
	
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

func update_start_time_text() -> void:
	if _note_info:
		_note_info.set_start_time(get_time())

#func _time_text_changed(seconds : float) -> void: # SIGNAL
	#set_time(seconds)
	#Gear.update_note_time(self, true)

func _power_changed(value : bool) -> void:
	powered = value
	value_changed.emit()

func has_mouse_on_info() -> bool:
	if not _note_info:
		return false
	return _note_info.visible and _note_info.has_mouse()
