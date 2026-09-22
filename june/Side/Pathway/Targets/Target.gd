extends Sprite2D

class_name Target

var _start_time : float

var _score : float
var _zone_points : float
var _damage : float

var _path_type : Path.Types ## GROUND or AIR

var _base_speed : float = 0.0 ## 0 means that has the same speed of the pathway
var _current_speed : float = 1.0
var half_reaction : bool = false

var _is_dead : bool = false

var _collision_radius_in_time : float

const _KNOCKBACK_OPACITY_SPEED := 1.0 
var _knockback_velocity := Vector2.ZERO
var _rotation_velocity := 0.0
var _in_knockback_state : bool = false

var target_editor : TargetEditor

func _init(start_time : float, path_type : Path.Types) -> void:
	set_start_time(start_time)
	set_path_type(path_type)

func collide(character : Character) -> void:
	character.take_damage(_damage)
	print("dei dano no player hehe")

func hit() -> void:
	pass

func _death() -> void:
	_is_dead = true

func is_colliding(time : float) -> bool:
	return false

func get_global_rect() -> Rect2:
	return Rect2(global_position.x, global_position.y, 0, 0)

func _knockback_process(delta : float) -> void:
	## Gravidade
	_knockback_velocity.y += 980.0 * 2 * delta

	## Movimento
	position += _knockback_velocity * delta

	# Rotação
	rotation += _rotation_velocity * delta
	
	modulate.a -= _KNOCKBACK_OPACITY_SPEED * delta
	
	if modulate.a <= 0:
		_in_knockback_state = false

func throw_back(direction: float = -1.0) -> void:
	_in_knockback_state = true

	_knockback_velocity.x = randf_range(800.0, 1200.0) * direction
	_knockback_velocity.y = -1500 
	
	_rotation_velocity = randf_range(5.0, 10.0) * [1, -1].pick_random()

func create_target_editor() -> void:
	if not target_editor:
		target_editor = TargetEditor.new(self)
		add_child(target_editor)

func is_just_pressed() -> bool:
	if _path_type == Path.Types.GROUND:
		return Input.is_action_just_pressed("1_ground") or Input.is_action_just_pressed("2_ground")
	else: ## AIR
		return Input.is_action_just_pressed("1_air") or Input.is_action_just_pressed("2_air")

func is_pressed() -> bool:
	if _path_type == Path.Types.GROUND:
		return Input.is_action_pressed("1_ground") or Input.is_action_pressed("2_ground")
	else: ## AIR
		return Input.is_action_pressed("1_air") or Input.is_action_pressed("2_air")

func is_just_released() -> bool:
	if _path_type == Path.Types.GROUND:
		return Input.is_action_just_released("1_ground") or Input.is_action_just_released("2_ground")
	else: ## AIR
		return Input.is_action_just_released("1_air") or Input.is_action_just_released("2_air")

func get_current_time() -> float:
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

func get_base_speed() -> float:
	return _base_speed

func set_base_speed(base_speed : float) -> void:
	_base_speed = base_speed
	if not is_equal_approx(_base_speed, 0):
		set_current_speed(base_speed)

func get_current_speed() -> float:
	return _current_speed

func is_dead() -> bool:
	return _is_dead

func get_width_in_secs_by_speed() -> float:
	return Path.WIDTH_IN_SECS * _current_speed

func set_current_speed(current_speed : float) -> void:
	if _base_speed == 0.0:
		_current_speed = current_speed
	else:
		_current_speed = _base_speed

func get_collision_radius_in_time() -> float:
	return _collision_radius_in_time

func is_in_knockback_state() -> bool:
	return _in_knockback_state
