extends Sprite2D

class_name Target

var _start_time : float

var _score : float
var _zone_points : float
var _damage : float

var _path_type : Path.Types ## GROUND or AIR

var _speed : float = 0.0
var half_reaction : bool = false

var _collision_radius_in_time : float

var target_editor : TargetEditor

func _init(start_time : float, path_type : Path.Types) -> void:
	_start_time = start_time
	_path_type = path_type

func collide() -> void:
	pass

func hit() -> void:
	pass

func _death() -> void:
	pass

func is_colliding(time : float) -> bool:
	return false

func get_size() -> Vector2:
	return Vector2.ZERO

func is_just_pressed() -> bool:
	if _path_type == Path.Types.GROUND:
		if Input.is_action_just_pressed("1_ground") or Input.is_action_just_pressed("2_ground"):
			return true
	else: ## AIR
		if Input.is_action_just_pressed("1_air") or Input.is_action_just_pressed("2_air"):
			return true
	return false

func is_pressed() -> bool:
	if _path_type == Path.Types.GROUND:
		if Input.is_action_pressed("1_ground") or Input.is_action_pressed("2_ground"):
			return true
	else: ## AIR
		if Input.is_action_pressed("1_air") or Input.is_action_pressed("2_air"):
			return true
	return false

func is_just_released() -> bool:
	if _path_type == Path.Types.GROUND:
		if Input.is_action_just_released("1_ground") or Input.is_action_just_released("2_ground"):
			return true
	else: ## AIR
		if Input.is_action_just_released("1_air") or Input.is_action_just_released("2_air"):
			return true
	return false

func get_time() -> float:
	return _start_time

func get_start_time() -> float:
	return _start_time

func set_start_time(start_time : float) -> void:
	_start_time = start_time

func set_path_type(path_type : Path.Types) -> void:
	_path_type = path_type

func get_path_type() -> Path.Types:
	return _path_type

func get_score() -> float:
	return _score

func get_zone_points() -> float:
	return _zone_points

func get_damage() -> float:
	return _damage

func get_speed() -> float:
	return _speed

func set_speed(speed : float) -> void:
	_speed = speed

func get_collision_radius_in_time() -> float:
	return _collision_radius_in_time
