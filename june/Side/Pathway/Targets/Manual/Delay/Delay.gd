extends ManualTarget

class_name Delay

var _hits : int = 0

var _maximum_hits : int

var _current_time : float

func hit() -> void:
	print("Delay acertado")
	_hits += 1

func is_colliding(time : float) -> bool:
	return (time >= _current_time - get_collision_radius_in_time()
			or time <= _current_time + get_collision_radius_in_time())

func get_current_time() -> float:
	return _current_time

func has_hitted_all() -> bool:
	return _hits >= _maximum_hits
