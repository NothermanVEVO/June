extends Button

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
var _mouse_selection : Selection = Selection.new()
var _selected_notes : Array[Note] = []
var _last_drag_mouse_position : Vector2
var _last_time_difference_y : float = 0.0
var _last_note_holder_idx : int = -1

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
	
	add_child(_mouse_selection)

func _resized() -> void:
	_hit_zone_y = size.y + NoteHolder.get_hitzone()
	gear.set_max_size_y(_hit_zone_y)
	gear.position.x = size.x / 2
	gear.position.y = size.y# - NoteHolder.get_hitzone()

func _process(delta: float) -> void:
	focus_effect.visible = false
	if has_focus():
		focus_effect.visible = true
		if Input.is_action_just_pressed("Scroll Up"): # SCROLL THE SONG
			time_slider.value += 0.1
		elif Input.is_action_just_pressed("Scroll Down"):
			time_slider.value -= 0.1
	
		_handle_selected_item(GameComponents.get_selected_item_text())

func _handle_selected_item(item_text : String) -> void:
	match item_text:
		"Select":
			_handle_select() # DOING ...
		"Un/lock":
			pass
		"Tap":
			_handle_selected_item_tap() # TO REVIEW ...
		"Hold":
			_handle_selected_item_hold() # TO REVIEW ...
		"Power":
			pass
		"Speed":
			pass
		"Fade":
			pass
		"Sound":
			pass
		"Note":
			pass
		"Section":
			pass
		#_:
			#print("epa, NÃO ERA PRA ESTAR ENTRANDO AQUI, FICA ESPERTO")

