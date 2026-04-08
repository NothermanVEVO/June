extends VBoxContainer

class_name ActionsVBoxContainer

@onready var _actions_container : ActionsContainer = $"../../../../.."

var _pathway_editor : PathwayEditor
var _highest_grid_time : float

var _sample_action := Sprite2D.new()
var _current_hold_action : ManualTargetActionHold

var _closest_action_path_container : ActionPathContainer = null

var _actions_paths_containers : Array[ActionPathContainer]

var _is_pressing_left_edit_hold_button : bool = false
var _is_pressing_right_edit_hold_button : bool = false

var _mouse_selection : Selection = Selection.new()

var _start_selection_global_position : Vector2
var _clicked_on_target : bool = false
var _selected_targets : Array[Target] = []
var _target_selected_clicked : Target
var _lowest_selected_target_index : int
var _highest_selected_target_index : int

var _mouse_was_pressed_inside : bool = false
var _last_mouse_time_pos : float

var _leftest_target_selected : ManualTarget
var _rightest_target_selected : ManualTarget

@onready var _actions_item_list : ItemList = $"../ActionListMarginContainer/ActionsItemList"

func setup(pathway_editor : PathwayEditor, highest_grid_time : float, actions_paths_containers : Array[ActionPathContainer]) -> void:
	_pathway_editor = pathway_editor
	
	if _pathway_editor:
		_pathway_editor.changed_speed.connect(_changed_speed)
	
	_highest_grid_time = highest_grid_time
	_actions_paths_containers = actions_paths_containers

func _ready() -> void:
	add_child(_mouse_selection)
	
	_sample_action.global_position = Vector2(INF, INF)
	_sample_action.modulate.a = 0.5
	_sample_action.scale *= 1.5
	
	add_child(_sample_action)
	
	resized.connect(_resized)
	
	_actions_container.changed_actions_path_order.connect(_changed_actions_path_order)

func _changed_actions_path_order() -> void:
	_actions_paths_containers.sort_custom(func(a, b):
		return a.index < b.index
		)
	
	for target in _selected_targets:
		_lowest_and_highest_selected(target)

func _resized() -> void:
	if _mouse_selection:
		_mouse_selection.set_global_rect(Rect2(0, 0, 0, 0))

func _changed_speed(speed : float) -> void:
	for action_path_container in _actions_paths_containers:
		action_path_container.get_path_editor().set_speed(speed)

