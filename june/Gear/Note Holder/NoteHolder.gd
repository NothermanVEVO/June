extends Node2D

class_name NoteHolder

var _note_action : String = ""

var _notes : Array[Note]

static var width : float = 0.0

var _pos_x := 0.0
static var _hit_zone_y : float = -50.0 # SET THE POSITION OF THE HITZONE #NOTE

const SECS_SIZE_Y = 4 # SPEED OF THE GAME

var _last_visible_notes : Array[Note] = []

var _key_pressed_gradient := KeyPressedGradient.new()

const _hit_effect_scene := preload("res://Effects/HitEffect.tscn")
var _hit_effect : HitEffect

var _currently_note_idx : int = 0

const MAX_TIME_HIT : float = 0.25 # THE MAXIMUM HIT RANGE

var _hitted_hold_note_precision : int = 0
var _holding_note_time : float = 0.0
const HOLDING_NOTE_DELAY : float = 0.15

var _note_type : Note.Type

var _note_size_time : float = 0.0

var _last_note_was_processed : bool = false

signal changed_note

signal last_note_was_processed

func _init(note_action : String, pos_x : float, note_type : Note.Type) -> void:
	_note_action = note_action
	_pos_x = pos_x
	_note_type = note_type

func _ready() -> void:
	position = Vector2(_pos_x, _hit_zone_y)
	add_child(_key_pressed_gradient)
	Global.changed_hitzone_y.connect(_changed_hitzone_y)
	
	_hit_effect = _hit_effect_scene.instantiate()
	add_child(_hit_effect)
	
	Global.changed_max_size_y.connect(_calculate_note_size_time)
	Global.speed_changed.connect(_calculate_note_size_time)
	
	_calculate_note_size_time()

func _process(_delta: float) -> void:
	
	match Gear.mode:
		Gear.Mode.PLAYER:
			_player_process()
		Gear.Mode.EDITOR:
			queue_redraw() #TODO REMOVE THIS LATER, FOR THE SAKE OF GOD
			_editor_process()

func _player_process() -> void:
	#if not _notes:
		#return
	
	if _last_note_was_processed:
		if Input.is_action_just_pressed(_note_action):
			_key_pressed_gradient.key_just_pressed()
		elif Input.is_action_just_released(_note_action):
			_key_pressed_gradient.key_just_released()
		return
	
	var time : float
	
	if MusicPlayer.get_current_time() >= MusicPlayer.TIME_TO_START and not Song.is_finished():
		time = Song.get_time()
	elif MusicPlayer.get_current_time() < MusicPlayer.TIME_TO_START:
		time = MusicPlayer.get_current_time() - MusicPlayer.TIME_TO_START
	elif Song.is_finished() and Song.get_time() >= Song.get_duration():
		time = Song.get_duration() + Gear.get_time_after_song_finished()
	
	if _currently_note_idx < _notes.size():
		if _notes[_currently_note_idx] is HoldNote:
			if _notes[_currently_note_idx].state == Note.State.HITTED:
				if _notes[_currently_note_idx].get_end_time() < time - MAX_TIME_HIT:
					_notes[_currently_note_idx].end_state = Note.State.HITTED
					if Global.main_music_player:
						Global.main_music_player.pop_precision(1)
						Global.main_music_player.add_score(MusicPlayer.get_value_of_note() / 100)
					_currently_note_idx += 1
					_check_for_last_note_processed()
				elif _holding_note_time >= HOLDING_NOTE_DELAY and not _notes[_currently_note_idx].get_end_time() < time:
					if Global.main_music_player:
						Global.main_music_player.pop_precision(_hitted_hold_note_precision)
						_hit_effect.play_effect(99)
						_holding_note_time = 0.0
				else:
					_holding_note_time += get_process_delta_time()
			if _notes[_currently_note_idx].state == Note.State.TO_HIT:
				if _notes[_currently_note_idx].get_start_time() < time - MAX_TIME_HIT:
					_notes[_currently_note_idx].end_state = Note.State.BREAK
					if Global.main_music_player:
						Global.main_music_player.pop_precision(0)
					_notes[_currently_note_idx].modulate.a = 0.5
					_currently_note_idx += 1
					_check_for_last_note_processed()
		elif _notes[_currently_note_idx].get_time() < time - MAX_TIME_HIT:
			_notes[_currently_note_idx].state = Note.State.BREAK
			if Global.main_music_player:
				Global.main_music_player.pop_precision(0)
			_currently_note_idx += 1
			_check_for_last_note_processed()
	
	if Input.is_action_just_pressed(_note_action):
		_key_pressed_gradient.key_just_pressed()
		_hit(time)
	elif Input.is_action_just_released(_note_action):
		_key_pressed_gradient.key_just_released()
		_hit_hold_note(time)
	
	display_notes(time)

