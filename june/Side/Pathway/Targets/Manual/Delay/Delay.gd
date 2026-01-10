extends ManualTarget

class_name Delay

var _hits : int = 0

var _maximum_hits : int

var _current_time : float

func _init(start_time : float, path_type : Path.Types) -> void:
	super._init(start_time, path_type)
	_current_time = start_time

func hit() -> void:
	print("Delay acertado")
	_hits += 1

func is_colliding(time : float) -> bool:
	return (time >= _current_time - get_collision_radius_in_time()
			or time <= _current_time + get_collision_radius_in_time())

func get_time() -> float:
	return _current_time

func has_hitted_all() -> bool:
	return _hits >= _maximum_hits

func set_start_time(start_time : float) -> void:
	super.set_start_time(start_time)
	_current_time = start_time
