extends Delay

class_name OneTimeDelay

var _first_time_delay : float
var _has_hitted_first_delay : bool = false

func hit() -> void:
	super.hit()
	if not _has_hitted_first_delay:
		_current_time = _first_time_delay