func _check_for_last_note_processed() -> void:
	if _currently_note_idx >= _notes.size():
		last_note_was_processed.emit()
		_last_note_was_processed = true

func _editor_process() -> void:
	if not Input.is_action_just_pressed("Save") and Input.is_action_just_pressed(_note_action):
		_key_pressed_gradient.key_just_pressed()
	elif Input.is_action_just_released(_note_action):
		_key_pressed_gradient.key_just_released()
	
	var time : float = Song.get_time()
	display_notes(time)

func _calculate_note_size_time() -> void:
	_note_size_time = get_time_pos_y(float(Note.height) / 2, Gear.get_max_size_y() + float(Note.height) / 2, float(Note.height) + float(Note.height) / 2, 0, Gear.MAX_TIME_Y())

func display_notes(time : float) -> void:
	var notes := get_notes(time - _note_size_time, time + Gear.MAX_TIME_Y() + _note_size_time)
	for note in _last_visible_notes:
		if not note in notes:
			note.visible = false
	
	for note in notes:
		note.visible = note.end_state != Note.State.HITTED if note is HoldNote else note.state == Note.State.TO_HIT
		if not note.visible:
			continue
		note.position.x = -width / 2
		note.position.y = -get_local_pos_y_correct(float(Note.height) / 2, Gear.get_max_size_y() + float(Note.height) / 2, note.get_time(), time, time + Gear.MAX_TIME_Y())
		
		if note.get_time() < time:
			var p_time = note.get_time() + (time - note.get_time())
			var difference = -get_local_pos_y_correct(0, Gear.get_max_size_y(), p_time, note.get_time(), note.get_time() + Gear.MAX_TIME_Y())
			while p_time - Gear.MAX_TIME_Y() > 0.0:
				p_time -= Gear.MAX_TIME_Y()
				difference -= get_local_pos_y_correct(0, Gear.get_max_size_y(), p_time, note.get_time(), note.get_time() + Gear.MAX_TIME_Y())
			note.position.y -= difference
		elif note.get_time() > time + Gear.MAX_TIME_Y():
			var p_time = note.get_time() - (time + Gear.MAX_TIME_Y())
			var difference = -get_local_pos_y_correct(0, Gear.get_max_size_y(), p_time, 0, Gear.MAX_TIME_Y())
			while p_time > Gear.MAX_TIME_Y():
				p_time -= Gear.MAX_TIME_Y()
				difference -= get_local_pos_y_correct(0, Gear.get_max_size_y(), p_time, 0, Gear.MAX_TIME_Y())
			note.position.y += difference
	
	_last_visible_notes = notes

