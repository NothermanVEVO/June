extends HoldManual

class_name HoldBlank

func _init(start_time : float, end_time : float, path_type : Path.Types) -> void:
	set_start_time(start_time)
	set_end_time(end_time)
	set_path_type(path_type)

func set_start_time(start_time : float) -> void:
	hold._start_time = start_time

func set_end_time(end_time : float) -> void:
	hold._end_time = end_time
