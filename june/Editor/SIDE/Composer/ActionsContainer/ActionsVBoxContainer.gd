extends VBoxContainer

class_name ActionsVBoxContainer

var _pathway_editor : PathwayEditor
var _highest_grid_time : float

var _sample_action := Sprite2D.new()
var _current_hold_action : ManualTargetActionHold

var _closest_action_path_container : ActionPathContainer = null

var _actions_paths_containers : Array[ActionPathContainer]

var _is_pressing_left_edit_hold_button : bool = false
var _is_pressing_right_edit_hold_button : bool = false

@onready var _actions_item_list : ItemList = $"../ActionListMarginContainer/ActionsItemList"

func setup(pathway_editor : PathwayEditor, highest_grid_time : float, actions_paths_containers : Array[ActionPathContainer]) -> void:
	_pathway_editor = pathway_editor
	
	if _pathway_editor:
		_pathway_editor.changed_speed.connect(_changed_speed)
	
	_highest_grid_time = highest_grid_time
	_actions_paths_containers = actions_paths_containers

func _ready() -> void:
	_sample_action.global_position = Vector2(INF, INF)
	_sample_action.modulate.a = 0.5
	_sample_action.scale *= 1.5
	
	add_child(_sample_action)

func _changed_speed(speed : float) -> void:
	for action_path_container in _actions_paths_containers:
		action_path_container.get_path_editor().set_speed(speed)

func _process(delta: float) -> void:
	queue_redraw()
	
	_closest_action_path_container = _get_closest_action_path_container()
	
	var selected_items := _actions_item_list.get_selected_items()
	
	if not selected_items.is_empty() and not _actions_paths_containers.is_empty():
		_handle_selected_item(_actions_item_list.get_item_text(selected_items[0]))

func _handle_selected_item(item_text : String) -> void:
	if not _is_mouse_inside():
		_sample_action.texture = null
	
	match item_text:
		"Selecionar":
			_process_select()
		"Comentário": ## TAP
			_process_comment()
		"Seção": ## TAP
			_process_section()
		"Fade": ## HOLD
			_process_fade()
		"Velocidade": ## TAP
			_process_speed()
		"Chefão": ## HOLD
			_process_boss()
		"Dialogo": ## HOLD
			_process_dialog()
		"Cinemática": ## HOLD
			_process_cinematic()
		"Trocar cenário": ## TAP
			_process_change_scenario()
		"Trocar inimigos": ## TAP
			_process_change_enemy()
		"Tremor": ## TAP
			_process_shake()
		"Câmera": ## HOLD
			_process_camera()
		"Vinheta": ## HOLD
			_process_vignette()

func _process_select() -> void:
	pass

func _process_comment() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.COMMENT_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item") and _closest_action_path_container:
		var comment_action := ActionComment.new(_get_closest_grid_time_to_mouse())
		_closest_action_path_container.get_path_editor().add_manual_target(comment_action.create_manual_target())

func _process_section() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.SECTION_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item") and _closest_action_path_container:
		var section_action := ActionSection.new(_get_closest_grid_time_to_mouse())
		_closest_action_path_container.get_path_editor().add_manual_target(section_action.create_manual_target())

func _process_fade() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.FADE_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item"):
		var time : float = _get_closest_grid_time_to_mouse()
		var fade_action := ActionFade.new(time, time)
		_current_hold_action = fade_action.create_manual_target()
		
		_closest_action_path_container.get_path_editor().add_manual_target(_current_hold_action)
		_current_hold_action.set_process.call_deferred(true)
		_current_hold_action.is_pressing_left_edit_button.connect(_is_pressing_left_edit_button_hold)
		_current_hold_action.is_pressing_right_edit_button.connect(_is_pressing_right_edit_button_hold)
		_current_hold_action.released_left_edit_button.connect(_hold_left_edit_button_released)
		_current_hold_action.released_right_edit_button.connect(_hold_right_edit_button_released)
	elif _current_hold_action != null and Input.is_action_pressed("Add Item"):
		_current_hold_action.set_end_time(_get_closest_grid_time_to_mouse())

func _process_speed() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.SPEED_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item") and _closest_action_path_container:
		var speed_action := ActionSpeed.new(_get_closest_grid_time_to_mouse())
		_closest_action_path_container.get_path_editor().add_manual_target(speed_action.create_manual_target())

func _process_boss() -> void:
	pass

func _process_dialog() -> void:
	pass

func _process_cinematic() -> void:
	pass

func _process_change_scenario() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.CHANGE_SCENARIO_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item") and _closest_action_path_container:
		var change_scenario_action := ActionChangeScenerio.new(_get_closest_grid_time_to_mouse())
		_closest_action_path_container.get_path_editor().add_manual_target(change_scenario_action.create_manual_target())

func _process_change_enemy() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.CHANGE_ENEMIES_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item") and _closest_action_path_container:
		var change_enemy_action := ActionChangeEnemy.new(_get_closest_grid_time_to_mouse())
		_closest_action_path_container.get_path_editor().add_manual_target(change_enemy_action.create_manual_target())

func _process_shake() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.SHAKE_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item") and _closest_action_path_container:
		var shake_action := ActionShake.new(_get_closest_grid_time_to_mouse())
		_closest_action_path_container.get_path_editor().add_manual_target(shake_action.create_manual_target())

