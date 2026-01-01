extends Node2D

class_name Pathway

enum Direction {LEFT, RIGHT}

var _direction : Direction

static var _distance_from_border : float = 0.0 
const DISTANCE_FROM_BOTTOM : float = 500
const MAX_WIDTH : float = 1920
const MAX_HEIGHT : float = 1080

var _ground_path : Path
var _air_path : Path

static func _set_distance_from_border(distance : float) -> void:
	_distance_from_border = distance

static func get_distance_from_border() -> float:
	return _distance_from_border

func get_ground_path_global_position() -> Vector2:
	return _ground_path.global_position

func get_air_path_global_position() -> Vector2:
	return _air_path.global_position
