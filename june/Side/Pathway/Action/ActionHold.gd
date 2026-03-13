extends Action

class_name ActionHold

var end_time : float

func _init(start_time : float, end_time : float) -> void:
	super._init(start_time)
	self.end_time = end_time

func get_duration() -> float:
	return start_time - end_time
