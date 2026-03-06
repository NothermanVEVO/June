extends Node2D

class_name Path

const BASE_HITZONE : float = 400.0
const WIDTH_IN_SECS : float = 4.0 ## The value of the 'width' in seconds.
const HEIGHT : float = 160.0

enum Types {GROUND, MID, AIR}

var _type : Types

static var hitzone : float = BASE_HITZONE ## Distance of the hitzone
static var width : float = Pathway.MAX_WIDTH

var _direction : Pathway.Direction

var _manual_targets : Array[ManualTarget]
var _auto_targets : Array[AutoTarget]

const MAX_TIME_HIT : float = 0.25

var _speed : float = 1.0

var _last_visible_targets : Array[Target] = []

func _init(type : Types, direction : Pathway.Direction) -> void:
	_type = type
	_direction = direction

func get_type() -> Types:
	return _type

func get_rect() -> Rect2:
	return Rect2(position.x, position.y, width, HEIGHT)

func get_global_hitzone_x() -> float:
	return global_position.x - 50 if _direction == Pathway.Direction.LEFT else global_position.x + 50

func _display_targets(time : float) -> void:
	pass

func _is_between(from : float, to : float, value : float) -> bool:
	return value >= from and value <= to

static func reverse_path_type(path_type : Path.Types) -> Path.Types:
	if path_type == Types.GROUND:
		return Types.AIR
	return Types.GROUND

func get_targets(from : float, to : float) -> Array[Target]:
	var targets : Array[Target] = []
	targets.append_array(get_manual_targets(from, to))
	targets.append_array(get_auto_targets(from, to))
	
	return targets

## MANUAL TARGETS

func get_manual_targets(from : float, to : float) -> Array[ManualTarget]:
	var result : Array[ManualTarget] = []
	var low := 0
	var high := _manual_targets.size()
	
	for target in _manual_targets:
		if target is HoldManual and (_is_between(from, to, target.get_start_time()) or
								target.get_start_time() < from and target.get_end_time() >= from):
			result.append(target)
		elif target is Delay and _is_between(from, to, target.get_current_time()):
			result.append(target)
		elif _is_between(from, to, target.get_start_time()):
			result.append(target)
	return result

func add_manual_target(manual_target : ManualTarget) -> void:
	_add_value(_manual_targets, manual_target)

func remove_manual_target(manual_target : ManualTarget, free : bool = false) -> void:
	_remove_value(_manual_targets, manual_target, free)

func update_manual_target(manual_target : ManualTarget) -> void:
	_update_value(_manual_targets, manual_target)

## AUTO TARGETS

func get_auto_targets(from : float, to : float) -> Array[AutoTarget]:
	var result : Array[AutoTarget] = []
	var low := 0
	var high := _auto_targets.size()
	while low < high:
		@warning_ignore("integer_division")
		var mid := (low + high) / 2
		if _auto_targets[mid].get_current_time() < from:
			low = mid + 1
		else:
			high = mid

	var i := low
	while i < _auto_targets.size() and (_auto_targets[i].get_current_time() < to or is_equal_approx(_auto_targets[i].get_current_time(), to)):
		result.append(_auto_targets[i])
		i += 1
	return result

func add_auto_target(auto_target : AutoTarget) -> void:
	_add_value(_auto_targets, auto_target)

func remove_auto_target(auto_target : AutoTarget, free : bool = false) -> void:
	_remove_value(_auto_targets, auto_target, free)

func update_auto_target(auto_target : AutoTarget) -> void:
	_update_value(_auto_targets, auto_target)

## BASE FOR ARRAY TARGETS

func _add_value(array : Array, target : Target) -> void:
	var low := 0
	var high := array.size()

	while low < high:
		@warning_ignore("integer_division")
		var mid := (low + high) / 2
		if target.get_current_time() < array[mid].get_current_time():
			high = mid
		else:
			low = mid + 1

	array.insert(low, target)
	if not target is Blank or not target is HoldBlank:
		add_child.call_deferred(target)
		target.visible = false

func _remove_value(array : Array, target : Target, free : bool = false) -> void:
	array.erase(target)
	if not target is Blank or not target is HoldBlank:
		remove_child.call_deferred(target)
		if free:
			target.queue_free()

#func add_target_at(start_time : float) -> void:
	#pass
#
#func remove_target_at(start_time : float) -> void:
	#pass

func _update_value(array : Array, target : Target) -> void:
	array.erase(target)
	
	var low := 0
	var high := array.size()

	while low < high:
		@warning_ignore("integer_division")
		var mid := (low + high) / 2
		if target.get_time() < array[mid].get_time():
			high = mid
		else:
			low = mid + 1

	array.insert(low, target)

func set_speed(speed : float) -> void:
	_speed = speed
	
	for manual_target in _manual_targets:
		manual_target.set_current_speed(speed)
	
	for auto_target in _auto_targets:
		auto_target.set_current_speed(speed)

func get_speed() -> float:
	return _speed

func WIDTH_IN_SECS_BY_SPEED() -> float:
	return WIDTH_IN_SECS * _speed

static func get_pos_x(min_time : float, max_time : float, current_time : float, min_pos_x : float, max_pos_x : float) -> float:
	var percentage = Global.get_percentage_between(min_time, max_time, current_time)
	var value = min_pos_x + (max_pos_x - min_pos_x) * percentage
	return clampf(value, min_pos_x, max_pos_x)

static func get_time_x(min_pos_x : float, max_pos_x : float, current_pos_x : float, min_time : float, max_time : float) -> float:
	var percentage = Global.get_percentage_between(min_pos_x, max_pos_x, current_pos_x)
	var value = min_time + (max_time - min_time) * percentage
	return clampf(value, min_time, max_time)
