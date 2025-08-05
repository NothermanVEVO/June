extends NinePatchRect

class_name Note

static var _speed = 200

static var img = preload("res://assets/noteFormated.png")

static var height = 25

var _current_time : float

func _init(current_time : float) -> void:
	_current_time = current_time
	
	texture = img
	custom_minimum_size = Vector2(NoteHolder.width, height)
	position = Vector2(-custom_minimum_size / 2)
	z_index = 1

func _physics_process(delta: float) -> void:
	global_position.y += _speed * delta

#func _draw() -> void:
	#draw_rect(Rect2(-NoteHolder.width / 2, -12.5, NoteHolder.width, 25), Color.BLUE_VIOLET)
	#draw_circle(Vector2(0, 0), 5 , Color.GREEN)

func set_time(time : float) -> void:
	_current_time = time

func get_time() -> float:
	return _current_time

static func get_speed() -> float:
	return _speed
