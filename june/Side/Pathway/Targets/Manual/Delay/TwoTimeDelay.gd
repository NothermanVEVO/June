extends OneTimeDelay

class_name TwoTimeDelay

var _second_time_delay : float

func hit() -> void:
	if _has_hitted_first_delay:
		_current_time = _second_time_delay
