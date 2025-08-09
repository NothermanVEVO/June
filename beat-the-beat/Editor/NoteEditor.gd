extends Note

class_name NoteEditor

@onready var _note_info_scene : PackedScene = preload("res://Editor/NoteInfo.tscn")
var _note_info : NoteInfo

var _min_global_pos_y : float

func _init(current_time : float, min_global_pos_y : float) -> void:
	_current_time = current_time
	_min_global_pos_y = min_global_pos_y
	
	texture = NORMAL_NOTE_IMG
	size = Vector2(NoteHolder.width, height)
	position = Vector2(-size / 2)
	z_index = 1
	

func _ready() -> void:
	_note_info = _note_info_scene.instantiate()
	add_child(_note_info)
	_note_info.visible = false
	_note_info.set_type(NoteInfo.Type.TAP)
	
	var dict_result = SoundBoard.split_time(_current_time)
	#var minutes : String = 
	_note_info.set_start_time("")

func _process(delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	if get_global_rect().has_point(mouse_pos) and Input.is_action_just_pressed("Inspect Note"):
		if _note_info.global_position.y - _note_info.size.y < _min_global_pos_y:
			_note_info.position = Vector2(get_local_mouse_position().x, get_local_mouse_position().y)
		else:
			_note_info.position = Vector2(get_local_mouse_position().x, get_local_mouse_position().y - _note_info.size.y)
		_note_info.visible = true
	elif _note_info.visible and not _note_info.get_global_rect().has_point(mouse_pos) and (
			Input.is_action_just_pressed("Add Item") or Input.is_action_just_pressed("Inspect Note")):
		_note_info.visible = false
