extends HoldManual

class_name HoldBlank

func _init(start_time : float, end_time : float, path_type : Path.Types) -> void:
	set_start_time(start_time)
	set_end_time(end_time)
	set_path_type(path_type)
	_middle_hold.free()
	_end_hold.free()

func set_start_time(start_time : float) -> void:
	_start_time = start_time

func set_end_time(end_time : float) -> void:
	_end_time = end_time
