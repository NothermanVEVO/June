extends OneTimeDelay

class_name TwoTimesDelay

var _second_time_delay : float

func hit() -> void:
	if _has_hitted_first_delay:
		_current_time = _second_time_delay

func get_second_time_delay() -> float:
	return _second_time_delay

func set_second_time_delay(second_time_delay : float) -> void:
	_second_time_delay = second_time_delay