func _process(delta: float) -> void:
	queue_redraw()
	
	_closest_action_path_container = _get_closest_action_path_container()
	
	if Input.is_action_just_pressed("Add Item"):
		_mouse_was_pressed_inside = _is_mouse_inside() and not _actions_container.is_resizing()
	
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
		"Diálogo": ## HOLD
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
	if _is_pressing_left_edit_hold_button or _is_pressing_right_edit_hold_button:
		return
	
	if Input.is_action_just_pressed("Delete"):
		for target in _selected_targets:
			_actions_paths_containers[target.path_index].get_path_editor().remove_manual_target(target, true)
		_selected_targets.clear()
	
	#if Input.is_action_just_pressed("Inspect Note"):
		#var selected_targets := _get_global_targets_intersected_with(Rect2(get_global_mouse_position().x, get_global_mouse_position().y, 1, 1), Song.get_time(), Song.get_time() + _pathway_editor.WIDTH_IN_SECS_BY_SPEED())
		#
		#if selected_targets and selected_targets[0]:
			#_current_target_info_window = _TARGET_INFO_WINDOW_SCENE.instantiate()
			#add_child(_current_target_info_window)
			#_current_target_info_window.setup(selected_targets[0], _pathway_editor)
			#_current_target_info_window.popup_centered()
	
	if Input.is_action_just_pressed("Add Item"):
		
		var selected_targets := _get_global_targets_intersected_with(Rect2(get_global_mouse_position().x, get_global_mouse_position().y, 1, 1), Song.get_time(), Song.get_time() + _pathway_editor.WIDTH_IN_SECS_BY_SPEED())
		_clicked_on_target = not selected_targets.is_empty()
		
		if not _clicked_on_target:
			_target_selected_clicked = null
			_clear_selected_targets()
			_start_selection_global_position = get_global_mouse_position()
		else: ## CLICKED ON TARGET
			
			_target_selected_clicked = selected_targets[0]
			
			_last_mouse_time_pos = _get_closest_grid_time_to_mouse()
			
			if not _target_selected_clicked.target_editor.is_selected():
				_clear_selected_targets()
				_select_targets(selected_targets.slice(0, 1))
		
	elif Input.is_action_pressed("Add Item") and _mouse_was_pressed_inside:
		if _clicked_on_target:
			var mouse_time_pos := _get_closest_grid_time_to_mouse()
			var mouse_time_diff : float = mouse_time_pos - _last_mouse_time_pos
			_last_mouse_time_pos = mouse_time_pos
			var mouse_path_idx := _get_action_path_idx_in_mouse()
			
			## Change time pos
			if mouse_time_diff:
				if _leftest_target_selected.get_start_time() + mouse_time_diff >= Song.offset and (
					(_rightest_target_selected is HoldManual and _rightest_target_selected.get_end_time() + mouse_time_diff <= _highest_grid_time) or (
					_rightest_target_selected.get_start_time() + mouse_time_diff <= _highest_grid_time)):
						for selected_target in _selected_targets:
							selected_target.set_start_time(selected_target.get_start_time() + mouse_time_diff)
							if selected_target is HoldManual:
								selected_target.set_end_time(selected_target.get_end_time() + mouse_time_diff)
			
			## Change paths
			if _target_selected_clicked.path_index >= 0 and mouse_path_idx >= 0 and _target_selected_clicked.path_index != mouse_path_idx:
				var index_difference : int = (mouse_path_idx - _target_selected_clicked.path_index)
				if _lowest_selected_target_index + index_difference >= 0 and _highest_selected_target_index + index_difference < _actions_paths_containers.size():
					_lowest_selected_target_index += index_difference
					_highest_selected_target_index += index_difference
					for selected_target in _selected_targets:
						change_target_path(selected_target, selected_target.path_index, clampi(selected_target.path_index + index_difference, 0, _actions_paths_containers.size()), true)
		
		else: ## NOT CLICKED ON TARGET
			_mouse_selection.set_global_rect(Rect2(_start_selection_global_position.x, _start_selection_global_position.y, get_global_mouse_position().x - _start_selection_global_position.x, get_global_mouse_position().y - _start_selection_global_position.y))
	elif Input.is_action_just_released("Add Item"):
		if _clicked_on_target:
			_target_selected_clicked = null
			
		else: ## NOT CLICKED ON TARGET
			_select_targets(_get_global_targets_intersected_with(_mouse_selection.get_global_rect(), Song.get_time(), Song.get_time() + _pathway_editor.WIDTH_IN_SECS_BY_SPEED()))
			_mouse_selection.set_global_rect(Rect2(0, 0, 0, 0))

func _process_comment() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.COMMENT_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item") and _closest_action_path_container:
		var comment_action := ActionComment.new(_get_closest_grid_time_to_mouse())
		_closest_action_path_container.add_manual_target(comment_action.create_manual_target())

func _process_section() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.SECTION_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item") and _closest_action_path_container:
		var section_action := ActionSection.new(_get_closest_grid_time_to_mouse())
		_closest_action_path_container.add_manual_target(section_action.create_manual_target())

func _process_fade() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.FADE_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item"):
		var time : float = _get_closest_grid_time_to_mouse()
		var fade_action := ActionFade.new(time, time)
		_current_hold_action = fade_action.create_manual_target()
		
		_closest_action_path_container.add_manual_target(_current_hold_action)
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
		_closest_action_path_container.add_manual_target(speed_action.create_manual_target())

