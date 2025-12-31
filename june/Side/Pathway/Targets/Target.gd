extends NinePatchRect

class_name Target

enum Types {LIGHT, MEDIUM, HEAVY, TWIN, HOLD, HAMMER, SHIELD, BOSS, NOTE, TRAP}

var _start_time : float

var _score : float
var _zone_points : float
var _damage : float

var _path_type : Path.Types ## GROUND or AIR

var _speed : float = -1.0
var is_from_boss : bool

func _init(start_time : float, path_type : Path.Types, is_from_boss : bool) -> void:
	_start_time = start_time
	_path_type = path_type
	self.is_from_boss = is_from_boss

func collide() -> void:
	pass

func hit() -> void:
	pass

func get_start_time() -> float:
	return _start_time

func set_start_time(start_time : float) -> void:
	_start_time = start_time

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
