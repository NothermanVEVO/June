extends Delay

class_name OneTimeDelay

var _first_time_delay : float
var _has_hitted_first_delay : bool = false

func _init(start_time : float, first_time_delay : float, path_type : Path.Types) -> void:
	super._init(start_time, path_type)
	set_first_time_delay(first_time_delay)

func hit() -> void:
	super.hit()
	if not _has_hitted_first_delay:
		_current_time = _first_time_delay

func get_first_time_delay() -> float:
	return _first_time_delay

func set_first_time_delay(first_time_delay : float) -> void:
	_first_time_delay = first_time_delay
