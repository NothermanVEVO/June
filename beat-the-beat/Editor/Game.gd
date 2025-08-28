extends Button

class_name GameEditor

@export_range(4, 6) var keys_quantity : int = 4

var gear : Gear

@onready var time_slider : HSlider = $"../../../SoundBoard/Time Slider"
@onready var focus_effect : ReferenceRect = $"Focus Effect"
@onready var soundboard : SoundBoard = $"../../../SoundBoard"

var sample_tap_note : Note

var _hit_zone_y : float

var _currently_hold_note : HoldNoteEditor

var _is_mouse_inside : bool = false

var _start_mouse_click_position : Vector2
var _clicked_note : Note
var _clicked_on_note : bool = false
var _last_grid_time_mouse : float
var _mouse_selection : Selection = Selection.new()
var _selected_notes : Array[Note] = []
var _selected_long_notes : Array[LongNote] = []
var _last_drag_mouse_position : Vector2
var _last_time_difference_y : float = 0.0
var _last_note_holder_idx : int = -1
var _had_time_difference : bool = false

var _clicked_long_note : LongNote

var _mouse_was_pressed_inside : bool = false

@onready var _mouse_time_container : PanelContainer = $"Mouse Time"
@onready var _mouse_time_text : RichTextLabel = $"Mouse Time/MarginContainer/RichTextLabel"

var _currently_sample_long_note : LongNote

var _sample_long_annotation_note : LongNote
var _sample_long_section_note : LongNote
var _sample_long_speed_note : LongNote

signal changed

func _ready() -> void:
	match keys_quantity:
		4:
			gear = Gear.new(Gear.Type.FOUR_KEYS, Gear.Mode.EDITOR, false, size.y)
		5:
			gear = Gear.new(Gear.Type.FIVE_KEYS, Gear.Mode.EDITOR, false, size.y)
		6:
			gear = Gear.new(Gear.Type.SIX_KEYS, Gear.Mode.EDITOR, false, size.y)
	add_child(gear)
	
	resized.connect(_resized)
	
	sample_tap_note = Note.new(0)
	add_child(sample_tap_note)
	sample_tap_note.position = Vector2(-10000000, -10000000)
	sample_tap_note.modulate = Color(1, 1, 1, 0.5)
	
	_sample_long_annotation_note = LongNote.new(0, LongNote.Type.ANNOTATION)
	add_child(_sample_long_annotation_note)
	_sample_long_annotation_note.set_process(false)
	_sample_long_annotation_note.position = Vector2(-10000000, -10000000)
	_sample_long_annotation_note.modulate = Color(1, 1, 1, 0.5)
	
	_sample_long_section_note = LongNote.new(0, LongNote.Type.SECTION)
	add_child(_sample_long_section_note)
	_sample_long_section_note.set_process(false)
	_sample_long_section_note.position = Vector2(-10000000, -10000000)
	_sample_long_section_note.modulate = Color(1, 1, 1, 0.5)
	
	_sample_long_speed_note = LongNote.new(0, LongNote.Type.SPEED)
	add_child(_sample_long_speed_note)
	_sample_long_speed_note.set_process(false)
	_sample_long_speed_note.position = Vector2(-10000000, -10000000)
	_sample_long_speed_note.modulate = Color(1, 1, 1, 0.5)
	
	_sample_long_annotation_note = _sample_long_annotation_note
	
	add_child(_mouse_selection)

func _resized() -> void:
	_hit_zone_y = size.y + NoteHolder.get_hitzone()
	gear.set_max_size_y(_hit_zone_y)
	gear.position.x = size.x / 2
	gear.position.y = size.y# - NoteHolder.get_hitzone()

func set_gear(type : Gear.Type) -> void:
	remove_child(gear)
	gear = Gear.new(type, Gear.Mode.EDITOR, false, size.y)
	add_child(gear)
	
	remove_child(sample_tap_note)
	sample_tap_note = Note.new(0)
	sample_tap_note.position = Vector2(-10000000, -10000000)
	sample_tap_note.modulate = Color(1, 1, 1, 0.5)
	add_child(sample_tap_note)
	
	_resized()

