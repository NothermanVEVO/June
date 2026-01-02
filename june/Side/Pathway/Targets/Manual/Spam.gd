extends Target

class_name Spam

const NO_SPAM_LIMIT_TIME : float = 1.0

var _end_time : float

var _min_hits : float
var _max_hits : float

var _current_hits : float = 0

func hit() -> void:
	_current_hits += 1
	print("ai")
	if has_hitted_all():
		_death()

func _death() -> void:
	print("morri")

func get_end_time() -> float:
	return _end_time

func set_end_time(end_time : float) -> void:
	_end_time = end_time

func get_duration() -> float:
	return _end_time - _start_time

func get_min_hits() -> float:
	return _min_hits

func get_max_hits() -> float:
	return _min_hits

func get_current_hits() -> float:
	return _current_hits

func has_hitted_min() -> bool:
	return _current_hits >= _min_hits

func has_hitted_all() -> bool:
	return _current_hits >= _max_hits
