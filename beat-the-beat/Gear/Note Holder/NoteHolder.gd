extends Node2D

class_name NoteHolder

var note_action : String = ""

var _notes : Array[Note]
var _note_idx : int = 0

static var width : float = 0.0
const max_note_distance : float = 100.0

var _pos_x := 0.0
static var _hit_zone_y : float = -50.0 # SET THE POSITION OF THE HITZONE #NOTE

const SECS_SIZE_Y = 10 # SPEED OF THE GAME

var _last_visible_notes : Array[Note] = []

func _init(note_action : String, pos_x : float) -> void:
	self.note_action = note_action
	_pos_x = pos_x

func _ready() -> void:
	position = Vector2(_pos_x, _hit_zone_y)

func _process(delta: float) -> void:
	queue_redraw() #TODO REMOVE THIS LATER, FOR THE SAKE OF GOD

func _physics_process(delta: float) -> void:
	if _notes:
		match Gear.mode:
			Gear.Mode.PLAYER:
				_player_process()
			Gear.Mode.EDITOR:
				_editor_process()
				
	#if _notes: # NOTE REDO
		#if _notes[0].global_position.y > global_position.y + max_note_distance:
			#print("BREAK")
			#_notes[0].state = Note.State.BREAK
			#_notes[0].visible = false
			##_notes[0].queue_free()
			##_notes.remove_at(0)

func _player_process() -> void:
	if Input.is_action_just_pressed(note_action):
		_hit()

func _editor_process() -> void:
	var time : float = Song.get_time()
	
	var notes := get_notes(time, time + SECS_SIZE_Y)
	
	for note in _last_visible_notes:
		if not note in notes:
			note.visible = false
			notes.erase(note)
			
	for note in notes:
		note.visible = true
		note.position.x = -width / 2
		note.position.y = -get_local_pos_y_correct(Note.height / 2, Gear.get_max_size_y() + Note.height / 2, note.get_time(), time, time + SECS_SIZE_Y)# + (Note.height / 2)
		
		if note is HoldNote and note.get_start_time() < time:
			var difference = -get_local_pos_y_correct(0, Gear.get_max_size_y(), note.get_time() + (time - note.get_time()), note.get_time(), note.get_time() + SECS_SIZE_Y)
			note.position.y -= difference
	
	_last_visible_notes = notes

func _hit() -> void: # NOTE REDO
	#if _notes:
		#if abs(_notes[0].global_position.y + (Note.height / 2) - global_position.y) <= max_note_distance:
			#print(_calculate_round_precision(_notes[0]))
			#_notes[0].state = Note.State.HITTED
			#_notes[0].visible = false
			#_notes[0].queue_free()
			#_notes.remove_at(0)
	pass

func _calculate_difference(note : Note) -> float:
	var note_pos = -(note.global_position.y + (Note.height / 2) - global_position.y)
	var result = (note_pos - max_note_distance) / (-max_note_distance) * 100
	return result if result <= 100.0 else (result - 200)

func _calculate_round_precision(note : Note) -> int:
	var difference = _calculate_difference(note)
	var value = sign(difference)  # 1 ou -1
	difference *= value

	if difference > 90.0:
		return 100 * value
	elif difference > 80.0:
		return 90 * value
	elif difference > 70.0:
		return 80 * value
	elif difference > 60.0:
		return 70 * value
	elif difference > 50.0:
		return 60 * value
	elif difference > 40.0:
		return 50 * value
	elif difference > 30.0:
		return 40 * value
	elif difference > 20.0:
		return 30 * value
	elif difference > 10.0:
		return 20 * value
	elif difference > 1.0:
		return 10
	else:
		return 0

#func add_note() -> void:
	#var note = Note.new()
	#note.global_position.y -= get_viewport_rect().size.y
	#_notes.append(note)
	#add_child(note)

func add_note(note : Note) -> void:
	var low := 0
	var high := _notes.size()

	while low < high:
		var mid := (low + high) / 2
		if note.get_time() < _notes[mid].get_time():
			high = mid
		else:
			low = mid + 1

	_notes.insert(low, note)
	add_child(note)
	note.visible = false

func get_notes(from : float, to : float) -> Array[Note]:
	var result : Array[Note] = []
	var low := 0
	var high := _notes.size()

	for note in _notes:
		if note is HoldNote and (note.get_start_time() < from and note.get_end_time() > from):
			result.append(note)
			break

	while low < high:
		var mid := (low + high) / 2
		if _notes[mid].get_time() < from:
			low = mid + 1
		else:
			high = mid

	var i := low
	while i < _notes.size() and _notes[i].get_time() <= to:
		result.append(_notes[i])
		i += 1

	return result

static func get_hitzone() -> float:
	return _hit_zone_y

func _draw() -> void:
	var pos = Vector2.ZERO
	var rect_size_y = Note.height
	var pos_x = pos.x - width / 2
	var pos_y = pos.y - (rect_size_y / 2)
	draw_rect(Rect2(pos_x, pos_y, width, rect_size_y), Color.BLUE)
	draw_line(Vector2(pos_x, pos_y), Vector2(pos_x, pos_y - Gear.get_max_size_y()), Color.WHITE)
	draw_line(Vector2(pos_x + width, pos_y), Vector2(pos_x + width, pos_y - Gear.get_max_size_y()), Color.WHITE)
	draw_circle(pos, 5, Color.YELLOW)
	draw_circle(Vector2(pos.x, pos.y - max_note_distance), 
		5, Color.RED)

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