func _process(delta: float) -> void:
	focus_effect.visible = false
	queue_redraw() # TODO REMOVE THIS SHIT LATER 
	
	_display_mouse_time_position()
	
	if Input.is_action_just_pressed("Add Item"):
		_mouse_was_pressed_inside = get_global_rect().has_point(get_global_mouse_position())
	
	#if Input.is_action_pressed("Add Item") and _mouse_was_pressed_inside: #BUG TODO WARNING NOTE REALLY BUGGED
		#var mouse_time_difference_y := _get_time_difference_y() # BUG TIME DIFFERENCE IT'S NOT SO EFFICIENT
		## print(mouse_time_difference_y) # BUG USE THIS TO SEE
	#
		#var temp = mouse_time_difference_y
		#mouse_time_difference_y -= _last_time_difference_y
		#_last_time_difference_y = temp
	#
		#if get_local_mouse_position().y > _hit_zone_y and mouse_time_difference_y < 0 or get_local_mouse_position().y < 0 and mouse_time_difference_y > 0: #MOVE DOWN / MOVE UP
			#var song := Song.new()
			#song.set_time(clampf(Song.get_time() + mouse_time_difference_y, 0.0, Song.get_duration()))
	
	if GameComponents.get_selected_item_text() == "Power":
		Global.set_mouse_effect(MouseEffect.Effect.POWER_ITEM)
	else:
		Global.set_mouse_effect(MouseEffect.Effect.NONE)
	
	if has_focus():
		focus_effect.visible = true
		if Input.is_action_just_pressed("Scroll Up"): # SCROLL THE SONG
			time_slider.value += 0.1
		elif Input.is_action_just_pressed("Scroll Down"):
			time_slider.value -= 0.1
	
		_handle_selected_item(GameComponents.get_selected_item_text())

func _display_mouse_time_position(display_on_grid : bool = false) -> void:
	#if get_local_mouse_position().x < 0 or get_local_mouse_position().x > size.x:
		#return
	
	_mouse_time_container.visible = true
	var mouse_time_pos_y
	var result = _get_limited_by_gear_local_mouse_position()
	var mouse_pos : Vector2 = result["position"]
	if display_on_grid:
		mouse_time_pos_y = _get_closest_grid_time_to_mouse()
	else:
		mouse_time_pos_y = NoteHolder.get_time_pos_y(_hit_zone_y - Note.height / 2, - Note.height / 2, mouse_pos.y, Song.get_time(), Song.get_time() + Gear.MAX_TIME_Y())
	var splitted_time := SoundBoard.split_time(mouse_time_pos_y)
	_mouse_time_text.text = "%02d:%02d:%03d" % [splitted_time["minutes"], splitted_time["seconds"], splitted_time["milliseconds"]]
	
	var note_holders_positions := gear.get_note_holders_global_position()
	if note_holders_positions:
		var position_x = note_holders_positions[note_holders_positions.size() - 1].x - global_position.x + _mouse_time_container.size.x
		#var miss_placement_y = -_mouse_time_container.size.y / 8
		var position_y
		if display_on_grid:
			mouse_pos.y = NoteHolder.get_local_pos_y(_hit_zone_y - Note.height / 2, - Note.height / 2, mouse_time_pos_y, Song.get_time(), Song.get_time() + Gear.MAX_TIME_Y())
		position_y = clampf(mouse_pos.y, 0.0, _hit_zone_y)
		_mouse_time_container.position = Vector2(position_x, position_y)