func _handle_select() -> void:
	if Input.is_action_just_pressed("Delete"):
		for note in _selected_notes:
			Gear.remove_note_at(note.get_idx(), note, true, true)
	
	if Input.is_action_just_pressed("Add Item"):
		_start_mouse_click_position = get_local_mouse_position()
		var notes := Gear.get_global_intersected_rects(Rect2(get_global_mouse_position(), Vector2.ZERO))
		_clicked_on_note = notes.size() >= 1 # IF TRUE, MEANS THAT IT CLICKED ON A NOTE
		
		var closest_note : Note
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
			if not closest_note.is_selected():
				_clear_selected_notes()
				_selected_notes.append(closest_note)
				closest_note.set_selected_highlight(true)
		else: # IF DIDN'T CLICKED ON A NOTE, JUST CLEAR SELECTED NOTES
			_clear_selected_notes()
	elif _clicked_on_note:
		if Input.is_action_pressed("Add Item"):
			#if not _is_mouse_inside_selection_rect():
				#return
				
			var dict := _get_limited_by_gear_local_mouse_position()
			var note_hold_idx = dict["note_hold"]
			
			var leftest_note : Note
			for note in _selected_notes:
				if leftest_note:
					if note.get_idx() < leftest_note.get_idx():
						leftest_note = note
				else:
					leftest_note = note
			
			var rightest_note : Note
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
				if not ((leftest_note.get_idx() + distance < 0) or (leftest_note.get_idx() + distance > Gear.get_type() - 1) or (
					rightest_note.get_idx() + distance < 0) or (rightest_note.get_idx() + distance > Gear.get_type() - 1)):
					for note in _selected_notes:
						Gear.change_note_from_note_holder(note.get_idx(), note.get_idx() + distance, note, true)
					_last_note_holder_idx = note_hold_idx
			
			var time_difference_y := _get_time_difference_y()
			
			var temp = time_difference_y
			time_difference_y -= _last_time_difference_y
			_last_time_difference_y = temp
			
			#print("Time Diff: " + str(time_difference_y))
			
			if not time_difference_y or (time_difference_y > 0.0 and get_local_mouse_position().y > _hit_zone_y) or (
				time_difference_y < 0.0 and get_local_mouse_position().y < 0.0):
				return
			
			var lowest_note : Note
			for note in _selected_notes:
				if lowest_note:
					if note.get_time() < lowest_note.get_time():
						lowest_note = note
				else:
					lowest_note = note
			
			#if not lowest_note.visible:
				#print(lowest_note.get_time())
				#print(Song.get_time())
				#print("Omg")
			
			var highest_note : Note
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
			
			#if not highest_note.visible:
				#print(highest_note.get_time())
				#print(Song.get_time())
				#print("Omg")
			
			var changed_clicked_note := false
			
			if lowest_note.get_time() + time_difference_y < 0.0:
				time_difference_y = -lowest_note.get_time()
			if _clicked_note.get_time() + time_difference_y < Song.get_time():
				changed_clicked_note = true
				_clicked_note.set_time(_clicked_note.get_time() + time_difference_y)
				var song := Song.new()
				if _clicked_note.get_time() < Song.get_time():
					song.set_time(_clicked_note.get_time())
				Gear.update_note_time(_clicked_note, true)
			
			var highest_note_time = highest_note.get_time() + highest_note.get_duration() if highest_note is HoldNoteEditor else highest_note.get_time()
			
			if highest_note_time + time_difference_y > Song.get_duration():
				time_difference_y = Song.get_duration() - highest_note_time
			highest_note_time = _clicked_note.get_time() + _clicked_note.get_duration() if _clicked_note is HoldNoteEditor else _clicked_note.get_time()
			if highest_note_time + time_difference_y > Song.get_time() + Gear.MAX_TIME_Y():
				changed_clicked_note = true
				_clicked_note.set_time(_clicked_note.get_time() + time_difference_y)
				var song := Song.new()
				song.set_time(highest_note_time + time_difference_y - Gear.MAX_TIME_Y())
				Gear.update_note_time(_clicked_note, true)
			
			for note in _selected_notes:
				if note == _clicked_note and changed_clicked_note:
					continue
				note.set_time(note.get_time() + time_difference_y)
				Gear.update_note_time(note, true)
			
		elif Input.is_action_just_released("Add Item"):
			_last_time_difference_y = 0.0
			_last_note_holder_idx = -1
	else:
		if Input.is_action_pressed("Add Item"):
			_mouse_selection.set_rect(Rect2(_start_mouse_click_position, get_local_mouse_position() - _start_mouse_click_position))
		elif Input.is_action_just_released("Add Item") and not _clicked_on_note:
			var rect := Rect2(_start_mouse_click_position, get_local_mouse_position() - _start_mouse_click_position)
			rect.position += global_position
			rect.size = (get_global_mouse_position() - (_start_mouse_click_position + global_position))
			rect = rect.abs()
			_selected_notes = Gear.get_global_intersected_rects(rect)
			for notes in _selected_notes:
				notes.set_selected_highlight(true)
			_mouse_selection.set_rect(Rect2(0, 0, 0, 0))

func _get_time_difference_y() -> float:
	var mouse_pos : Vector2 = get_local_mouse_position()
	mouse_pos.y -= Note.height / 2
	
	
	#print("Mouse Pos Y: " + str(mouse_pos.y))
	#print("Last Drag Mouse Position Y: " + str(_last_drag_mouse_position.y))
	
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
	var full_rect := _selected_notes[0].get_global_rect()
	for note in _selected_notes:
		full_rect = full_rect.merge(note.get_global_rect())
	return full_rect.has_point(get_global_mouse_position())

func _clear_selected_notes() -> void:
	for note in _selected_notes:
		if not is_instance_valid(note):
			continue
		note.set_selected_highlight(false)
	_selected_notes.clear()

func _get_limited_by_gear_global_mouse_position() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	
	mouse_pos.y = clampf(mouse_pos.y, 
						gear.global_position.y - Gear.get_max_size_y() + NoteHolder.get_hitzone(), 
						gear.global_position.y + NoteHolder.get_hitzone())
	
	var note_holds = Gear.get_note_holders_global_position()
	
	if note_holds:
		mouse_pos.x = clampf(mouse_pos.x, 
							note_holds[0].x - NoteHolder.width / 2, 
							note_holds[note_holds.size() - 1].x + NoteHolder.width / 2)
	
	return mouse_pos