func _hit(time : float) -> void:
	if _currently_note_idx >= _notes.size():
		return
	if _notes[_currently_note_idx].get_time() >= time - MAX_TIME_HIT and _notes[_currently_note_idx].get_time() <= time + MAX_TIME_HIT:
		_notes[_currently_note_idx].state = Note.State.HITTED
		var precision := _calculate_difference(time, _notes[_currently_note_idx].get_time())
		if not _notes[_currently_note_idx] is HoldNote and Global.main_music_player:
			Global.main_music_player.pop_precision(precision)
			_hit_effect.play_effect(99)
			Global.main_music_player.add_score(MusicPlayer.get_value_of_note() * abs(precision) / 100)
			_currently_note_idx += 1
			_check_for_last_note_processed()
		elif _notes[_currently_note_idx] is HoldNote:
			if Global.main_music_player:
				Global.main_music_player.pop_precision(precision)
			if precision == 0:
				_notes[_currently_note_idx].modulate.a = 0.5
				_notes[_currently_note_idx].state == Note.State.BREAK
				_currently_note_idx += 1
				_check_for_last_note_processed()
				return
			_hit_effect.play_effect(99)
			_hitted_hold_note_precision = precision
			#if precision > 0 and precision != 100: ## DOES THAT WORK?? WORK AT THIS IN THE FUTURE TODO
				#_notes[_currently_note_idx].set_start_time(time)

func _hit_hold_note(time : float) -> void:
	if _currently_note_idx >= _notes.size():
		return
	if _notes[_currently_note_idx] is HoldNote and _notes[_currently_note_idx].state == Note.State.HITTED:
		_notes[_currently_note_idx].end_state = Note.State.HITTED
		var precision := _calculate_difference(time, _notes[_currently_note_idx].get_end_time())
		if time < _notes[_currently_note_idx].get_end_time() - MAX_TIME_HIT:
			_notes[_currently_note_idx].modulate.a = 0.5
			_notes[_currently_note_idx].end_state = Note.State.BREAK
			precision = 0
		elif time > _notes[_currently_note_idx].get_end_time():
			if precision == 0 or time > _notes[_currently_note_idx].get_end_time() + MAX_TIME_HIT: ## DOES THAT WORK? COULDN'T TEST
				precision = -1
		if abs(precision) < abs(_hitted_hold_note_precision):
			_hitted_hold_note_precision = precision
		Global.main_music_player.pop_precision(_hitted_hold_note_precision)
		_hit_effect.play_effect(99)
		Global.main_music_player.add_score(MusicPlayer.get_value_of_note() * abs(_hitted_hold_note_precision) / 100)
		_currently_note_idx += 1
		_check_for_last_note_processed()
		_holding_note_time = 0.0

func _calculate_difference(time : float, note_time : float) -> int:
	var difference : float = Global.get_percentage_between(time, time + MAX_TIME_HIT, note_time) * 100
	var value : int = sign(difference)
	difference = abs(abs(difference) - 100)
	return _calculate_round_precision(difference, value)

func _calculate_round_precision(difference : float, value : int) -> int: ## YES... EVERYTHING IS A LIE.
	if difference >= 80.0: ## TO NOT BE SO FRUSTRATING
		return 100
	elif difference >= 72.5 and difference < 80.0:
		return 90 * value
	elif difference >= 65.0 and difference < 72.5:
		return 80 * value
	elif difference >= 57.5 and difference < 65.0:
		return 70 * value
	elif difference >= 52.5 and difference < 57.5:
		return 60 * value
	elif difference >= 47.5 and difference < 52.5:
		return 50 * value
	elif difference >= 42.5 and difference < 47.5:
		return 40 * value
	elif difference >= 37.5 and difference < 42.5:
		return 30 * value
	elif difference >= 32.5 and difference < 37.5:
		return 20 * value
	elif difference >= 25.0 and difference < 32.5:
		return 10 * value
	elif difference >= 20.0 and difference < 25.0:
		return 1 * value
	elif difference >= 0.0 and difference < 20.0: ## YOU BETTER NOT TRY TO SPAM
		return 0
	return 0