func _handle_selected_item(item_text : String) -> void:
	match item_text:
		"Select":
			_handle_select() # TO REVIEW ...
		"Un/lock":
			pass
		"Tap":
			_handle_selected_item_tap() # TO REVIEW ...
		"Hold":
			_handle_selected_item_hold() # TO REVIEW ...
		"Power":
			_handle_selected_item_power() # TO REVIEW ...
		"Speed":
			_handle_long_note(LongNote.Type.SPEED) # TO REVIEW ...
		"Fade":
			pass
		"Sound":
			pass
		"Note":
			_handle_long_note(LongNote.Type.ANNOTATION) # TO REVIEW ...
		"Section":
			_handle_long_note(LongNote.Type.SECTION) # TO REVIEW ...
		#_:
			#print("epa, NÃO ERA PRA ESTAR ENTRANDO AQUI, FICA ESPERTO")

func _handle_select() -> void:
	if Input.is_action_just_pressed("Delete"):
		if _selected_notes or _selected_long_notes:
			changed.emit()
		
		for note in _selected_notes:
			gear.remove_note_at(note.get_idx(), note, true, true)
		for long_note in _selected_long_notes:
			gear.remove_long_note(long_note, true)
		
		_selected_notes.clear()
		_selected_long_notes.clear()
	
	if Input.is_action_just_pressed("Add Item"):
		_start_mouse_click_position = get_local_mouse_position()
		_last_time_difference_y = 0.0
		var notes := gear.get_global_note_intersected_rects(Rect2(get_global_mouse_position(), Vector2.ZERO))
		_clicked_on_note = notes.size() >= 1 # IF TRUE, MEANS THAT IT CLICKED ON A NOTE
		
		var closest_note : Note = null
		for note in notes:
			if closest_note:
				if note.get_local_mouse_position().distance_squared_to(_start_mouse_click_position) < (
				closest_note.get_local_mouse_position().distance_squared_to(_start_mouse_click_position)):
					closest_note = note
			else:
				closest_note = note
		
		if _clicked_on_note:
			_last_drag_mouse_position = _get_limited_by_gear_local_mouse_position()["position"]
			_clicked_note = closest_note
			_last_grid_time_mouse = _get_closest_grid_time_to_mouse()
			if not closest_note.is_selected():
				_clear_selected_notes()
				_selected_notes.append(closest_note)
				closest_note.set_selected_highlight(true)
		else: # IF DIDN'T CLICKED ON A NOTE, CLEAR SELECTED NOTES
			_clear_selected_notes()
			_clear_selected_long_notes()
			
			## CHECK IF CLICKED IN A LONG NOTE
			var long_note := gear.get_global_long_note_intersected_rects(Rect2(get_global_mouse_position(), Vector2.ZERO))
			if long_note:
				_selected_long_notes.append(long_note)
				long_note.set_selected_highlight(true)
				_last_drag_mouse_position = _get_limited_by_gear_local_mouse_position()["position"]
				_last_grid_time_mouse = _get_closest_grid_time_to_mouse()
				_clicked_long_note = long_note
	elif _clicked_on_note:
		if Input.is_action_pressed("Add Item"):
			_display_mouse_time_position(true)
			#if not _is_mouse_inside_selection_rect():
				#return
				
			var dict := _get_limited_by_gear_local_mouse_position()
			var note_hold_idx = dict["note_hold"]
			
			var leftest_note : Note = null
			for note in _selected_notes:
				if leftest_note:
					if note.get_idx() < leftest_note.get_idx():
						leftest_note = note
				else:
					leftest_note = note
			
			var rightest_note : Note = null
			for note in _selected_notes:
				if rightest_note:
					if note.get_idx() > rightest_note.get_idx():
						rightest_note = note
				else:
					rightest_note = note
			
			if note_hold_idx < 0 or _last_note_holder_idx < 0:
				_last_note_holder_idx = note_hold_idx
			elif note_hold_idx != _last_note_holder_idx:
				var distance = note_hold_idx - _last_note_holder_idx
				if not ((leftest_note.get_idx() + distance < 0) or (leftest_note.get_idx() + distance > gear.get_type() - 1) or (
					rightest_note.get_idx() + distance < 0) or (rightest_note.get_idx() + distance > gear.get_type() - 1)):
					
					_had_time_difference = true
					changed.emit()
					for note in _selected_notes:
						gear.change_note_from_note_holder(note.get_idx(), note.get_idx() + distance, note, true)
					_last_note_holder_idx = note_hold_idx
			
			var mouse_time_difference_y := _get_time_difference_y()
			
			var temp = mouse_time_difference_y
			mouse_time_difference_y -= _last_time_difference_y
			_last_time_difference_y = temp
			
			#var time_difference_y := _get_closest_grid_time_to_mouse() - _clicked_note.get_time()
			var time_difference_y := _get_closest_grid_time_to_mouse() - _last_grid_time_mouse
			_last_grid_time_mouse = _get_closest_grid_time_to_mouse()
			
			if time_difference_y:
				changed.emit()
				_had_time_difference = true
			#print("Time Diff: " + str(time_difference_y))
			
			#if not time_difference_y or (time_difference_y > 0.0 and get_local_mouse_position().y > _hit_zone_y) or (
				#time_difference_y < 0.0 and get_local_mouse_position().y < 0.0):
				#return
			## TODO REWORK THIS...
			
			var lowest_note : Note = null
			for note in _selected_notes:
				if lowest_note:
					if note.get_time() < lowest_note.get_time():
						lowest_note = note
				else:
					lowest_note = note
			
			var highest_note : Note = null
			for note in _selected_notes:
				if highest_note:
					if highest_note is HoldNoteEditor:
						if note is HoldNoteEditor and note.get_time() + note.get_duration() > highest_note.get_time() + highest_note.get_duration():
							highest_note = note
					else: # HIGHEST NOTE IS NOT HOLD NOTE
						if note is HoldNoteEditor and note.get_time() + note.get_duration() > highest_note.get_time():
							highest_note = note
						elif note.get_time() > highest_note.get_time():
							highest_note = note
				else:
					highest_note = note
			
			if lowest_note.get_time() + time_difference_y < 0.0:
				time_difference_y = -lowest_note.get_time()
			#if get_local_mouse_position().y > _hit_zone_y and mouse_time_difference_y < 0: #MOVE DOWN
			if lowest_note.get_time() < Song.get_time() and mouse_time_difference_y < 0: #MOVE DOWN
				var song := Song.new()
				song.set_time(clampf(Song.get_time() + mouse_time_difference_y, 0.0, Song.get_duration()))
			
			var highest_note_time = highest_note.get_time() + highest_note.get_duration() if highest_note is HoldNoteEditor else highest_note.get_time()
			
			if highest_note_time + time_difference_y > _get_highest_grid_time():
				time_difference_y = 0
			highest_note_time = _clicked_note.get_time() + _clicked_note.get_duration() if _clicked_note is HoldNoteEditor else _clicked_note.get_time()
			if highest_note_time + time_difference_y > Song.get_time() + Gear.MAX_TIME_Y():
				var song := Song.new()
				if mouse_time_difference_y > 0:
					song.set_time(clampf(Song.get_time() + mouse_time_difference_y, 0.0, Song.get_duration()))
			if get_local_mouse_position().y < 0 and mouse_time_difference_y > 0: #MOVE UP
				var song := Song.new()
				song.set_time(clampf(Song.get_time() + mouse_time_difference_y, 0.0, Song.get_duration()))
			
			for note in _selected_notes:
				note.set_time(note.get_time() + time_difference_y)
				gear.update_note_time(note, true)
			
		elif Input.is_action_just_released("Add Item"):
			if _had_time_difference:
				_had_time_difference = false
				#changed.emit()
			_last_time_difference_y = 0.0
			_last_note_holder_idx = -1
	elif _clicked_long_note:
		if Input.is_action_pressed("Add Item"):
			var time_difference_y := _get_closest_grid_time_to_mouse() - _last_grid_time_mouse
			_last_grid_time_mouse = _get_closest_grid_time_to_mouse()
			if time_difference_y:
				changed.emit()
				_had_time_difference = true
				_clicked_long_note.set_time(_clicked_long_note.get_time() + time_difference_y)
				gear.update_long_note(_clicked_long_note, true)
		elif Input.is_action_just_released("Add Item"):
			if _had_time_difference:
				_had_time_difference = false
				#changed.emit()
			_clicked_long_note = null
	else:
		if Input.is_action_pressed("Add Item"):
			_mouse_selection.set_rect(Rect2(_start_mouse_click_position, get_local_mouse_position() - _start_mouse_click_position))
		elif Input.is_action_just_released("Add Item") and not _clicked_on_note:
			var rect := Rect2(_start_mouse_click_position, get_local_mouse_position() - _start_mouse_click_position)
			rect.position += global_position
			rect.size = (get_global_mouse_position() - (_start_mouse_click_position + global_position))
			rect = rect.abs()
			_selected_notes = gear.get_global_note_intersected_rects(rect)
			for notes in _selected_notes:
				notes.set_selected_highlight(true)
			_mouse_selection.set_rect(Rect2(0, 0, 0, 0))

