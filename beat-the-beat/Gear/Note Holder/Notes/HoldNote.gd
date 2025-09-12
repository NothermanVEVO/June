extends Note

class_name HoldNote

const START_NOTE_IMG = preload("res://assets/holdStart.png")
const MIDDLE_NOTE_IMG = preload("res://assets/holdMiddle.png")
const END_NOTE_IMG = preload("res://assets/holdEnd.png")

var _start_note : NinePatchRect = NinePatchRect.new()
var _middle_note : NinePatchRect = NinePatchRect.new()
var _end_note : NinePatchRect = NinePatchRect.new()

var _duration : float

var end_state : State = State.TO_HIT

func _init(start_time : float, end_time : float) -> void:
	_current_time = start_time
	_duration = end_time - start_time
	
	_start_note.texture = START_NOTE_IMG
	_middle_note.texture = MIDDLE_NOTE_IMG
	_end_note.texture = END_NOTE_IMG
	
	set_start_time(start_time)
	
	add_child(_start_note)
	add_child(_end_note)
	add_child(_middle_note)

func _ready() -> void:
	Global.speed_changed.connect(_speed_changed)

func get_start_time() -> float:
	return _current_time

func get_end_time() -> float:
	return _current_time + _duration

func get_duration() -> float:
	return _duration

func set_start_time(start_time : float) -> void:
	set_time(start_time)
	
	_start_note.size = Vector2(NoteHolder.width, height / 2.0)
	_start_note.position = Vector2(0, _start_note.size.y)
	
	set_end_time(get_end_time())

func set_end_time(end_time : float) -> void:
	_duration = end_time - _current_time
	
	var end_pos = NoteHolder.get_local_pos_y_correct(0, Gear.get_max_size_y(), end_time - _current_time, 0, Gear.MAX_TIME_Y())
	
	while end_time - _current_time > Gear.MAX_TIME_Y():
		end_time -= Gear.MAX_TIME_Y()
		end_pos += NoteHolder.get_local_pos_y_correct(0, Gear.get_max_size_y(), end_time - _current_time, 0, Gear.MAX_TIME_Y())
	
	_end_note.size = Vector2(NoteHolder.width, Note.height / 2.0)
	_end_note.position = Vector2(0, -end_pos)
	
	_middle_note.position = Vector2(0, floor(_end_note.position.y + _end_note.size.y))
	_middle_note.size = Vector2(NoteHolder.width, ceil(abs(_middle_note.position.y - _start_note.size.y)))

func _speed_changed() -> void:
	set_end_time(get_end_time())
