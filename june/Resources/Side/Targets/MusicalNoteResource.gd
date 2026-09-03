extends TargetResource

class_name MusicalNoteResource

@export var variant : int

func _init(start_time : float = 0.0, path_type : int = 0, variant : int = 0) -> void:
	super._init(start_time, path_type)
	self.variant = variant