func _get_limited_by_gear_local_mouse_position() -> Dictionary:
	var mouse_pos = _get_limited_by_gear_global_mouse_position()
	var note_holds : Array[Vector2] = Gear.get_note_holders_global_position()
	
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

func _handle_selected_item_tap() -> void:
	if not get_rect().has_point(get_local_mouse_position()) or _is_any_note_with_display_info():
		sample_tap_note.visible = false
		return
	
	var result = _get_limited_by_gear_local_mouse_position()
	var mouse_pos : Vector2 = result["position"]
	var idx : int = result["note_hold"]
	
	if mouse_pos.x >= 0: # FINDED A NOTE HOLD
		sample_tap_note.visible = true
		sample_tap_note.position = Vector2(mouse_pos.x - NoteHolder.width / 2, mouse_pos.y)
		var time_pos = Song.get_time()
		
		var mouse_time_pos_y = NoteHolder.get_time_pos_y(_hit_zone_y - Note.height / 2, - Note.height / 2, mouse_pos.y, time_pos, time_pos + Gear.MAX_TIME_Y())
		if mouse_time_pos_y > soundboard.song.stream.get_length():
			mouse_time_pos_y = soundboard.song.stream.get_length()
			sample_tap_note.position.y = NoteHolder.get_local_pos_y(_hit_zone_y - Note.height / 2, - Note.height / 2, mouse_time_pos_y, time_pos, time_pos + Gear.MAX_TIME_Y())
		
		sample_tap_note.set_time(mouse_time_pos_y)
		
		if Input.is_action_just_pressed("Add Item"):
			gear.add_note_at(idx, NoteEditor.new(sample_tap_note.get_time(), global_position.y), true)
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
		sample_tap_note.visible = true
		sample_tap_note.position = Vector2(mouse_pos.x - NoteHolder.width / 2, mouse_pos.y)
		var time_pos = Song.get_time()
		
		var mouse_time_pos_y = NoteHolder.get_time_pos_y(_hit_zone_y - Note.height / 2, - Note.height / 2, mouse_pos.y, time_pos, time_pos + Gear.MAX_TIME_Y())
		if mouse_time_pos_y > soundboard.song.stream.get_length():
			mouse_time_pos_y = soundboard.song.stream.get_length()
			sample_tap_note.position.y = NoteHolder.get_local_pos_y(_hit_zone_y - Note.height / 2, - Note.height / 2, mouse_time_pos_y, time_pos, time_pos + Gear.MAX_TIME_Y())
		
		sample_tap_note.set_time(mouse_time_pos_y)
		
		if Input.is_action_just_pressed("Add Item"):
			sample_tap_note.visible = false
			_currently_hold_note = HoldNoteEditor.new(mouse_time_pos_y, mouse_time_pos_y, global_position.y)
			gear.add_note_at(idx, _currently_hold_note, true)
			_last_drag_mouse_position = _get_limited_by_gear_local_mouse_position()["position"]
		elif Input.is_action_pressed("Add Item"):
			sample_tap_note.visible = false
			_currently_hold_note.set_end_time(mouse_time_pos_y)
			Gear.update_note_time(_currently_hold_note, true)
			
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
			_currently_hold_note.set_end_time(mouse_time_pos_y)
			_currently_hold_note.update_end_time_text()
			_last_time_difference_y = 0.0
	else: # DIDN'T FIND A NOTE HOLD
		sample_tap_note.visible = false

func  _is_any_note_with_display_info() -> bool:
	var notes := Gear.get_notes_between(Song.get_time(), Song.get_time() + Gear.MAX_TIME_Y())
	for note in notes:
		if note.has_mouse_on_info():
			return true
	return false

func _on_mouse_entered() -> void:
	_is_mouse_inside = true

func _on_mouse_exited() -> void:
	_is_mouse_inside = false
