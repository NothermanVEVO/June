extends TargetResource

class_name SpamResource

@export var end_time : int

func _init(start_time : float = 0.0, end_time : float = 0.0, path_type : int = 0) -> void:
	super._init(start_time, path_type)
	self.end_time = end_time
