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

var _actions : Array[Action] ## TODO

var _speed : float = 1.0

signal changed_speed(speed : float)

func add_target_at(path_type : Path.Types, target : Target, validate_note : bool = false) -> void:
	target.set_path_type(path_type)
	
	target.set_current_speed(_speed)
	
	if path_type == Path.Types.GROUND:
		if target is ManualTarget:
			_ground_path.add_manual_target(target)
		else: ## AUTO TARGET
			_ground_path.add_auto_target(target)
	else: ## AIR
		if target is ManualTarget:
			_air_path.add_manual_target(target)
		else: ## AUTO TARGET
			_air_path.add_auto_target(target)
	
	if target is Spam:
		add_target_at(target.get_hold_blank().get_path_type(), target.get_hold_blank(), validate_note)
	if target is TwinTap and target.is_older():
		add_target_at(target.get_twin().get_path_type(), target.get_twin(), validate_note)

func remove_target_at(path_type : Path.Types, target : Target, validate_note : bool = false, free : bool = false) -> void:
	if path_type == Path.Types.GROUND:
		if target is ManualTarget:
			_ground_path.remove_manual_target(target, free)
		else: ## AUTO TARGET
			_ground_path.remove_auto_target(target, free)
	else: ## AIR
		if target is ManualTarget:
			_air_path.remove_manual_target(target, free)
		else: ## AUTO TARGET
			_air_path.remove_auto_target(target, free)
	
	if target is Spam:
		remove_target_at(target.get_hold_blank().get_path_type(), target.get_hold_blank(), validate_note)
	if target is TwinTap and target.is_older():
		remove_target_at(target.get_twin().get_path_type(), target.get_twin(), validate_note)

func add_full_real_clone(real_clone : RealClone, validate_note : bool = false) -> void:
	for fake_clone in real_clone.fake_clones:
		add_target_at(fake_clone.get_path_type(), fake_clone, validate_note)

func remove_full_real_clone(real_clone : RealClone, validate_note : bool = false, free : bool = false) -> void:
	for fake_clone in real_clone.fake_clones:
		remove_target_at(fake_clone.get_path_type(), fake_clone, validate_note)
	remove_target_at(real_clone.get_path_type(), real_clone, validate_note, free)

func update_target(target : Target, validate_note : bool = false) -> void:
	if target.get_path_type() == Path.Types.GROUND:
		if target is ManualTarget:
			_ground_path.update_manual_target(target)
		else: ## AUTO TARGET
			_ground_path.update_auto_target(target)
	else: ## AIR
		if target is ManualTarget:
			_air_path.update_manual_target(target)
		else: ## AUTO TARGET
			_air_path.update_auto_target(target)

func change_target_path(to_path_type : Path.Types, target : Target, validate_note : bool = false) -> void:
	remove_target_at(target.get_path_type(), target, validate_note)
	add_target_at(to_path_type, target, validate_note)

#func remove_target_at_time(time : float, end_time : float, idx : int, type : NoteResource.Type, validate_note : bool = false, free : bool = false) -> void:
	#_note_holders[idx].remove_note_at_time(time, end_time, type, validate_note, free) ## TODO

func get_global_targets_intersected_with(rect : Rect2, from : float, to : float) -> Array[Target]:
	var intersected_targets : Array[Target] = []
	
	var targets : Array[Target] = []
	targets.append_array(_ground_path.get_targets(from, to))
	targets.append_array(_air_path.get_targets(from, to))
	
	for target in targets:
		if target is Blank or target is HoldBlank or not target.get_global_rect().intersects(rect, true):
			continue
		intersected_targets.append(target)
	
	return intersected_targets

func add_action(action : Action) -> void:
	var low := 0
	var high := _actions.size()

	while low < high:
		@warning_ignore("integer_division")
		var mid := (low + high) / 2
		if action.get_current_time() < _actions[mid].get_current_time():
			high = mid
		else:
			low = mid + 1

	_actions.insert(low, action)

func remove_action(action : Action) -> void:
	_actions.erase(action)

#func add_action_at(start_time : float) -> void:
	#pass
#
#func remove_action_at(start_time : float) -> void:
	#pass

func update_action(action : Action) -> void:
	_actions.erase(action)
	
	var low := 0
	var high := _actions.size()

	while low < high:
		@warning_ignore("integer_division")
		var mid := (low + high) / 2
		if action.get_time() < _actions[mid].get_time():
			high = mid
		else:
			low = mid + 1

	_actions.insert(low, action)

static func _set_distance_from_border(distance : float) -> void:
	_distance_from_border = distance

static func get_distance_from_border() -> float:
	return _distance_from_border

func get_ground_path_global_position() -> Vector2:
	return _ground_path.global_position

func get_air_path_global_position() -> Vector2:
	return _air_path.global_position

func get_speed() -> float:
	return _speed

func set_speed(speed : float) -> void:
	_speed = speed
	_ground_path.set_speed(speed)
	_air_path.set_speed(speed)
	changed_speed.emit(speed)

func WIDTH_IN_SECS_BY_SPEED() -> float:
	return Path.WIDTH_IN_SECS * _speed