func _handle_selected_item_tap() -> void:
	if not get_rect().has_point(get_local_mouse_position()) or _is_any_note_with_display_info():
		sample_tap_note.visible = false
		return
	
	var result = _get_limited_by_gear_local_mouse_position()
	var mouse_pos : Vector2 = result["position"]
	var idx : int = result["note_hold"]
	
	if mouse_pos.x >= 0: # FINDED A NOTE HOLD
		_display_mouse_time_position(true)
		sample_tap_note.visible = true
		sample_tap_note.position = Vector2(mouse_pos.x - NoteHolder.width / 2, mouse_pos.y)
		var time_pos = Song.get_time()
		
		#var mouse_time_pos_y = NoteHolder.get_time_pos_y(_hit_zone_y - Note.height / 2, - Note.height / 2, mouse_pos.y, time_pos, time_pos + Gear.MAX_TIME_Y())
		var mouse_time_pos_y = _get_closest_grid_time_to_mouse()
		
		#if mouse_time_pos_y > soundboard.song.stream.get_length():
			#mouse_time_pos_y = soundboard.song.stream.get_length()
		if mouse_time_pos_y > _get_highest_grid_time():
			mouse_time_pos_y = _get_highest_grid_time()
		
		sample_tap_note.position.y = NoteHolder.get_local_pos_y(_hit_zone_y - Note.height / 2, - Note.height / 2, mouse_time_pos_y, time_pos, time_pos + Gear.MAX_TIME_Y())
		sample_tap_note.set_time(mouse_time_pos_y)
		
		if Input.is_action_just_pressed("Add Item"):
			changed.emit()
			var note := NoteEditor.new(sample_tap_note.get_time())
			note.value_changed.connect((func(): emit_signal("changed")))
			gear.add_note_at(idx, note, true)
	else: # DIDN'T FIND A NOTE HOLD
		sample_tap_note.visible = false

