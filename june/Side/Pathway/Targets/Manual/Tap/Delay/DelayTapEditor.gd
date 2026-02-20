extends Tap

class_name DelayTapEditor

var _delay_parent : Delay

func _init(start_time : float, path_type : Path.Types, delay_parent : Delay) -> void:
	super._init(start_time, path_type)
	_delay_parent = delay_parent

func get_delay_parent() -> Delay:
	return _delay_parent
