extends HoldNote

class_name HoldNoteEditor

@onready var _note_info_scene : PackedScene = preload("res://Editor/NoteInfo.tscn")
var _note_info : NoteInfo

var _min_global_pos_y : float

func _init(start_time : float, end_time : float, min_global_pos_y : float) -> void:
	_start_time = start_time
	_end_time = end_time
	_min_global_pos_y = min_global_pos_y
	
	set_time(_start_time)
	
	_start_note.texture = START_NOTE_IMG
	_middle_note.texture = MIDDLE_NOTE_IMG
	_end_note.texture = END_NOTE_IMG
	
	add_child(_start_note)
	_start_note.size = Vector2(NoteHolder.width, height / 2)
	_start_note.position = Vector2(0, _start_note.size.y)
	
	var end_pos = NoteHolder.get_local_pos_y_correct(0, Gear.get_max_size_y(), end_time - start_time, 0, NoteHolder.SECS_SIZE_Y)
	add_child(_end_note)
	_end_note.size = Vector2(NoteHolder.width, Note.height / 2)
	_end_note.position = Vector2(0, -end_pos)
	
	add_child(_middle_note)
	_middle_note.size = Vector2(NoteHolder.width, abs(_start_note.position.y - (_end_note.position.y + _end_note.size.y)))
	_middle_note.position = Vector2(0, _start_note.position.y - _middle_note.size.y)

func _ready() -> void:
	_note_info = _note_info_scene.instantiate()
	add_child(_note_info)
	_note_info.visible = false
	_note_info.set_type(NoteInfo.Type.HOLD)
	
	_note_info.set_start_time(_start_time)
	_note_info.set_end_time(_end_time)

func _process(delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	
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
