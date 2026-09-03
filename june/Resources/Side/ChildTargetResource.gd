extends TargetResource

class_name ChildTargetResource

@export var idx : int = 0

func _init(start_time : float = 0.0, path_type : int = 0, target_type : int = 0, idx : int = 0) -> void:
	super._init(start_time, path_type, target_type)
	self.idx = idx
