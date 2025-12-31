extends Target

class_name Hold

var _end_time : float

func get_end_time() -> float:
	return _end_time

func set_end_time(end_time : float) -> void:
	_end_time = end_time

func get_duration() -> float:
	return _end_time - _start_time
