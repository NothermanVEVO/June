extends NinePatchRect

class_name Note

enum State {TO_HIT, HITTED, BREAK}

const NORMAL_NOTE_IMG = preload("res://assets/noteFormated.png")

static var height : int = 25

var _current_time : float

var state : State = State.TO_HIT

var _is_selected : bool = false
var _is_valid : bool = true

var _idx : int

var powered : bool = false

func _init(current_time : float) -> void:
	_current_time = current_time
	
	texture = NORMAL_NOTE_IMG
	size = Vector2(NoteHolder.width, height)
	position = Vector2(-size / 2)
	z_index = 1

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

func to_resource() -> NoteResource:
	var end_time := 0.0
	var type := NoteResource.Type.HOLD if self is HoldNote else NoteResource.Type.TAP
	var note = self ## KKKKKKKKKKKKKKKKKKKKKKK PILANTRAGEM HEIN
	end_time = note.get_end_time() if note is HoldNote else end_time
	return NoteResource.new(_current_time, end_time, _idx, type, powered, _is_valid, _is_selected)
	