func _process_boss() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.BOSS_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item"):
		var time : float = _get_closest_grid_time_to_mouse()
		var fade_action := ActionBoss.new(time, time)
		_current_hold_action = fade_action.create_manual_target()
		
		_closest_action_path_container.add_manual_target(_current_hold_action)
		_current_hold_action.set_process.call_deferred(true)
		_current_hold_action.is_pressing_left_edit_button.connect(_is_pressing_left_edit_button_hold)
		_current_hold_action.is_pressing_right_edit_button.connect(_is_pressing_right_edit_button_hold)
		_current_hold_action.released_left_edit_button.connect(_hold_left_edit_button_released)
		_current_hold_action.released_right_edit_button.connect(_hold_right_edit_button_released)
	elif _current_hold_action != null and Input.is_action_pressed("Add Item"):
		_current_hold_action.set_end_time(_get_closest_grid_time_to_mouse())

func _process_dialog() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.DIALOG_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item"):
		var time : float = _get_closest_grid_time_to_mouse()
		var fade_action := ActionDialog.new(time, time)
		_current_hold_action = fade_action.create_manual_target()
		
		_closest_action_path_container.add_manual_target(_current_hold_action)
		_current_hold_action.set_process.call_deferred(true)
		_current_hold_action.is_pressing_left_edit_button.connect(_is_pressing_left_edit_button_hold)
		_current_hold_action.is_pressing_right_edit_button.connect(_is_pressing_right_edit_button_hold)
		_current_hold_action.released_left_edit_button.connect(_hold_left_edit_button_released)
		_current_hold_action.released_right_edit_button.connect(_hold_right_edit_button_released)
	elif _current_hold_action != null and Input.is_action_pressed("Add Item"):
		_current_hold_action.set_end_time(_get_closest_grid_time_to_mouse())

func _process_cinematic() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.CINEMATIC_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item"):
		var time : float = _get_closest_grid_time_to_mouse()
		var fade_action := ActionCinematic.new(time, time)
		_current_hold_action = fade_action.create_manual_target()
		
		_closest_action_path_container.add_manual_target(_current_hold_action)
		_current_hold_action.set_process.call_deferred(true)
		_current_hold_action.is_pressing_left_edit_button.connect(_is_pressing_left_edit_button_hold)
		_current_hold_action.is_pressing_right_edit_button.connect(_is_pressing_right_edit_button_hold)
		_current_hold_action.released_left_edit_button.connect(_hold_left_edit_button_released)
		_current_hold_action.released_right_edit_button.connect(_hold_right_edit_button_released)
	elif _current_hold_action != null and Input.is_action_pressed("Add Item"):
		_current_hold_action.set_end_time(_get_closest_grid_time_to_mouse())

func _process_change_scenario() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.CHANGE_SCENARIO_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item") and _closest_action_path_container:
		var change_scenario_action := ActionChangeScenerio.new(_get_closest_grid_time_to_mouse())
		_closest_action_path_container.add_manual_target(change_scenario_action.create_manual_target())

func _process_change_enemy() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.CHANGE_ENEMIES_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item") and _closest_action_path_container:
		var change_enemy_action := ActionChangeEnemy.new(_get_closest_grid_time_to_mouse())
		_closest_action_path_container.add_manual_target(change_enemy_action.create_manual_target())

func _process_shake() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.SHAKE_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item") and _closest_action_path_container:
		var shake_action := ActionShake.new(_get_closest_grid_time_to_mouse())
		_closest_action_path_container.add_manual_target(shake_action.create_manual_target())

func _process_camera() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.CAMERA_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item"):
		var time : float = _get_closest_grid_time_to_mouse()
		var fade_action := ActionCamera.new(time, time)
		_current_hold_action = fade_action.create_manual_target()
		
		_closest_action_path_container.add_manual_target(_current_hold_action)
		_current_hold_action.set_process.call_deferred(true)
		_current_hold_action.is_pressing_left_edit_button.connect(_is_pressing_left_edit_button_hold)
		_current_hold_action.is_pressing_right_edit_button.connect(_is_pressing_right_edit_button_hold)
		_current_hold_action.released_left_edit_button.connect(_hold_left_edit_button_released)
		_current_hold_action.released_right_edit_button.connect(_hold_right_edit_button_released)
	elif _current_hold_action != null and Input.is_action_pressed("Add Item"):
		_current_hold_action.set_end_time(_get_closest_grid_time_to_mouse())

