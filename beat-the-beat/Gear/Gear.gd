extends Node2D

class_name Gear

enum Type {FOUR_KEYS = 4, FIVE_KEYS = 5, SIX_KEYS = 6}
static var _type : int

static var _note_holders : Array[NoteHolder]

const width := 500

var _center_screen : bool = true

enum Mode{PLAYER, EDITOR}
static var mode : Mode

static var _max_size_y : float = -1

static var current_time : float = 0.0

func _init(type : Type, mode : Mode, center_screen : bool = true, max_size_y : float = -1) -> void:
	_type = type
	self.mode = mode
	_center_screen = center_screen
	if max_size_y >= 0:
		_max_size_y = max_size_y

func _ready() -> void: #TODO HANDLE ANY POSITION FOR THE GEAR, NOT ONLY THE MIDDLE
	if _max_size_y < 0:
		_max_size_y = get_viewport_rect().size.y + Note.height
	
	_note_holders.clear()
	
	NoteHolder.width = width / _type
	var initial_x
	if _center_screen:
		initial_x = (get_viewport_rect().size.x / 2) - (width / 2) + (NoteHolder.width / 2)
	else:
		initial_x = -(width / 2) + (NoteHolder.width / 2)
	
	for i in range(_type):
		var note_holder := NoteHolder.new(str(i + 1) + "_" + str(_type) + "k", initial_x)
		initial_x += NoteHolder.width
		_note_holders.append(note_holder)
		add_child(note_holder)

func add_note_at(idx : int, note : Note, validate_note : bool = false) -> void:
	note.set_idx(idx)
	_note_holders[idx].add_note(note, validate_note)

static func remove_note_at(idx : int, note : Note, validate_note : bool = false) -> void:
	_note_holders[idx].remove_note(note, validate_note)

static func get_type() -> int:
	return _type

static func get_note_holders_global_position() -> Array[Vector2]:
	var array : Array[Vector2] = []
	for note_holder in _note_holders:
		array.append(note_holder.global_position)
	return array

static func get_global_intersected_rects(rect : Rect2) -> Array[Note]:
	var array : Array[Note] = []
	for note_holder in _note_holders:
		for note in note_holder.get_notes_array():
			if note is HoldNote and rect.intersects(note.get_global_hold_rect(), true):
				array.append(note)
			elif rect.intersects(note.get_global_rect(), true):
				array.append(note)
	return array

static func change_note_from_note_holder(from : int, to : int, note : Note, validate_note : bool = false) -> void:
	if from == to:
		_note_holders[from].update_note(note, validate_note)
		return
	_note_holders[from].remove_note(note, validate_note)
	note.set_idx(to)
	_note_holders[to].add_note(note, validate_note)

static func get_notes_between(from : float, to : float) -> Array[Note]:
	var notes : Array[Note] = []
	for note_holder in _note_holders:
		for note in note_holder.get_notes(from, to):
			notes.append(note)
	return notes

static func update_note_time(note : Note, validate_note : bool = false) -> void:
	if note is NoteEditor:
		note.update_start_time_text()
	elif note is HoldNoteEditor:
		note.update_start_time_text()
		note.update_end_time_text()
	change_note_from_note_holder(note.get_idx(), note.get_idx(), note, validate_note)

func set_max_size_y(max_size_y : float) -> void:
	_max_size_y = max_size_y
	if _max_size_y < 0:
		_max_size_y = get_viewport_rect().size.y + Note.height

static func get_max_size_y() -> float:
	return _max_size_y

func _draw() -> void:
	draw_circle(Vector2.ZERO, 10, Color.AQUA)