func _handle_selected_item_hold() -> void:
	if not get_rect().has_point(get_local_mouse_position()) or _is_any_note_with_display_info():
		sample_tap_note.visible = false
		#return
	
	var result = _get_limited_by_gear_local_mouse_position()
	var mouse_pos : Vector2 = result["position"]
	var idx : int = result["note_hold"]
	
	if mouse_pos.x >= 0: # FINDED A NOTE HOLD
		_display_mouse_time_position(true)
		sample_tap_note.visible = true
		sample_tap_note.position = Vector2(mouse_pos.x - NoteHolder.width / 2, mouse_pos.y)
		var time_pos = Song.get_time()
		
		#var mouse_time_pos_y = NoteHolder.get_time_pos_y(_hit_zone_y - Note.height / 2, - Note.height / 2, mouse_pos.y, time_pos, time_pos + Gear.MAX_TIME_Y())
		var mouse_time_pos_y = _get_closest_grid_time_to_mouse()
		
		#if mouse_time_pos_y > soundboard.song.stream.get_length():
			#mouse_time_pos_y = soundboard.song.stream.get_length()
		if mouse_time_pos_y > _get_highest_grid_time():
			mouse_time_pos_y = _get_highest_grid_time()
		
		sample_tap_note.position.y = NoteHolder.get_local_pos_y(_hit_zone_y - Note.height / 2, - Note.height / 2, mouse_time_pos_y, time_pos, time_pos + Gear.MAX_TIME_Y())
		
		sample_tap_note.set_time(mouse_time_pos_y)
		
		if Input.is_action_just_pressed("Add Item"):
			sample_tap_note.visible = false
			changed.emit()
			_currently_hold_note = HoldNoteEditor.new(mouse_time_pos_y, mouse_time_pos_y)
			gear.add_note_at(idx, _currently_hold_note, true)
			_last_drag_mouse_position = _get_limited_by_gear_local_mouse_position()["position"]
		elif Input.is_action_pressed("Add Item"):
			sample_tap_note.visible = false
			_currently_hold_note.set_end_time(mouse_time_pos_y)
			gear.update_note_time(_currently_hold_note, true)
			
			var time_difference_y := _get_time_difference_y()
			_last_drag_mouse_position = _get_limited_by_gear_local_mouse_position()["position"]
			
			var temp = time_difference_y
			time_difference_y -= _last_time_difference_y
			_last_time_difference_y = temp
			
			if not _currently_hold_note.visible:
				_currently_hold_note.visible = true #NOTE NOT THE BEST WAY, BUT WORKS FOR NOW
				
			if not time_difference_y or (time_difference_y > 0.0 and get_local_mouse_position().y > _hit_zone_y) or (
				time_difference_y < 0.0 and get_local_mouse_position().y < 0.0):
				return
			if get_local_mouse_position().y < 0.0 or get_local_mouse_position().y > _hit_zone_y:
				var song := Song.new()
				song.set_time(clampf(Song.get_time() + time_difference_y, 0.0, Song.get_duration()))
		elif Input.is_action_just_released("Add Item"):
			_currently_hold_note.pressing_button.connect(_pressing_some_hold_resize_button)
			_currently_hold_note.set_end_time(mouse_time_pos_y)
			_currently_hold_note.update_end_time_text()
			_currently_hold_note.value_changed.connect((func(): emit_signal("changed")))
			_last_time_difference_y = 0.0
	else: # DIDN'T FIND A NOTE HOLD
		sample_tap_note.visible = false

