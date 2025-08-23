extends HoldNote

class_name HoldNoteEditor

@onready var _note_info_scene : PackedScene = preload("res://Editor/NoteInfo.tscn")
var _note_info : NoteInfo

var _shader_material = ShaderMaterial.new()
const HIGHLIGHT_SHADER = preload("res://shaders/Highlight.gdshader")

var _min_global_pos_y : float

var top_button := Button.new()
var bottom_button := Button.new()

var is_button_down : bool = false

signal pressing_button(hold_note : HoldNoteEditor, top_button : bool)

func _init(start_time : float, end_time : float, min_global_pos_y : float) -> void:
	set_start_time(start_time)
	set_end_time(end_time)
	_min_global_pos_y = min_global_pos_y
	
	_start_note.texture = START_NOTE_IMG
	_middle_note.texture = MIDDLE_NOTE_IMG
	_end_note.texture = END_NOTE_IMG
	
	add_child(_start_note)
	add_child(_end_note)
	add_child(_middle_note)

func _ready() -> void:
	Global.speed_changed.connect(_speed_changed)
	
	_note_info = _note_info_scene.instantiate()
	add_child(_note_info)
	_note_info.visible = false
	_note_info.set_type(NoteInfo.Type.HOLD)
	
	_note_info.set_start_time(_current_time)
	_note_info.set_end_time(get_end_time())
	
	#_note_info.valid_start_time_text_change.connect(_start_time_text_changed)
	#_note_info.valid_end_time_text_change.connect(_end_time_text_changed)
	
	_shader_material.shader = HIGHLIGHT_SHADER
	
	top_button.position = _end_note.position# + Vector2(0, - Note.height)
	top_button.size = Vector2(_end_note.size.x, Note.height / 4)
	top_button.mouse_default_cursor_shape = Control.CURSOR_VSIZE
	add_child(top_button)
	
	bottom_button.position = _start_note.position# + Vector2(0, - Note.height)
	bottom_button.size = Vector2(_start_note.size.x, Note.height / 4)
	bottom_button.mouse_default_cursor_shape = Control.CURSOR_VSIZE
	add_child(bottom_button)

func _process(delta: float) -> void:
	if is_selected():
		top_button.visible = true
		bottom_button.visible = true
		top_button.position = _end_note.position - Vector2(0, Note.height / 8)
		bottom_button.position = _start_note.position + Vector2(0, Note.height / 4)
	else:
		top_button.visible = false
		bottom_button.visible = false
	
	var mouse_pos := get_global_mouse_position()
	
	if top_button.button_pressed:
		pressing_button.emit(self, true)
	elif bottom_button.button_pressed:
		pressing_button.emit(self, false)
	
	var rect := Rect2(_end_note.global_position, Vector2(_start_note.size.x, _start_note.size.y + _middle_note.size.y + _end_note.size.y))
	
	if rect.has_point(mouse_pos) and Input.is_action_just_pressed("Inspect Note"):
		if mouse_pos.y - _note_info.size.y < _min_global_pos_y:
			_note_info.global_position = Vector2(mouse_pos.x, mouse_pos.y)
		else:
			_note_info.global_position = Vector2(mouse_pos.x, mouse_pos.y - _note_info.size.y)
		_note_info.visible = true
	elif _note_info.visible and not _note_info.get_global_rect().has_point(mouse_pos) and (
			Input.is_action_just_pressed("Add Item") or Input.is_action_just_pressed("Inspect Note")):
		_note_info.visible = false

func get_global_hold_rect() -> Rect2:
	return Rect2(_end_note.global_position, Vector2(_start_note.size.x, _start_note.size.y + _middle_note.size.y + _end_note.size.y))

func _set_highlight(highlight : bool) -> void:
	if highlight:
		_start_note.material = _shader_material
		_middle_note.material = _shader_material
		_end_note.material = _shader_material
	else:
		_start_note.material = null
		_middle_note.material = null
		_end_note.material = null

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

func update_start_time_text() -> void:
	_note_info.set_start_time(get_time())

func update_end_time_text() -> void:
	_note_info.set_end_time(get_end_time())

#func _start_time_text_changed(seconds : float) -> void: # SIGNAL
	#set_start_time(seconds)
	#Gear.update_note_time(self, true)

#func _end_time_text_changed(seconds : float) -> void: # SIGNAL
	#set_end_time(seconds)
	#Gear.update_note_time(self, true)

func has_mouse_on_info() -> bool:
	return _note_info.visible and _note_info.has_mouse()
