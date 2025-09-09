extends Node2D

class_name Gear

enum Type {FOUR_KEYS = 4, FIVE_KEYS = 5, SIX_KEYS = 6}
var _type : int

var _note_holders : Array[NoteHolder]

const width : float = 400

var _center_screen : bool = true

enum Mode{PLAYER, EDITOR}
static var mode : Mode

static var _max_size_y : float = -1

static var _speed : float = 1.0

var _long_notes : Array[LongNote]
var _last_visible_long_notes : Array[LongNote]

@warning_ignore("shadowed_variable")
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
	
	NoteHolder.width = width / float(_type)
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
		note_holder.changed_note.connect(_changed_note_from_note_holder)

func _physics_process(_delta: float) -> void:
	if not _long_notes:
		return
	
	match mode:
		Mode.PLAYER:
			pass
		Mode.EDITOR:
			_editor_process()

func _editor_process() -> void:
	var long_notes = get_long_notes(Song.get_time(), Song.get_time() + MAX_TIME_Y())
	
	for long_note in _last_visible_long_notes:
		if not long_note in long_notes:
			long_note.visible = false
	
	for long_note in long_notes:
		long_note.visible = true
		var time_pos_y = NoteHolder.get_local_pos_y(NoteHolder.get_hitzone() - LongNote.height / 2, -_max_size_y + NoteHolder.get_hitzone() - LongNote.height / 2, long_note.get_time(), Song.get_time(), Song.get_time() + MAX_TIME_Y())
		long_note.position.x = -width / 2
		long_note.position.y = time_pos_y
	
	_last_visible_long_notes = long_notes

func get_all_long_notes() -> Array[LongNote]:
	return _long_notes

func _fade_note_value_changed() -> void:
	_validate_long_notes()

func get_all_notes() -> Array[Note]:
	var notes : Array[Note] = []
	for note_holder in _note_holders:
		for note in note_holder.get_all_notes():
			notes.append(note)
	return notes

func add_long_note(long_note : LongNote, validate : bool = false) -> void:
	if long_note.get_type() == LongNote.Type.FADE:
		long_note.value_changed.connect(_fade_note_value_changed)
	
	var low := 0
	var high := _long_notes.size()

	while low < high:
		@warning_ignore("integer_division")
		var mid := (low + high) / 2
		if long_note.get_time() < _long_notes[mid].get_time():
			high = mid
		else:
			low = mid + 1

	_long_notes.insert(low, long_note)
	add_child.call_deferred(long_note)
	long_note.visible = false
	
	if validate:
		_validate_long_notes()

func remove_long_note(long_note : LongNote, free : bool = false, validate : bool = false) -> void:
	_long_notes.erase(long_note)
	_last_visible_long_notes.erase(long_note)
	remove_child.call_deferred(long_note)
	if free:
		long_note.call_deferred("queue_free")
	if validate:
		_validate_long_notes()

func get_long_notes(from : float, to : float) -> Array[LongNote]:
	var result : Array[LongNote] = []
	var low := 0
	var high := _long_notes.size()

	while low < high:
		@warning_ignore("integer_division")
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

func update_long_note(long_note : LongNote, validate : bool = false) -> void:
	_long_notes.erase(long_note)
	
	var low := 0
	var high := _long_notes.size()

	while low < high:
		@warning_ignore("integer_division")
		var mid := (low + high) / 2
		if long_note.get_time() < _long_notes[mid].get_time():
			high = mid
		else:
			low = mid + 1

	_long_notes.insert(low, long_note)
	
	if validate:
		_validate_long_notes()

func _validate_long_notes() -> void: # EH FEIO ISSO AQ MAS TO COM PREGUIÇA DE FAZER MELHOR
	for note_holder in _note_holders:
		note_holder.validate_notes(0.0, Song.get_duration())
		
		for note in _long_notes:
			note.set_invalid_highlight(get_long_notes(note.get_time(), note.get_time()).size() > 1)
		
		var fade_notes : Array[LongNote] = []
		for note in _long_notes:
			if note.get_type() == LongNote.Type.FADE:
				fade_notes.append(note)
		
		if not fade_notes:
			return
			
		_validate_fade_notes(fade_notes)

func _validate_fade_notes(fade_notes : Array[LongNote]) -> void: # DOESN'T WORK PERFECT LIKE INTENDED IF SOME LONG NOTES IN THE SAME TIME POS
	var valid_fade_notes_idxs : Array[int] = []
	var j_limit := fade_notes.size() - 1
	for i in range(0, fade_notes.size(), 1):
		if valid_fade_notes_idxs.has(i):
			continue
		if not fade_notes[i].fade: # FADE OUT
			var found_fade_in := false
			for j in range(j_limit, i, -1):
				if fade_notes[j].fade:
					j_limit -= 1
					found_fade_in = not fade_notes[i].get_time() == fade_notes[j].get_time()
					if found_fade_in:
						valid_fade_notes_idxs.append(j)
					var notes := get_notes_between(fade_notes[i].get_time(), fade_notes[j].get_time())
					for note in notes:
						note.set_invalid_highlight(true)
					break
				else:
					fade_notes[j].set_invalid_highlight(true)
			fade_notes[i].set_invalid_highlight(not found_fade_in)
		else:
			fade_notes[i].set_invalid_highlight(true)

func get_global_long_note_intersected_rects(rect : Rect2) -> LongNote:
	for long_note in _long_notes:
		if long_note.get_global_rect().intersects(rect):
			return long_note
	return null

func _changed_note_from_note_holder() -> void:
	var fade_notes : Array[LongNote] = []
	
	for long_note in _long_notes:
		if long_note.get_type() == LongNote.Type.FADE:
			fade_notes.append(long_note)
	_validate_fade_notes(fade_notes)

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

func set_hitzone(hitzone : float) -> void:
	for note_holder in _note_holders:
		note_holder.set_hitzone(hitzone)

func _draw() -> void:
	draw_circle(Vector2.ZERO, 10, Color.AQUA)
	var rect := Rect2(-width / 2, -get_viewport_rect().size.y, width, get_viewport_rect().size.y).abs()
	print(rect)
	
	draw_rect(rect, Color(0, 0, 0, 0.5))
	
