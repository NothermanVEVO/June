extends Node2D

class_name Path

const BASE_HITZONE : float = 400.0
const WIDTH_IN_SECS : float = 4.0 ## The value of the 'width' in seconds.
const HEIGHT : float = 160.0

enum Types {GROUND, AIR}

var _type : Types

static var hitzone : float = BASE_HITZONE ## Distance of the hitzone
static var width : float = Pathway.MAX_WIDTH

var _direction : Pathway.Direction

var _targets : Array[Target]

const MAX_TIME_HIT : float = 0.25

func _init(type : Types, direction : Pathway.Direction) -> void:
	_type = type
	_direction = direction

func get_type() -> Types:
	return _type

func get_rect() -> Rect2:
	return Rect2(position.x, position.y, width, HEIGHT)

func get_global_hitzone_x() -> float:
	return global_position.x - 50 if _direction == Pathway.Direction.LEFT else global_position.x + 50

func get_targets(from : float, to : float) -> Array[Target]:
	var result : Array[Target] = []
	var low := 0
	var high := _targets.size()

	for target in _targets: ## THIS IS REALLY BAD
		if target is Hold and (target.get_start_time() < from and target.get_end_time() > from):
			result.append(target)
			break

	while low < high:
		@warning_ignore("integer_division")
		var mid := (low + high) / 2
		if _targets[mid].get_time() < from:
			low = mid + 1
		else:
			high = mid

	var i := low
	while i < _targets.size() and (_targets[i].get_time() < to or is_equal_approx(_targets[i].get_time(), to)):
		result.append(_targets[i])
		i += 1

	return result

func add_target(target : Target) -> void:
	var low := 0
	var high := _targets.size()

	while low < high:
		@warning_ignore("integer_division")
		var mid := (low + high) / 2
		if target.get_time() < _targets[mid].get_time():
			high = mid
		else:
			low = mid + 1

	_targets.insert(low, target)
	add_child.call_deferred(target)
	target.visible = false

func remove_target(target : Target, free : bool = false) -> void:
	_targets.erase(target)
	remove_child.call_deferred(target)
	if free:
		target.queue_free()

#func add_target_at(start_time : float) -> void:
	#pass
#
#func remove_target_at(start_time : float) -> void:
	#pass

func update_target(target : Target) -> void:
	_targets.erase(target)
	
	var low := 0
	var high := _targets.size()

	while low < high:
		@warning_ignore("integer_division")
		var mid := (low + high) / 2
		if target.get_time() < _targets[mid].get_time():
			high = mid
		else:
			low = mid + 1

	_targets.insert(low, target)

static func get_pos_x(min_time : float, max_time : float, current_time : float, min_pos_x : float, max_pos_x : float) -> float:
	var percentage = Global.get_percentage_between(min_time, max_time, current_time)
	var value = min_pos_x + (max_pos_x - min_pos_x) * percentage
	return clampf(value, min_pos_x, max_pos_x)

static func get_time_x(min_pos_x : float, max_pos_x : float, current_pos_x : float, min_time : float, max_time : float) -> float:
	var percentage = Global.get_percentage_between(min_pos_x, max_pos_x, current_pos_x)
	var value = min_time + (max_time - min_time) * percentage
	return clampf(value, min_time, max_time)
