extends OneTimeDelayResource

class_name TwoTimesDelayResource

@export var second_delay_time : float = 0.0

func _init(start_time : float = 0.0, path_type : int = 0, first_delay_time : float = 0.0, second_delay_time : float = 0.0) -> void:
	super._init(start_time, path_type, first_delay_time)
	self.second_delay_time = second_delay_time
