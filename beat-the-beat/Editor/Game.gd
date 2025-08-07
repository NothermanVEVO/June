extends Button

@export_range(4, 6) var keys_quantity : int = 4

var gear : Gear

@onready var time_slider : HSlider = $"../../../SoundBoard/Time Slider"
@onready var focus_effect : ReferenceRect = $"Focus Effect"
@onready var soundboard : SoundBoard = $"../../../SoundBoard"

var sample_tap_note : NoteEditor
var last_item_tap_pos : Vector2 = Vector2(-10000000, -10000000)

var _hit_zone_y : float

var _currently_hold_note : HoldNote

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
	
	sample_tap_note = NoteEditor.new(0, true)
	add_child(sample_tap_note)
	sample_tap_note.position = last_item_tap_pos
	sample_tap_note.modulate = Color(1, 1, 1, 0.5)

func _resized() -> void:
	remove_child(gear)
	_hit_zone_y = size.y + NoteHolder.get_hitzone()
	match keys_quantity:
		4:
			gear = Gear.new(Gear.Type.FOUR_KEYS, Gear.Mode.EDITOR, false, _hit_zone_y)
		5:
			gear = Gear.new(Gear.Type.FIVE_KEYS, Gear.Mode.EDITOR, false, _hit_zone_y)
		6:
			gear = Gear.new(Gear.Type.SIX_KEYS, Gear.Mode.EDITOR, false, _hit_zone_y)
	add_child(gear)
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
			pass
		"Un/lock":
			pass
		"Tap":
			_handle_selected_item_tap() # TO REVIEW ...
		"Hold":
			_handle_selected_item_hold() # DOING ...
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
		#_:
			#print("epa, NÃO ERA PRA ESTAR ENTRANDO AQUI, FICA ESPERTO")

func _get_limited_by_gear_global_mouse_position() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	
	mouse_pos.y = clampf(mouse_pos.y, 
						gear.global_position.y - gear.get_max_size_y() + NoteHolder.get_hitzone(), 
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
	var idx = 0
	
	for i in note_holds.size():
		var dist_dif = abs(get_global_mouse_position().x - note_holds[i].x)
		if dist_dif > NoteHolder.width / 2:
			continue
		if dist_dif < closest_x_dist:
			closest_x_dist = dist_dif
			pos_x = note_holds[i].x - global_position.x
			idx = i
	
	mouse_pos.y -= Note.height / 2 + global_position.y
	mouse_pos.x = pos_x
	return {
		"position": mouse_pos,
		"note_hold": idx
	}

func _handle_selected_item_tap() -> void:
	var result = _get_limited_by_gear_local_mouse_position()
	var mouse_pos : Vector2 = result["position"]
	var idx : int = result["note_hold"]
	
	if mouse_pos.x >= 0: # FINDED A NOTE HOLD
		sample_tap_note.position = Vector2(mouse_pos.x - NoteHolder.width / 2, mouse_pos.y)
		var time_pos = Song.get_time()
		
		var mouse_time_pos_y = NoteHolder.get_time_pos_y(_hit_zone_y - Note.height / 2, - Note.height / 2, mouse_pos.y, time_pos, time_pos + NoteHolder.SECS_SIZE_Y)
		if mouse_time_pos_y > soundboard.song.stream.get_length():
			mouse_time_pos_y = soundboard.song.stream.get_length()
			sample_tap_note.position.y = NoteHolder.get_local_pos_y(_hit_zone_y - Note.height / 2, - Note.height / 2, mouse_time_pos_y, time_pos, time_pos + NoteHolder.SECS_SIZE_Y)
		
		sample_tap_note.set_time(mouse_time_pos_y)
		#print(sample_tap_note.get_time())
		#print("SIZE Y: " + str(size.y) + " | GEAR SIZE Y: " + str(Gear.get_max_size_y()))
		#print(NoteHolder.get_local_pos_y(size.y - Note.height / 2, - Note.height / 2, sample_tap_note.get_time(), time_pos, time_pos + NoteHolder.SECS_SIZE_Y))
		last_item_tap_pos = sample_tap_note.position
		
		if Input.is_action_just_pressed("Add Item"):
			gear.add_note_at(idx, NoteEditor.new(sample_tap_note.get_time()))
	else: # DIDN'T FIND A NOTE HOLD
		sample_tap_note.position = last_item_tap_pos

func _handle_selected_item_hold() -> void:
	var result = _get_limited_by_gear_local_mouse_position()
	var mouse_pos : Vector2 = result["position"]
	var idx : int = result["note_hold"]
	
	if mouse_pos.x >= 0: # FINDED A NOTE HOLD
		sample_tap_note.position = Vector2(mouse_pos.x - NoteHolder.width / 2, mouse_pos.y)
		var time_pos = Song.get_time()
		
		var mouse_time_pos_y = NoteHolder.get_time_pos_y(_hit_zone_y - Note.height / 2, - Note.height / 2, mouse_pos.y, time_pos, time_pos + NoteHolder.SECS_SIZE_Y)
		if mouse_time_pos_y > soundboard.song.stream.get_length():
			mouse_time_pos_y = soundboard.song.stream.get_length()
			sample_tap_note.position.y = NoteHolder.get_local_pos_y(_hit_zone_y - Note.height / 2, - Note.height / 2, mouse_time_pos_y, time_pos, time_pos + NoteHolder.SECS_SIZE_Y)
		
		sample_tap_note.set_time(mouse_time_pos_y)
		
		if Input.is_action_just_pressed("Add Item"):
			_currently_hold_note = HoldNote.new(mouse_time_pos_y, mouse_time_pos_y)
			gear.add_note_at(idx, _currently_hold_note)
		elif Input.is_action_pressed("Add Item"):
			_currently_hold_note.set_end_time(mouse_time_pos_y)
		elif Input.is_action_just_released("Add Item"):
			_currently_hold_note.set_end_time(mouse_time_pos_y)
