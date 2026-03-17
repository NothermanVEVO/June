extends Resource

class_name Action

var start_time : float

func _init(start_time : float) -> void:
	self.start_time = start_time

func create_manual_target() -> ManualTarget:
	return null
