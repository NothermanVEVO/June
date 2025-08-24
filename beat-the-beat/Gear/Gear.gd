extends Node2D

class_name Gear

enum Type {FOUR_KEYS = 4, FIVE_KEYS = 5, SIX_KEYS = 6}
var _type : int

var _note_holders : Array[NoteHolder]

const width := 500

var _center_screen : bool = true

enum Mode{PLAYER, EDITOR}
static var mode : Mode

static var _max_size_y : float = -1

static var _speed : float = 1.0

var _long_notes : Array[LongNote]
var _last_visible_long_notes : Array[LongNote]

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

func _physics_process(delta: float) -> void:
	if not _long_notes:
		return
	
	match mode:
		Mode.PLAYER:
			pass
		Mode.EDITOR:
			_editor_process()

func _editor_process() -> void:
	var long_notes = get_long_notes(Song.get_time(), MAX_TIME_Y())
	
	for note in _last_visible_long_notes:
		if not note in long_notes:
			note.visible = false
			_last_visible_long_notes.erase(note)
	
	for long_note in long_notes:
		long_note.visible = true
		var time_pos_y = NoteHolder.get_local_pos_y(NoteHolder.get_hitzone() - LongNote.height / 2, -_max_size_y + NoteHolder.get_hitzone() - LongNote.height / 2, long_note.get_time(), Song.get_time(), Song.get_time() + MAX_TIME_Y())
		long_note.position.x = -width / 2
		long_note.position.y = time_pos_y
	
	_last_visible_long_notes = long_notes

func add_long_note(long_note : LongNote) -> void:
	var low := 0
	var high := _long_notes.size()

	while low < high:
		var mid := (low + high) / 2
		if long_note.get_time() < _long_notes[mid].get_time():
			high = mid
		else:
			low = mid + 1

	_long_notes.insert(low, long_note)
	add_child.call_deferred(long_note)
	long_note.visible = false

func remove_long_note(long_note : LongNote, free : bool = false) -> void:
	_long_notes.erase(long_note)
	_last_visible_long_notes.erase(long_note)
	remove_child.call_deferred(long_note)
	if free:
		long_note.call_deferred("queue_free")

func get_long_notes(from : float, to : float) -> Array[LongNote]:
	var result : Array[LongNote] = []
	var low := 0
	var high := _long_notes.size()

	while low < high:
		var mid := (low + high) / 2
		if _long_notes[mid].get_time() < from:
			low = mid + 1
		else:
			high = mid

	var i := low
	while i < _long_notes.size() and _long_notes[i].get_time() <= to:
		result.append(_long_notes[i])
		i += 1

	return result

func update_long_note(note : LongNote) -> void:
	_long_notes.erase(note)
	
	var low := 0
	var high := _long_notes.size()

	while low < high:
		var mid := (low + high) / 2
		if note.get_time() < _long_notes[mid].get_time():
			high = mid
		else:
			low = mid + 1

	_long_notes.insert(low, note)

func get_global_long_note_intersected_rects(rect : Rect2) -> LongNote:
	for long_note in _long_notes:
		if long_note.get_global_rect().intersects(rect):
			return long_note
	return null

static func set_speed(speed : float) -> void:
	_speed = clampf(speed, 0.0, 10.0)
	Global.speed_changed.emit()

static func get_speed() -> float:
	return _speed

static func MAX_TIME_Y() -> float:
	return NoteHolder.SECS_SIZE_Y / _speed

func add_note_at(idx : int, note : Note, validate_note : bool = false) -> void:
	note.set_idx(idx)
	_note_holders[idx].add_note(note, validate_note)

func remove_note_at(idx : int, note : Note, validate_note : bool = false, free : bool = false) -> void:
	_note_holders[idx].remove_note(note, validate_note, free)

func get_type() -> int:
	return _type

func get_note_holders_global_position() -> Array[Vector2]:
	var array : Array[Vector2] = []
	for note_holder in _note_holders:
		array.append(note_holder.global_position)
	return array

func get_global_note_intersected_rects(rect : Rect2) -> Array[Note]:
	var array : Array[Note] = []
	for note_holder in _note_holders:
		for note in note_holder.get_notes_array():
			if note is HoldNote and rect.intersects(note.get_global_hold_rect(), true):
				array.append(note)
			elif rect.intersects(note.get_global_rect(), true):
				array.append(note)
	return array

func change_note_from_note_holder(from : int, to : int, note : Note, validate_note : bool = false) -> void:
	if from == to:
		_note_holders[from].update_note(note, validate_note)
		return
	_note_holders[from].remove_note(note, validate_note)
	note.set_idx(to)
	_note_holders[to].add_note(note, validate_note)

func get_notes_between(from : float, to : float) -> Array[Note]:
	var notes : Array[Note] = []
	for note_holder in _note_holders:
		for note in note_holder.get_notes(from, to):
			notes.append(note)
	return notes

func update_note_time(note : Note, validate_note : bool = false) -> void:
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
	Global.changed_max_size_y.emit()

static func get_max_size_y() -> float:
	return _max_size_y

func _draw() -> void:
	draw_circle(Vector2.ZERO, 10, Color.AQUA)
