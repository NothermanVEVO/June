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

var _manual_targets : Array[ManualTarget]
var _auto_targets : Array[AutoTarget]

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

func _display_targets() -> void:
	pass

## MANUAL TARGETS

func get_manual_targets(from : float, to : float) -> Array[ManualTarget]: ##TODO
	return _get_values(_manual_targets, from, to)

func add_manual_targets(manual_target : ManualTarget) -> void:
	_add_value(_manual_targets, manual_target)

func remove_manual_target(manual_target : ManualTarget, free : bool = false) -> void:
	_remove_value(_manual_targets, manual_target, free)

func update_manual_target(manual_target : ManualTarget) -> void:
	_update_value(_manual_targets, manual_target)

## AUTO TARGETS

func get_auto_targets(from : float, to : float) -> Array[AutoTarget]: ##TODO
	return _get_values(_auto_targets, from, to)

func add_auto_targets(auto_target : AutoTarget) -> void:
	_add_value(_auto_targets, auto_target)

func remove_auto_target(auto_target : AutoTarget, free : bool = false) -> void:
	_remove_value(_auto_targets, auto_target, free)

func update_auto_target(auto_target : AutoTarget) -> void:
	_update_value(_auto_targets, auto_target)

## BASE FOR ARRAY TARGETS

func _get_values(array : Array, from : float, to : float) -> Array:
	var result : Array = []
	var low := 0
	var high := array.size()
	
	for target in array:
		if target is Hold:
			pass
		elif target is Spam:
			pass
		elif target is Delay:
			pass
		else:
			pass
	
	#for target in array: ## THIS IS REALLY BAD
		#if target is Hold and (target.get_start_time() < from and target.get_end_time() > from):
			#result.append(target)
			#break
#
	#while low < high:
		#@warning_ignore("integer_division")
		#var mid := (low + high) / 2
		#if array[mid].get_time() < from:
			#low = mid + 1
		#else:
			#high = mid
#
	#var i := low
	#while i < array.size() and (array[i].get_time() < to or is_equal_approx(array[i].get_time(), to)):
		#result.append(array[i])
		#i += 1

	return result

func _add_value(array : Array, target : Target) -> void:
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
	add_child.call_deferred(target)
	target.visible = false

func _remove_value(array : Array, target : Target, free : bool = false) -> void:
	array.erase(target)
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

static func get_pos_x(min_time : float, max_time : float, current_time : float, min_pos_x : float, max_pos_x : float) -> float:
	var percentage = Global.get_percentage_between(min_time, max_time, current_time)
	var value = min_pos_x + (max_pos_x - min_pos_x) * percentage
	return clampf(value, min_pos_x, max_pos_x)

static func get_time_x(min_pos_x : float, max_pos_x : float, current_pos_x : float, min_time : float, max_time : float) -> float:
	var percentage = Global.get_percentage_between(min_pos_x, max_pos_x, current_pos_x)
	var value = min_time + (max_time - min_time) * percentage
	return clampf(value, min_time, max_time)