func _handle_selected_item_power() -> void:
	if Input.is_action_just_pressed("Add Item"):
		changed.emit()
		var notes := gear.get_global_note_intersected_rects(Rect2(get_global_mouse_position(), Vector2.ZERO))
		_clicked_on_note = notes.size() >= 1 # IF TRUE, MEANS THAT IT CLICKED ON A NOTE
		if _clicked_on_note:
			var closest_note : Note = null
			for note in notes:
				if closest_note:
					if note.get_local_mouse_position().distance_squared_to(_start_mouse_click_position) < (
					closest_note.get_local_mouse_position().distance_squared_to(_start_mouse_click_position)):
						closest_note = note
				else:
					closest_note = note
			closest_note.powered = !closest_note.powered

func _handle_long_note(type : LongNote.Type) -> void:
	if not get_rect().has_point(get_local_mouse_position()) or _is_any_note_with_display_info():
		_currently_sample_long_note.visible = false
	
	match type:
		LongNote.Type.ANNOTATION:
			_currently_sample_long_note = _sample_long_annotation_note
		LongNote.Type.SECTION:
			_currently_sample_long_note = _sample_long_section_note
		LongNote.Type.SPEED:
			_currently_sample_long_note = _sample_long_speed_note
	
	var result = _get_limited_by_gear_local_mouse_position()
	var mouse_pos : Vector2 = result["position"]
	
	if mouse_pos.x >= 0: # FINDED A NOTE HOLD
		_display_mouse_time_position(true)
		_currently_sample_long_note.visible = true
		_currently_sample_long_note.position = Vector2(mouse_pos.x - NoteHolder.width / 2, mouse_pos.y)
		var time_pos = Song.get_time()
		
		var mouse_time_pos_y = _get_closest_grid_time_to_mouse()
		
		if mouse_time_pos_y > _get_highest_grid_time():
			mouse_time_pos_y = _get_highest_grid_time()
		
		_currently_sample_long_note.position.y = NoteHolder.get_local_pos_y(_hit_zone_y - LongNote.height / 2, - LongNote.height / 2, mouse_time_pos_y, time_pos, time_pos + Gear.MAX_TIME_Y())
		_currently_sample_long_note.position.x = gear.get_note_holders_global_position()[0].x - global_position.x - NoteHolder.width / 2
		_currently_sample_long_note.set_time(mouse_time_pos_y)
		
		if Input.is_action_just_pressed("Add Item"):
			if gear.get_long_notes(_currently_sample_long_note.get_time(), _currently_sample_long_note.get_time()):
				return #TODO SHOW A POPUP DIALOG HERE
			changed.emit()
			var long_note = LongNote.new(_currently_sample_long_note.get_time(), _currently_sample_long_note.get_type())
			gear.add_long_note(long_note)
			long_note.value_changed.connect(func(): emit_signal("changed"))
	else: # DIDN'T FIND A NOTE HOLD
		_currently_sample_long_note.visible = false


