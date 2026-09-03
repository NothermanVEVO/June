extends TargetResource

class_name OneTimeDelayResource

@export var first_delay_time : float = 0.0

func _init(start_time : float = 0.0, path_type : int = 0, first_delay_time : float = 0.0) -> void:
	super._init(start_time, path_type)
	self.first_delay_time = first_delay_time
