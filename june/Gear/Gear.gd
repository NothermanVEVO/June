extends Node2D

class_name Gear

enum Type {FOUR_KEYS = 4, FIVE_KEYS = 5, SIX_KEYS = 6}
var _type : int

var _note_holders : Array[NoteHolder]

const width : float = 500

var _center_screen : bool = true

enum Mode{PLAYER, EDITOR}
static var mode : Mode

static var _max_size_y : float = -1

static var _speed : float = 1.0

var _long_notes : Array[LongNote] = []
var _last_visible_long_notes : Array[LongNote]

var _number_of_last_processed_signals_received : int = 0
signal last_note_was_processed

var _currently_long_note_idx : int = 0
static var _game_speed := 1.0

static var _time_after_song_finished : float = 0.0

var _speed_tween : Tween

signal fade_out
signal fade_in
signal section_changed(title : String)

@warning_ignore("shadowed_variable")
func _init(type : Type, mode : Mode, center_screen : bool = true, max_size_y : float = -1) -> void:
	_type = type
	self.mode = mode
	_game_speed = 1.0
	_time_after_song_finished = 0.0
	_center_screen = center_screen
	if max_size_y >= 0:
		_max_size_y = max_size_y
	var dict := Global.get_settings_dictionary()
	if dict["game_gear_position"] == GameSettingsScreen.GearPositions.LEFT:
		position.x -= 625
	elif dict["game_gear_position"] == GameSettingsScreen.GearPositions.RIGHT:
		position.x += 625

func _ready() -> void: #TODO HANDLE ANY POSITION FOR THE GEAR, NOT ONLY THE MIDDLE
	if _max_size_y < 0:
		_max_size_y = get_viewport_rect().size.y + Note.height
	
	_note_holders.clear()
	
	NoteHolder.width = width / float(_type)
	Note.height = NoteHolder.width
	var initial_x
	if _center_screen:
		initial_x = (get_viewport_rect().size.x / 2) - (width / 2) + (NoteHolder.width / 2)
	else:
		var position_difference := 0.0 if mode == Mode.EDITOR else position.x
		initial_x = -(width / 2) + (NoteHolder.width / 2) + position_difference
	
	for i in range(_type):
		var note_type : Note.Type = Note.Type.RED if (i == 1 or i == _type - 2) else Note.Type.BLUE
		var note_holder := NoteHolder.new(str(i + 1) + "_" + str(_type) + "k", initial_x, note_type)
		note_holder.last_note_was_processed.connect(_note_holders_last_processed_notes)
		initial_x += NoteHolder.width
		_note_holders.append(note_holder)
		add_child(note_holder)
		note_holder.changed_note.connect(_changed_note_from_note_holder)

func _process(_delta: float) -> void:
	match mode:
		Mode.PLAYER:
			_player_process()
		Mode.EDITOR:
			_editor_process()

func _player_process() -> void:
	if Song.is_finished():
		_time_after_song_finished += get_process_delta_time()
	
	if _currently_long_note_idx >= _long_notes.size():
		return
	
	if _long_notes[_currently_long_note_idx].get_time() <= Song.get_time():
		match _long_notes[_currently_long_note_idx].get_type():
			LongNote.Type.SECTION:
				section_changed.emit(_long_notes[_currently_long_note_idx].get_section())
			LongNote.Type.SPEED:
				_fade_change_speed()
			LongNote.Type.FADE:
				if _long_notes[_currently_long_note_idx].fade:
					for note_holder in _note_holders:
						if note_holder.get_notes(Song.get_time(), Song.get_duration()).size() > 0:
							fade_in.emit()
							_currently_long_note_idx += 1
							return
				else:
					fade_out.emit()
		_currently_long_note_idx += 1

func _fade_change_speed() -> void:
	var target_speed = _long_notes[_currently_long_note_idx].get_speed()

	if _speed_tween and _speed_tween.is_running():
		_speed_tween.kill()

	_speed_tween = create_tween()
	_speed_tween.tween_method(_set_game_speed, _game_speed, target_speed, 0.3)

func _set_game_speed(speed : float) -> void:
	_game_speed = speed
	Global.speed_changed.emit()

func _editor_process() -> void:
	if not _long_notes:
		return
	
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

static func get_time_after_song_finished() -> float:
	return _time_after_song_finished

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