func _get_time_difference_y() -> float:
	var mouse_pos : Vector2 = get_local_mouse_position()
	mouse_pos.y -= Note.height / 2
	
	var difference = mouse_pos.y - _last_drag_mouse_position.y
	var is_negative : bool = difference < 0
	if is_negative:
		difference += _hit_zone_y - Note.height / 2
	else:
		difference = _hit_zone_y - Note.height / 2 - difference
	
	var time_difference_y = NoteHolder.get_time_pos_y(_hit_zone_y - Note.height / 2, - Note.height / 2, difference, 0, Gear.MAX_TIME_Y())
	
	return time_difference_y if is_negative else time_difference_y * -1

func _is_mouse_inside_selection_rect() -> bool:
	if not _selected_notes:
		return false
	var full_rect = _selected_notes[0].get_global_rect()
	for note in _selected_notes:
		full_rect = full_rect.merge(note.get_global_rect())
	return full_rect.has_point(get_global_mouse_position())

func _clear_selected_notes() -> void:
	for note in _selected_notes:
		if not is_instance_valid(note):
			continue
		note.set_selected_highlight(false)
	_selected_notes.clear()

func _clear_selected_long_notes() -> void:
	for long_note in _selected_long_notes:
		if not is_instance_valid(long_note):
			continue
		long_note.set_selected_highlight(false)
	_selected_long_notes.clear()

func _get_limited_by_gear_global_mouse_position() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	
	mouse_pos.y = clampf(mouse_pos.y, 
						gear.global_position.y - Gear.get_max_size_y() + NoteHolder.get_hitzone(), 
						gear.global_position.y + NoteHolder.get_hitzone())
	
	var note_holds = gear.get_note_holders_global_position()
	
	if note_holds:
		mouse_pos.x = clampf(mouse_pos.x, 
							note_holds[0].x - NoteHolder.width / 2, 
							note_holds[note_holds.size() - 1].x + NoteHolder.width / 2)
	
	return mouse_pos

