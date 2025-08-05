extends Button

@export_range(4, 6) var keys_quantity : int = 4

var gear : Gear

@onready var time_slider : HSlider = $"../../../SoundBoard/Time Slider"
@onready var focus_effect : ReferenceRect = $"Focus Effect"
@onready var soundboard : SoundBoard = $"../../../SoundBoard"

var sample_tap_note : NoteEditor
var last_item_tap_pos : Vector2 = Vector2(-10000000, -10000000)

func _ready() -> void:
	match keys_quantity:
		4:
			gear = Gear.new(Gear.Type.FOUR_KEYS, false)
		5:
			gear = Gear.new(Gear.Type.FIVE_KEYS, false)
		6:
			gear = Gear.new(Gear.Type.SIX_KEYS, false)
	add_child(gear)
	
	sample_tap_note = NoteEditor.new(0, true)
	add_child(sample_tap_note)
	sample_tap_note.position = last_item_tap_pos
	sample_tap_note.modulate = Color(1, 1, 1, 0.5)

func _process(delta: float) -> void:
	gear.position.x = size.x / 2
	gear.position.y = size.y - NoteHolder.get_hitzone()
	focus_effect.visible = false
	if has_focus():
		focus_effect.visible = true
		if Input.is_action_just_pressed("Scroll Up"): # SCROLL THE SONG
			time_slider.value += 0.1
		elif Input.is_action_just_pressed("Scroll Down"):
			time_slider.value -= 0.1
	
		_handle_selected_item(GameComponents.get_selected_item_text())

func get_time_pos_y(min_pos_y : float, max_pos_y : float, pos_y : float, min_time : float, max_time : float) -> float:
	var percentage = Global.get_percentage_between(min_pos_y, max_pos_y, pos_y)
	var value = min_time + (max_time - min_time) * percentage
	return clampf(value, min_time, max_time)

func get_local_pos_y(min_pos_y : float, max_pos_y : float, time_pos_y : float, min_time : float, max_time : float) -> float:
	var percentage = Global.get_percentage_between(min_time, max_time, time_pos_y)
	var value = min_pos_y + (max_pos_y - min_pos_y) * percentage
	return clampf(value, max_pos_y, min_pos_y)

func _handle_selected_item(item_text : String) -> void:
	match item_text:
		"Select":
			pass
		"Un/lock":
			pass
		"Tap":
			_handle_selected_item_tap() # DOING ...
		"Hold":
			pass
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

func _handle_selected_item_tap() -> void:
	var actual_pos = last_item_tap_pos
	var temp_pos = get_global_mouse_position()# - tap_note_item.size / 2
	var note_holds : Array[Vector2] = Gear.get_note_holders_global_position()
	
	var closest_x_dist := 1000000000
	var pos_x = -1
	var idx = 0
	
	for i in note_holds.size():
		#note_hold -= global_position
		var dist_dif = abs(temp_pos.x - note_holds[i].x)
		if dist_dif > NoteHolder.width / 2:
			continue
		#print(dist_dif)
		if dist_dif < closest_x_dist:
			closest_x_dist = dist_dif
			pos_x = note_holds[i].x - global_position.x
			idx = i
	
	temp_pos.y -= Note.height / 2 + global_position.y
	
	if pos_x >= 0: # FINDED A NOTE HOLD
		temp_pos.y = clampf(temp_pos.y, -Note.height / 2, size.y - Note.height / 2)
		sample_tap_note.position = Vector2(pos_x - NoteHolder.width / 2, temp_pos.y)
		var time_pos = soundboard.get_time_pos()
		sample_tap_note.set_time(get_time_pos_y(size.y - Note.height / 2, - Note.height / 2, temp_pos.y, time_pos, time_pos + NoteHolder.SECS_SIZE_Y))
		last_item_tap_pos = sample_tap_note.position
		
		if Input.is_action_just_pressed("Add Item"):
			gear.add_note_at(idx, NoteEditor.new(time_pos))
		#print(idx + 1) # WHICH NOTE HOLDER IT'S #TODO #TODO #TODO ....
	else: # DIDN'T FIND A NOTE HOLD
		sample_tap_note.position = last_item_tap_pos