#func _calculate_round_precision(difference : float, value : int) -> int: ## NOTE OLD PRECISION VALUES METHOD
	#if difference >= 92.5:
		#return 100
	#elif difference >= 82.5 and difference < 92.5:
		#return 90 * value
	#elif difference >= 72.5 and difference < 82.5:
		#return 80 * value
	#elif difference >= 62.5 and difference < 72.5:
		#return 70 * value
	#elif difference >= 52.5 and difference < 62.5:
		#return 60 * value
	#elif difference >= 42.5 and difference < 52.5:
		#return 50 * value
	#elif difference >= 32.5 and difference < 42.5:
		#return 40 * value
	#elif difference >= 22.5 and difference < 32.5:
		#return 30 * value
	#elif difference >= 12.5 and difference < 22.5:
		#return 20 * value
	#elif difference >= 5.0 and difference < 12.5:
		#return 10 * value
	#elif difference >= 2.5 and difference < 5.0:
		#return 1 * value
	#elif difference >= 0.0 and difference < 2.5:
		#return 0
	#return 0

func add_note(note : Note, validate_note : bool = false) -> void:
	var low := 0
	var high := _notes.size()

	while low < high:
		@warning_ignore("integer_division")
		var mid := (low + high) / 2
		if note.get_time() < _notes[mid].get_time():
			high = mid
		else:
			low = mid + 1

	_notes.insert(low, note)
	add_child.call_deferred(note)
	note.visible = false
	
	if not note is NoteEditor and not note is HoldNoteEditor:
		if note is HoldNote:
			note.set_type_hold_note(_note_type)
		else:
			note.set_note_type(_note_type)
	
	if validate_note:
		if note is HoldNote:
			validate_notes(note.get_start_time(), note.get_end_time())
		else:
			validate_notes(note.get_time(), note.get_time())
		changed_note.emit()

func remove_note(note : Note, validate_note : bool = false, free : bool = false) -> void:
	_notes.erase(note)
	_last_visible_notes.erase(note)
	remove_child.call_deferred(note)
	if free:
		note.call_deferred("queue_free")
	if validate_note:
		validate_notes(0.0, Song.get_duration()) # EH FEIO FAZER ISSO AQ, PREGUIÇOSO
		changed_note.emit()

func remove_note_at_time(time : float, end_time : float, type : NoteResource.Type, validate_note : bool = false, free : bool = false) -> void:
	var notes_at_time := get_notes(time, time)
	for note in notes_at_time:
		if type == NoteResource.Type.TAP and not note is HoldNote and note is Note:
			remove_note(note, validate_note, free)
			return
		elif type == NoteResource.Type.HOLD and note is HoldNote and note.get_start_time() == time and note.get_end_time() == end_time:
			remove_note(note, validate_note, free)
			return

func update_note(note : Note, validate_note : bool = false) -> void:
	_notes.erase(note)
	
	var low := 0
	var high := _notes.size()

	while low < high:
		@warning_ignore("integer_division")
		var mid := (low + high) / 2
		if note.get_time() < _notes[mid].get_time():
			high = mid
		else:
			low = mid + 1

	_notes.insert(low, note)
	if validate_note:
		validate_notes(0.0, Song.get_duration()) # EH FEIO FAZER ISSO AQ, PREGUIÇOSO
		changed_note.emit()

func get_notes(from : float, to : float) -> Array[Note]:
	var result : Array[Note] = []
	var low := 0
	var high := _notes.size()

	for note in _notes: ## THIS IS REALLY BAD :( IMPROVE THIS SHIT LATER, WITH JUST A SMALL AMOUNT OF NOTES, IT ALREADY INCREASES 
						## THE TIME BY 0.04 ms, WITHOUT THIS THE COST OF THIS FUNCTION IS DIVIDED BY 2
		if note is HoldNote and (note.get_time() < from and (note.get_time() + note.get_duration()) > from):
			result.append(note)
			break

	while low < high:
		@warning_ignore("integer_division")
		var mid := (low + high) / 2
		if _notes[mid].get_time() < from:
			low = mid + 1
		else:
			high = mid

	var i := low
	while i < _notes.size() and (_notes[i].get_time() < to or is_equal_approx(_notes[i].get_time(), to)):
		result.append(_notes[i])
		i += 1

	return result