func _get_limited_by_gear_local_mouse_position() -> Dictionary:
	var mouse_pos = _get_limited_by_gear_global_mouse_position()
	var note_holds : Array[Vector2] = gear.get_note_holders_global_position()
	
	var closest_x_dist := 1000000000
	var pos_x = -1
	var idx = -1
	
	for i in note_holds.size():
		var dist_dif = abs(get_global_mouse_position().x - note_holds[i].x)
		if dist_dif > NoteHolder.width / 2:
			continue
		if dist_dif < closest_x_dist:
			closest_x_dist = dist_dif
			pos_x = note_holds[i].x - global_position.x
			idx = i
	
	mouse_pos.y -= Note.height / 2 + global_position.y
	mouse_pos.x = pos_x # If -1 here, means that didn't finded a note_holder
	return {
		"position": mouse_pos,
		"note_hold": idx # If -1 here, means that didn't finded a note_holder
	}

func  _is_any_note_with_display_info() -> bool:
	var notes := gear.get_notes_between(Song.get_time(), Song.get_time() + Gear.MAX_TIME_Y())
	for note in notes:
		if note.has_mouse_on_info():
			return true
	return false

func _get_closest_grid_time_to_mouse() -> float:
	var mouse_pos : Vector2 = _get_limited_by_gear_local_mouse_position()["position"]
	var value := EditorMenuBar.get_divisor()
		
	var time_pos := NoteHolder.get_time_pos_y(_hit_zone_y - Note.height / 2, - Note.height / 2, mouse_pos.y, Song.get_time(), Song.get_time() + Gear.MAX_TIME_Y())
	var rest := fmod(time_pos, value)
	if rest <= value / 2.0:
		time_pos -= rest
	else:
		time_pos += value - rest
	return time_pos

func _get_highest_grid_time() -> float:
	return floor(Song.get_duration() / EditorMenuBar.get_divisor()) * EditorMenuBar.get_divisor()

func _draw() -> void:
	var nh_positions := gear.get_note_holders_global_position()
	var left_x := 0.0
	var right_x := 0.0
	
	var snap_divisor_value := EditorMenuBar.get_snap_divisor_value()
	
	if not nh_positions or not snap_divisor_value:
		return
	
	left_x = nh_positions[0].x - global_position.x - NoteHolder.width / 2
	right_x = nh_positions[nh_positions.size() - 1].x - global_position.x + NoteHolder.width / 2
	
	var value := EditorMenuBar.get_divisor()
	var rest := fmod(Song.get_time(), value)
	var start_time_pos := Song.get_time() + value - rest
	var n_grids := int((Gear.MAX_TIME_Y()) / value)
	
	for i in (n_grids + 1):
		var pos_y = NoteHolder.get_local_pos_y(_hit_zone_y - Note.height / 2, - Note.height / 2, start_time_pos + (value * i), Song.get_time(), Song.get_time() + Gear.MAX_TIME_Y())
		pos_y += Note.height / 2
		draw_line(Vector2(left_x, pos_y), Vector2(right_x, pos_y), Color.WHITE, 1)

func _on_mouse_entered() -> void:
	_is_mouse_inside = true

func _on_mouse_exited() -> void:
	_is_mouse_inside = false

func _pressing_some_hold_resize_button(hold_note : HoldNoteEditor, top_button : bool) -> void:
	var diff : float
	if top_button:
		diff = _get_closest_grid_time_to_mouse() - hold_note.get_end_time()
	else:
		diff = _get_closest_grid_time_to_mouse() - hold_note.get_start_time()
		
	if not diff:
		return
	
	changed.emit()
	
	if top_button:
		for note in _selected_notes:
			if not note is HoldNoteEditor:
				continue
			note.set_end_time(clampf(note.get_end_time() + diff, 0.0, _get_highest_grid_time()))
	else:
		for note in _selected_notes:
			if not note is HoldNoteEditor:
				continue
			var end_time = note.get_end_time()
			note.set_start_time(note.get_start_time() + diff)
			note.set_end_time(end_time) ## TODO PQ TEM DEMONIOS TEM UM ERRO VISUAL DE 1 FRAME AQ???? OLHA A PASTA RECORDS TODO BUG NOTE WARNING
	gear.update_note_time(hold_note, true)