func validate_all_note_holders() -> void:
	for note_holder in _note_holders:
		note_holder.validate_notes(0.0, Song.get_time())

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

## WHY ARE YOU DOING THIS LIKE THIS???
func remove_long_note_from_time(time : float, type : LongNote.Type, note_value, free : bool = false, validate : bool = false) -> void:
	var _lg_notes := get_long_notes(time, time)
	for long_note in _lg_notes:
		if type == LongNote.Type.ANNOTATION and long_note.get_annotation() == note_value:
			_long_notes.erase(long_note)
			_last_visible_long_notes.erase(long_note)
			remove_child.call_deferred(long_note)
			if free:
				long_note.call_deferred("queue_free")
			if validate:
				_validate_long_notes()
			break
		elif type == LongNote.Type.SECTION and long_note.get_section() == note_value:
			_long_notes.erase(long_note)
			_last_visible_long_notes.erase(long_note)
			remove_child.call_deferred(long_note)
			if free:
				long_note.call_deferred("queue_free")
			if validate:
				_validate_long_notes()
			break
		elif type == LongNote.Type.SPEED and long_note.get_speed() == float(note_value):
			_long_notes.erase(long_note)
			_last_visible_long_notes.erase(long_note)
			remove_child.call_deferred(long_note)
			if free:
				long_note.call_deferred("queue_free")
			if validate:
				_validate_long_notes()
			break
		elif type == LongNote.Type.FADE and long_note.get_fade() == str_to_var(note_value):
			_long_notes.erase(long_note)
			_last_visible_long_notes.erase(long_note)
			remove_child.call_deferred(long_note)
			if free:
				long_note.call_deferred("queue_free")
			if validate:
				_validate_long_notes()
			break

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
	while i < _long_notes.size() and (_long_notes[i].get_time() < to or is_equal_approx(_long_notes[i].get_time(), to)):
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
	for i in range(0, fade_notes.size(), 2):
		var found_pair := false
		if not fade_notes[i].fade: # FADE OUT
			if i + 1 < fade_notes.size():
				if fade_notes[i + 1].fade: # FADE IN
					fade_notes[i].set_invalid_highlight(false)
					fade_notes[i + 1].set_invalid_highlight(false)
					found_pair = true
					var notes := get_notes_between(fade_notes[i].get_time(), fade_notes[i + 1].get_time())
					for note in notes:
						note.set_invalid_highlight(true)
				else:
					fade_notes[i + 1].set_invalid_highlight(true)
			else:
				fade_notes[i].set_invalid_highlight(true)
		elif not found_pair:
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
	return clampf(NoteHolder.SECS_SIZE_Y / _speed / _game_speed, NoteHolder.SECS_SIZE_Y / 10, NoteHolder.SECS_SIZE_Y)

func add_note_at(idx : int, note : Note, validate_note : bool = false) -> void:
	note.set_idx(idx)
	_note_holders[idx].add_note(note, validate_note)

func remove_note_at(idx : int, note : Note, validate_note : bool = false, free : bool = false) -> void:
	_note_holders[idx].remove_note(note, validate_note, free)

func remove_note_at_time(time : float, end_time : float, idx : int, type : NoteResource.Type, validate_note : bool = false, free : bool = false) -> void:
	_note_holders[idx].remove_note_at_time(time, end_time, type, validate_note, free)

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
			if not note.visible or (note is HoldNoteEditor and (note.get_start_time() > Song.get_time() + Gear.MAX_TIME_Y() or note.get_end_time() < Song.get_time())
				) or (note is NoteEditor and (note.get_time() > Song.get_time() + Gear.MAX_TIME_Y() or note.get_time() < Song.get_time())):
					continue
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

func _note_holders_last_processed_notes() -> void:
	_number_of_last_processed_signals_received += 1
	
	var number_of_empty_note_holders := 0
	for note_holder in _note_holders:
		if note_holder.is_empty():
			number_of_empty_note_holders += 1
	
	if _number_of_last_processed_signals_received >= _note_holders.size() - number_of_empty_note_holders:
		last_note_was_processed.emit()

func _draw() -> void:
	#draw_circle(Vector2.ZERO, 10, Color.AQUA)
	#var rect := Rect2(-width / 2, -get_viewport_rect().size.y, width, get_viewport_rect().size.y).abs()
	#
	#draw_rect(rect, Color(0, 0, 0, 0.5))
	pass
	
