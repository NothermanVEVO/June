extends TargetResource

class_name HoldResource

@export var end_time : float = 0.0

@export var is_blank : bool = false

func _init(start_time : float = 0.0, end_time : float = 0.0, path_type : int = 0) -> void:
	super._init(start_time, path_type)
	self.end_time = end_time