func is_empty() -> bool:
	return _notes.is_empty()

func validate_notes(from : float, to : float) -> bool:
	var is_valid := true
	var notes := get_notes(from, to)
	var invalid_notes : Array[Note] = []
	for note in notes:
		if note is HoldNoteEditor:
			var temp_notes := get_notes(note.get_start_time(), note.get_end_time())
			if temp_notes.size() > 1:
				is_valid = false
				for temp_note in temp_notes:
					temp_note.set_invalid_highlight(true)
					invalid_notes.append(temp_note)
			elif note.get_end_time() <= note.get_start_time():
				note.set_invalid_highlight(true)
				invalid_notes.append(note)
			else:
				if not invalid_notes.has(note):
					note.set_invalid_highlight(false)
		elif note is NoteEditor:
			var temp_notes := get_notes(note.get_time(), note.get_time())
			if temp_notes.size() > 1:
				is_valid = false
				for temp_note in temp_notes:
					temp_note.set_invalid_highlight(true)
					invalid_notes.append(temp_note)
			else:
				if not invalid_notes.has(note):
					note.set_invalid_highlight(false)
	return is_valid

static func get_hitzone() -> float:
	return _hit_zone_y

static func set_hitzone(hitzone : float) -> void:
	_hit_zone_y = hitzone
	Global.changed_hitzone_y.emit()

func _changed_hitzone_y() -> void:
	position = Vector2(_pos_x, _hit_zone_y)

func get_notes_array() -> Array[Note]:
	return _notes

func get_all_notes() -> Array[Note]:
	return _notes

func _draw() -> void:
	if Gear.mode == Gear.Mode.PLAYER:
		return
	var pos = Vector2.ZERO
	#var rect_size_y = float(Note.height)
	var pos_x = pos.x - width / 2
	#var pos_y = pos.y - (rect_size_y / 2)
	#draw_rect(Rect2(pos_x, pos_y, width, rect_size_y), Color.BLUE)
	draw_line(Vector2(pos_x, pos.y), Vector2(pos_x, pos.y - Gear.get_max_size_y() - float(Note.height) / 2), Color.WHITE, 1, true)
	draw_line(Vector2(pos_x + width, pos.y), Vector2(pos_x + width, pos.y - Gear.get_max_size_y() - float(Note.height) / 2), Color.WHITE, 1, true)
	draw_line(pos - Vector2(width / 2, 0), pos + Vector2(width / 2, 0), Color.YELLOW, 10)
	#draw_circle(pos, 5, Color.YELLOW)
	#draw_circle(Vector2(pos.x, pos.y - max_note_distance), 
		#5, Color.RED)

static func get_time_pos_y(min_pos_y : float, max_pos_y : float, pos_y : float, min_time : float, max_time : float) -> float:
	var percentage = Global.get_percentage_between(min_pos_y, max_pos_y, pos_y)
	var value = min_time + (max_time - min_time) * percentage
	return clampf(value, min_time, max_time)

static func get_local_pos_y(min_pos_y : float, max_pos_y : float, time_pos_y : float, min_time : float, max_time : float) -> float:
	var percentage = Global.get_percentage_between(min_time, max_time, time_pos_y)
	var value = min_pos_y + (max_pos_y - min_pos_y) * percentage
	return clampf(value, max_pos_y, min_pos_y)

static func get_local_pos_y_correct(min_pos_y : float, max_pos_y : float, time_pos_y : float, min_time : float, max_time : float) -> float:
	var percentage = Global.get_percentage_between(min_time, max_time, time_pos_y)
	var value = min_pos_y + (max_pos_y - min_pos_y) * percentage
	return clampf(value, min_pos_y, max_pos_y)
