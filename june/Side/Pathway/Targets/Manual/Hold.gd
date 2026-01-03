extends ManualTarget

class_name Hold

var _end_time : float

var _has_hitted : bool

func hit() -> void:
	print("ai")
	_has_hitted = true

func released() -> void:
	_death()

func _death() -> void:
	print("morri")

func is_colliding(time : float) -> bool:
	return not _has_hitted and (time >= get_start_time() - get_collision_radius_in_time()
			or time <= get_start_time() + get_collision_radius_in_time())

func get_end_time() -> float:
	return _end_time

func set_end_time(end_time : float) -> void:
	_end_time = end_time

func get_duration() -> float:
	return _end_time - _start_time

func has_hitted() -> bool:
	return _has_hitted
