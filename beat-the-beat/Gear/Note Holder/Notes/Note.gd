extends NinePatchRect

class_name Note

enum State{TO_HIT, HITTED, BREAK}

const NORMAL_NOTE_IMG = preload("res://assets/noteFormated.png")

static var height : int = 25

var _current_time : float

var state : State = State.TO_HIT

func _init(current_time : float) -> void:
	_current_time = current_time
	
	texture = NORMAL_NOTE_IMG
	size = Vector2(NoteHolder.width, height)
	position = Vector2(-size / 2)
	z_index = 1

#func _draw() -> void:
	#draw_rect(Rect2(-NoteHolder.width / 2, -12.5, NoteHolder.width, 25), Color.BLUE_VIOLET)
	#draw_circle(Vector2(0, 0), 5 , Color.GREEN)

func set_time(time : float) -> void:
	_current_time = time

func get_time() -> float:
	return _current_time
