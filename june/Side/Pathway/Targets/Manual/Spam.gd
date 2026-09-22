extends HoldManual

class_name Spam

const NO_SPAM_LIMIT_TIME : float = 1.0

var _min_hits : float
var _max_hits : float

var _current_hits : float = 0

var _hold_blank : HoldBlank

var _hided_editor_visual : bool = false

func _init(start_time : float, end_time : float, path_type : Path.Types) -> void:
	_hold_blank = HoldBlank.new(start_time, end_time, path_type)
	super._init(start_time, end_time, path_type)
	z_index = 1
	texture = SideEditorTexture.HEAVY_TEXTURE
	_end_hold.texture = texture
	_middle_hold.modulate.a = 0.75
	_end_hold.modulate.a = 0.75

func _process(delta: float) -> void:
	if not _hided_editor_visual:
		super._process(delta)
	elif _in_knockback_state:
		_knockback_process(delta)

func hide_editor_visual() -> void:
	_end_hold.visible = false
	_middle_hold.visible = false
	
	_hided_editor_visual = true
	set_process(true)

func hit() -> void:
	_current_hits += 1
	_has_hitted = true
	#if has_hitted_all():
		#_death()

func _death() -> void:
	_is_dead = true
	throw_back()

#func is_colliding(time : float) -> bool:
	#return _current_hits == 0 and (time >= get_start_time() - get_collision_radius_in_time()
			#or time <= get_start_time() + get_collision_radius_in_time())

func is_just_pressed() -> bool:
	return (Input.is_action_just_pressed("1_ground") or Input.is_action_just_pressed("1_air") or 
		Input.is_action_just_pressed("2_ground") or Input.is_action_just_pressed("2_air"))

func set_start_time(start_time : float) -> void:
	super.set_start_time(start_time)
	_hold_blank.set_start_time(start_time)

func set_path_type(path_type : Path.Types) -> void:
	super.set_path_type(path_type)
	if path_type == Path.Types.GROUND:
		position.y = -Path.HEIGHT
		_hold_blank.set_path_type(Path.Types.AIR)
	else: ## AIR
		position.y = Path.HEIGHT
		_hold_blank.set_path_type(Path.Types.GROUND)

func get_time() -> float:
	if _has_hitted:
		return Song.get_time()
	return _start_time

func set_end_time(end_time : float) -> void:
	super.set_end_time(end_time)
	_hold_blank.set_end_time(end_time)

func get_hold_blank() -> HoldBlank:
	return _hold_blank

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
