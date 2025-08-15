extends Note

class_name HoldNote

const START_NOTE_IMG = preload("res://assets/holdStart.png")
const MIDDLE_NOTE_IMG = preload("res://assets/holdMiddle.png")
const END_NOTE_IMG = preload("res://assets/holdEnd.png")

var _start_note : NinePatchRect = NinePatchRect.new()
var _middle_note : NinePatchRect = NinePatchRect.new()
var _end_note : NinePatchRect = NinePatchRect.new()

var _start_time : float
var _end_time : float

var start_state : State = State.TO_HIT
var end_state : State = State.TO_HIT

func _init(start_time : float, end_time : float) -> void:
	_start_time = start_time
	_end_time = end_time
	
	set_time(_start_time)
	
	_start_note.texture = START_NOTE_IMG
	_middle_note.texture = MIDDLE_NOTE_IMG
	_end_note.texture = END_NOTE_IMG
	
	add_child(_start_note)
	_start_note.size = Vector2(NoteHolder.width, height / 2)
	_start_note.position = Vector2(0, _start_note.size.y)
	
	add_child(_end_note)
	add_child(_middle_note)
	
	set_end_time(end_time)

func get_start_time() -> float:
	return _start_time

func get_end_time() -> float:
	return _end_time

func get_duration() -> float:
	return _end_time - _start_time

func set_start_time(start_time : float) -> void:
	_start_time = start_time
	set_time(start_time)
	
	_start_note.size = Vector2(NoteHolder.width, height / 2)
	_start_note.position = Vector2(0, _start_note.size.y)
	
	var end_pos = NoteHolder.get_local_pos_y_correct(0, Gear.get_max_size_y(), _end_time - start_time, 0, NoteHolder.SECS_SIZE_Y)
	_end_note.size = Vector2(NoteHolder.width, Note.height / 2)
	_end_note.position = Vector2(0, -end_pos)
	
	_middle_note.size = Vector2(NoteHolder.width, abs(_start_note.position.y - (_end_note.position.y + _end_note.size.y)))
	_middle_note.position = Vector2(0, _start_note.position.y - _middle_note.size.y)

func set_end_time(end_time : float) -> void:
	_end_time = end_time
	
	var end_pos = NoteHolder.get_local_pos_y_correct(0, Gear.get_max_size_y(), end_time - _start_time, 0, NoteHolder.SECS_SIZE_Y)
	
	while end_time - _start_time > NoteHolder.SECS_SIZE_Y:
		end_time -= NoteHolder.SECS_SIZE_Y
		end_pos += NoteHolder.get_local_pos_y_correct(0, Gear.get_max_size_y(), end_time - _start_time, 0, NoteHolder.SECS_SIZE_Y)
	
	_end_note.size = Vector2(NoteHolder.width, Note.height / 2)
	_end_note.position = Vector2(0, -end_pos)
	
	_middle_note.size = Vector2(NoteHolder.width, abs(_start_note.position.y - (_end_note.position.y + _end_note.size.y)))
	_middle_note.position = Vector2(0, _start_note.position.y - _middle_note.size.y)