func _process_vignette() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.VIGNETTE_ICON_TEXTURE
	_sample_action.global_position = _get_global_locked_mouse_position()
	
	if Input.is_action_just_pressed("Add Item"):
		var time : float = _get_closest_grid_time_to_mouse()
		var fade_action := ActionVignette.new(time, time)
		_current_hold_action = fade_action.create_manual_target()
		
		_closest_action_path_container.add_manual_target(_current_hold_action)
		_current_hold_action.set_process.call_deferred(true)
		_current_hold_action.is_pressing_left_edit_button.connect(_is_pressing_left_edit_button_hold)
		_current_hold_action.is_pressing_right_edit_button.connect(_is_pressing_right_edit_button_hold)
		_current_hold_action.released_left_edit_button.connect(_hold_left_edit_button_released)
		_current_hold_action.released_right_edit_button.connect(_hold_right_edit_button_released)
	elif _current_hold_action != null and Input.is_action_pressed("Add Item"):
		_current_hold_action.set_end_time(_get_closest_grid_time_to_mouse())

func _get_global_targets_intersected_with(rect : Rect2, from : float, to : float) -> Array[Target]:
	var intersected_targets : Array[Target] = []
	
	var targets : Array[Target] = []
	for action_path_container in _actions_paths_containers:
		targets.append_array(action_path_container.get_path_editor().get_targets(from, to))
	
	for target in targets:
		if target is Blank or target is HoldBlank or not target.get_global_rect().intersects(rect, true):
			continue
		intersected_targets.append(target)
	
	return intersected_targets

func change_target_path(manual_target : ManualTarget, from_path_idx : int, to_path_idx : int, validate : bool) -> void:
	_actions_paths_containers[from_path_idx].get_path_editor().remove_manual_target(manual_target)
	_actions_paths_containers[to_path_idx].add_manual_target(manual_target)

func _get_action_path_idx_in_mouse() -> int:
	var idx := -1
	
	for action_path_container in _actions_paths_containers:
		if action_path_container.get_global_rect().has_point(get_global_mouse_position()):
			idx = action_path_container.index
			break
	
	return idx

func _clear_selected_targets() -> void:
	for selected_target in _selected_targets:
		selected_target.target_editor.set_selected_highlight(false)
	_selected_targets.clear()
	_rightest_target_selected = null
	_leftest_target_selected = null

func _righest_or_leftest_selected(target : Target) -> void:
	if not _leftest_target_selected or not _rightest_target_selected:
		_leftest_target_selected = target
		_rightest_target_selected = target
		return
	
	if target is HoldManual:
		if target.get_start_time() < _leftest_target_selected.get_start_time():
			_leftest_target_selected = target
		if _rightest_target_selected is HoldManual:
			if target.get_end_time() > _rightest_target_selected.get_end_time():
				_rightest_target_selected = target
		else:
			if target.get_end_time() > _rightest_target_selected.get_start_time():
				_rightest_target_selected = target
	else:
		if target.get_start_time() < _leftest_target_selected.get_start_time():
			_leftest_target_selected = target
		if _rightest_target_selected is HoldManual:
			if target.get_start_time() > _rightest_target_selected.get_end_time():
				_rightest_target_selected = target
		else:
			if target.get_start_time() > _rightest_target_selected.get_start_time():
				_rightest_target_selected = target

func _select_targets(targets : Array[Target]) -> void:
	_lowest_selected_target_index = 9223372036854775807
	_highest_selected_target_index = -9223372036854775807
	
	for target in targets:
		_righest_or_leftest_selected(target)
		_lowest_and_highest_selected(target)
		
		target.target_editor.set_selected_highlight(true)
		_selected_targets.append(target)

func _lowest_and_highest_selected(target : Target) -> void:
	if target.path_index < _lowest_selected_target_index:
		_lowest_selected_target_index = target.path_index
	if target.path_index > _highest_selected_target_index:
		_highest_selected_target_index = target.path_index

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
	var mouse_pos := get_global_mouse_position()
	return mouse_pos.x >= Path.hitzone and get_global_rect().has_point(mouse_pos)

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
