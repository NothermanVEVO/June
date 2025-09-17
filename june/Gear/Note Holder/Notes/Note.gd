extends NinePatchRect

class_name Note

enum State {TO_HIT, HITTED, BREAK}
enum Type {BLUE, RED}

#const NORMAL_NOTE_IMG = preload("res://assets/noteFormated.png")
const NORMAL_NOTE_BLUE_IMG = preload("res://concepts/hit_test_blue.png")
const NORMAL_NOTE_RED_IMG = preload("res://concepts/hit_test_red.png")

static var height : int = 125

var _current_time : float

var state : State = State.TO_HIT

var _is_selected : bool = false
var _is_valid : bool = true

var _idx : int

var powered : bool = false

enum Fever {NONE = 0, X1 = 20, X2 = 40, X3 = 60, X4 = 80, X5 = 100, ZONE = 120, MAX_ZONE = 140}
const FEVER_VALUE : float = 1.0

func _init(current_time : float) -> void:
	_current_time = current_time
	
	size = Vector2(NoteHolder.width, height)
	position = Vector2(-size / 2)
	z_as_relative = false
	z_index = 5

func set_time(time : float) -> void:
	_current_time = time

func get_time() -> float:
	return _current_time

func is_selected() -> bool:
	return _is_selected

func is_valid() -> bool:
	return _is_valid

func set_idx(idx : int) -> void:
	_idx = idx

func get_idx() -> int:
	return _idx

func set_note_type(type : Type) -> void:
	if type == Type.BLUE:
		texture = NORMAL_NOTE_BLUE_IMG
	else:
		texture = NORMAL_NOTE_RED_IMG

func to_resource() -> NoteResource:
	var end_time := 0.0
	var type := NoteResource.Type.HOLD if self is HoldNote else NoteResource.Type.TAP
	var note = self ## KKKKKKKKKKKKKKKKKKKKKKK PILANTRAGEM HEIN
	end_time = note.get_end_time() if note is HoldNote else end_time
	return NoteResource.new(_current_time, end_time, _idx, type, powered, _is_valid, _is_selected)
	
