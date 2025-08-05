extends Node2D

class_name NoteHolder

var note_action : String = ""

var _notes : Array[Note]

static var width : float = 0.0
const max_note_distance : float = 100.0

var _pos_x := 0.0
static var _hit_zone_y := 0.0

const SECS_SIZE_Y = 10

static var current_time : float = 0.0 #TODO #TODO #TODO ...

func _init(note_action : String, pos_x : float) -> void:
	self.note_action = note_action
	_pos_x = pos_x

func _ready() -> void:
	_hit_zone_y = get_viewport_rect().size.y - 20 # SET THE POSITION OF THE HITZONE #NOTE
	global_position = Vector2(_pos_x, _hit_zone_y)

func _physics_process(delta: float) -> void:
	if _notes:
		if _notes[0].global_position.y > global_position.y + max_note_distance:
			print("BREAK")
			_notes[0].queue_free()
			_notes.remove_at(0)
	if Input.is_action_just_pressed(note_action):
		_hit()

func _hit() -> void:
	if _notes:
		if abs(_notes[0].global_position.y + (Note.height / 2) - global_position.y) <= max_note_distance:
			print(_calculate_round_precision(_notes[0]))
			_notes[0].queue_free()
			_notes.remove_at(0)

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

func get_notes(from : float, to : float) -> Array[Note]:
	var result: Array[Note] = []
	var low := 0
	var high := _notes.size()

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
	var rect_size_y = 25
	var pos_x = pos.x - width / 2
	var pos_y = pos.y - (rect_size_y / 2)
	draw_rect(Rect2(pos_x, pos_y, width, rect_size_y), Color.BLUE)
	draw_line(Vector2(pos_x, pos_y), Vector2(pos_x, pos_y - 1000), Color.WHITE)
	draw_line(Vector2(pos_x + width, pos_y), Vector2(pos_x + width, pos_y - 1000), Color.WHITE)
	draw_circle(pos, 5, Color.YELLOW)
	draw_circle(Vector2(pos.x, pos.y - max_note_distance), 
		5, Color.RED)