func _process_camera() -> void:
	pass

func _process_vignette() -> void:
	pass

func _is_pressing_left_edit_button_hold(hold_target : HoldManual) -> void:
	_is_pressing_left_edit_hold_button = true
	
	var mouse_time := _get_closest_grid_time_to_mouse()
	
	if mouse_time != hold_target.get_start_time():
		hold_target.set_start_time(mouse_time)
		_pathway_editor.update_target(hold_target, true)

func _is_pressing_right_edit_button_hold(hold_target : HoldManual) -> void:
	_is_pressing_right_edit_hold_button = true
	
	var mouse_time := _get_closest_grid_time_to_mouse()
	
	if mouse_time != hold_target.get_end_time():
		hold_target.set_end_time(mouse_time)
		_pathway_editor.update_target(hold_target, true)

func _hold_left_edit_button_released() -> void:
	_is_pressing_left_edit_hold_button = false

func _hold_right_edit_button_released() -> void:
	_is_pressing_right_edit_hold_button = false

func _get_global_locked_mouse_position() -> Vector2:
	var mouse_pos : Vector2
	
	mouse_pos.x = _get_closest_grid_time_to_mouse_in_x() + _closest_action_path_container.global_position.x
	mouse_pos.y = _get_closest_action_path_container_mouse_y()
	
	return mouse_pos

func _get_closest_action_path_container() -> ActionPathContainer:
	var closest_distance : float = INF
	var closest_action_path_container : ActionPathContainer
	
	for action_path_container in _actions_paths_containers:
		var current_distance : float = (action_path_container.global_position + (action_path_container.get_global_rect().size / 2)).distance_squared_to(get_global_mouse_position())
		if current_distance < closest_distance:
			closest_action_path_container = action_path_container
			closest_distance = current_distance
	
	return closest_action_path_container

func _get_closest_action_path_container_mouse_y() -> float:
	return _closest_action_path_container.global_position.y + _closest_action_path_container.get_rect().size.y / 2 if _closest_action_path_container else INF

func _get_closest_grid_time_to_mouse_in_x() -> float:
	var time : float = clampf(_get_closest_grid_time_to_mouse(), 0, _highest_grid_time)
	return Path.get_pos_x(Song.get_time(), Song.get_time() + _pathway_editor.WIDTH_IN_SECS_BY_SPEED(), time, Path.hitzone, Path.width)

func _get_closest_grid_time_to_mouse() -> float:
	return clampf(SideGameEditor.get_closest_grid_time_pos(Path.get_time_x(Path.hitzone, Path.width, get_global_mouse_position().x, Song.get_time(), Song.get_time() + _pathway_editor.WIDTH_IN_SECS_BY_SPEED())), 0, _highest_grid_time)

func _get_closest_grid_time_pos(time_pos : float) -> float:
	return SideGameEditor.get_closest_grid_time_pos(time_pos)

func _get_next_grid_time_pos(time_pos : float) -> float:
	var grid_time_pos = _get_closest_grid_time_pos(time_pos)
	return clampf(_get_closest_grid_time_pos(grid_time_pos + SideMenuBarComposer.get_divisor()), 0.0, _highest_grid_time)

func _is_mouse_inside() -> bool:
	return get_global_rect().has_point(get_global_mouse_position())

func _draw() -> void:
	if not _pathway_editor:
		return
	
	var min_y = 0
	var max_y = get_rect().size.y
	
	var value := SideMenuBarComposer.get_divisor()
	var rest := fmod(Song.get_time() - Song.offset, value)
	var start_time_pos := Song.get_time() + value - rest
	var n_grids := int(_pathway_editor.WIDTH_IN_SECS_BY_SPEED() / value)
	
	for i in (n_grids + 2):
		var time : float = start_time_pos + (value * (i - 1))
		
		if time > _highest_grid_time:
			return
		elif time < Song.offset - 0.01: ## HAD TO DO THIS BECAUSE OF FLOAT ERROR
			continue
		
		var pos_x = Path.get_pos_x(Song.get_time(), Song.get_time() + _pathway_editor.WIDTH_IN_SECS_BY_SPEED(), time, Path.hitzone, Path.width)
		
		var is_start_line : bool = is_equal_approx(time, Song.offset)
		if not is_start_line:
			var is_end_line : bool = is_equal_approx(_highest_grid_time, time)
			if not is_end_line:
				draw_line(Vector2(pos_x, min_y), Vector2(pos_x, max_y), Color.WHITE, 1, true)
			else:
				draw_line(Vector2(pos_x, min_y), Vector2(pos_x, max_y), Color.MEDIUM_SPRING_GREEN, 5, true)
		else:
			draw_line(Vector2(pos_x, min_y), Vector2(pos_x, max_y), Color.CRIMSON, 5, true)
	
	var start_path_line_x := Path.get_pos_x(0, _pathway_editor.WIDTH_IN_SECS_BY_SPEED(), 0, Path.hitzone, Path.width)
	draw_line(Vector2(start_path_line_x, min_y), Vector2(start_path_line_x, max_y), Color.YELLOW, 5, true)
