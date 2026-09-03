extends TargetResource

class_name ParentTargetResource

var childs : Array[ChildTargetResource] = []

func _init(start_time : float = 0.0, path_type : int = 0, target_type : int = 0, childs : Array[ChildTargetResource] = []) -> void:
	super._init(start_time, path_type, target_type)
	self.childs = childs
