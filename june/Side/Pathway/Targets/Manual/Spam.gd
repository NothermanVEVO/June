extends ManualTarget

class_name Spam

const NO_SPAM_LIMIT_TIME : float = 1.0

var _end_time : float

var _min_hits : float
var _max_hits : float

var _current_hits : float = 0

var _blank : Blank

func _init(start_time : float, path_type : Path.Types) -> void:
	_start_time = start_time
	_blank = Blank.new(start_time, path_type)
	set_path_type(path_type)

func hit() -> void:
	_current_hits += 1
	print("ai")
	if has_hitted_all():
		_death()

func _death() -> void:
	print("morri")

#func is_colliding(time : float) -> bool:
	#return _current_hits == 0 and (time >= get_start_time() - get_collision_radius_in_time()
			#or time <= get_start_time() + get_collision_radius_in_time())

func is_just_pressed() -> bool:
	return (Input.is_action_just_pressed("1_ground") or Input.is_action_just_pressed("1_air") or 
		Input.is_action_just_pressed("2_ground") or Input.is_action_just_pressed("2_air"))

func set_start_time(start_time : float) -> void:
	super.set_start_time(start_time)
	_blank.set_start_time(start_time)

func set_path_type(path_type : Path.Types) -> void:
	super.set_path_type(path_type)
	if path_type == Path.Types.GROUND:
		_blank.set_path_type(Path.Types.AIR)
	else: ## AIR
		_blank.set_path_type(Path.Types.GROUND)

func get_blank() -> Blank:
	return _blank

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
