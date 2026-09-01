extends Button

class_name SideGameEditor

const _TARGET_INFO_WINDOW_SCENE : PackedScene = preload("res://Editor/SIDE/Composer/TargetInfoWindow/TargetInfoWindow.tscn")

var _pathway_editor := PathwayEditor.new()

@onready var _side_game_components_list : SideGameComponents = $"../Game Components List"

@onready var _actions_container : ActionsContainer = $"../../ActionsContainer"

var _current_target_info_window : TargetInfoWindow

var _mouse_selection : Selection = Selection.new()

@onready var _mouse_time_display_panel : PanelContainer = $MouseTimeDisplay
@onready var _mouse_time_display_text : RichTextLabel = $MouseTimeDisplay/MarginContainer/RichTextLabel
const MOUSE_DISPLAY_DISTANCE : float = 10.0

var _attach_mouse_display : bool = false

@onready var _focus_effect : ReferenceRect = $"Focus Effect"

var _last_zoom_value : float = 1.0

var _sample_target := Sprite2D.new()

var _current_hold_target : HoldManual

static var _highest_grid_time : float = 0.0

## SELECTION

var _start_selection_global_position : Vector2
var _clicked_on_target : bool = false
var _selected_targets : Array[Target] = []
var _target_selected_clicked : Target

var _mouse_was_pressed_inside : bool = false
var _last_mouse_time_pos : float

var _leftest_target_selected : Target
var _rightest_target_selected : Target
var _has_both_paths_selected : bool = false

var _is_pressing_left_edit_hold_button : bool = false
var _is_pressing_right_edit_hold_button : bool = false

func _init() -> void: ## TEMP
	Song.set_song(load("res://Sound Test Sample/Brutal, acabou pro beta versão globo.mp3"))
	Song.BPM = 60
	Song.offset = 1.0
	_highest_grid_time = 0
	_calculate_highest_grid_time()

func _ready() -> void:
	add_child(_pathway_editor)
	add_child(_mouse_selection)
	
	_actions_container.setup.call_deferred(_pathway_editor, _highest_grid_time)
	
	_sample_target.global_position = Vector2(INF, INF)
	_sample_target.modulate.a = 0.5
	
	add_child(_sample_target)
	
	_side_game_components_list.resizing.connect(_is_resizing_game_components_list)

func _on_resized() -> void:
	_pathway_editor.global_position.y = global_position.y + (get_global_rect().size.y / 2)
	
	Path.width = Pathway.MAX_WIDTH - SideGameComponents.get_width()
	Path.hitzone = Path.BASE_HITZONE * Global.get_percentage_between(Pathway.get_distance_from_border(), Pathway.MAX_WIDTH, Path.width)

func _is_resizing_game_components_list() -> void:
	var zoom_value := SideMenuBarComposer.get_zoom_value()
	if _pathway_editor and zoom_value:
		_pathway_editor.set_speed(zoom_value)
	if _mouse_selection:
		_mouse_selection.set_global_rect(Rect2(0, 0, 0, 0))

func _process(delta: float) -> void:
	queue_redraw()
	
	_attach_mouse_display = false
	
	if Input.is_action_just_pressed("Add Item"):
		_mouse_was_pressed_inside = _is_mouse_inside()
		if not _mouse_was_pressed_inside:
			_clear_selected_targets()
	
	if Input.is_action_just_pressed("Scroll Up") and not _current_target_info_window and get_global_rect().has_point(get_global_mouse_position()):
		if Song.playing:
			Song.stop()
		Song.set_time(clampf(Song.get_time() + 0.1, 0.0, Song.get_duration()))
	elif Input.is_action_just_pressed("Scroll Down") and not _current_target_info_window and get_global_rect().has_point(get_global_mouse_position()):
		if Song.playing:
			Song.stop()
		Song.set_time(clampf(Song.get_time() - 0.1, 0.0, Song.get_duration()))
	
	if _last_zoom_value != SideMenuBarComposer.get_zoom_value():
		_pathway_editor.set_speed(SideMenuBarComposer.get_zoom_value())
		_last_zoom_value = SideMenuBarComposer.get_zoom_value()
	
	var selected_in_text : String = SideGameComponents.get_selected_in_text()
	if selected_in_text:
		_process_selected_game_component(selected_in_text)
	
	_adjust_mouse_time_display()
	
	#print(Path.get_time_x(Path.hitzone, Path.width, get_global_mouse_position().x, Song.get_time(), Song.get_time() + Path.WIDTH_IN_SECS))

func _process_selected_game_component(game_component : String) -> void:
	_sample_target.visible = false
	_sample_target.flip_v = false
	_attach_mouse_display = true
	
	match game_component:
		"Selecionar (E)":
			_process_select()
		"Leve 1", "Leve 2", "Leve 3":
			_process_light_items(game_component)
		"Médio 1", "Médio 2":
			_process_medium_items(game_component)
		"Pesado":
			_process_heavy_item()
		"Dupla":
			_process_twins_item()
		"Shield", "Fortified":
			_process_shield_item(game_component)
		"Clone":
			_process_clone_item()
		"Hammer":
			_process_hammer_item()
		"Hold":
			_process_hold_item()
		"Trap":
			_process_trap_item()
		"Machado":
			_process_axe_item()
		"Nota 1", "Nota 2":
			_process_note_item(game_component)
		"Coração":
			_process_heart_item()

func _process_select() -> void:
	_attach_mouse_display = not _selected_targets.is_empty()
	
	if _is_pressing_left_edit_hold_button or _is_pressing_right_edit_hold_button:
		return
	
	if Input.is_action_just_pressed("Delete"):
		for target in _selected_targets:
			if target is FakeClone:
				target.real_clone.fake_clones.erase(target)
			if target is RealClone:
				_pathway_editor.remove_full_real_clone(target, true, true)
			elif target is DelayTapEditor:
				_pathway_editor.remove_target_at(target.get_delay_parent().get_path_type(), target.get_delay_parent(), true, true)
				continue
			_pathway_editor.remove_target_at(target.get_path_type(), target, true, true)
		_selected_targets.clear()
	
	if Input.is_action_just_pressed("Inspect Note"):
		var selected_targets := _pathway_editor.get_global_targets_intersected_with(Rect2(get_global_mouse_position().x, get_global_mouse_position().y, 1, 1), Song.get_time(), Song.get_time() + _pathway_editor.WIDTH_IN_SECS_BY_SPEED())
		
		if selected_targets and selected_targets[0]:
			_current_target_info_window = _TARGET_INFO_WINDOW_SCENE.instantiate()
			add_child(_current_target_info_window)
			_current_target_info_window.setup(selected_targets[0], _pathway_editor)
			_current_target_info_window.popup_centered()
	
	if Input.is_action_just_pressed("Add Item"):
		var selected_targets := _pathway_editor.get_global_targets_intersected_with(Rect2(get_global_mouse_position().x, get_global_mouse_position().y, 1, 1), Song.get_time(), Song.get_time() + _pathway_editor.WIDTH_IN_SECS_BY_SPEED())
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
			var mouse_path_type := _get_path_type_at_mouse()
			
			## Change time pos
			if mouse_time_diff:
				if _leftest_target_selected.get_start_time() + mouse_time_diff >= Song.offset and (
					(_rightest_target_selected is HoldManual and _rightest_target_selected.get_end_time() + mouse_time_diff <= _highest_grid_time) or (
					not _rightest_target_selected is HoldManual and _rightest_target_selected.get_start_time() + mouse_time_diff <= _highest_grid_time)):
						for selected_target in _selected_targets:
							selected_target.set_start_time(selected_target.get_start_time() + mouse_time_diff)
							if selected_target is HoldManual:
								selected_target.set_end_time(selected_target.get_end_time() + mouse_time_diff)
			
			## Change paths
			if not _has_both_paths_selected and _target_selected_clicked.get_path_type() != mouse_path_type:
				for selected_target in _selected_targets:
					if selected_target is DelayTapEditor:
						_pathway_editor.change_target_path(mouse_path_type, selected_target.get_delay_parent(), true)
					else:
						_pathway_editor.change_target_path(mouse_path_type, selected_target, true)
		
		else: ## NOT CLICKED ON TARGET
			_mouse_selection.set_global_rect(Rect2(_start_selection_global_position.x, _start_selection_global_position.y, get_global_mouse_position().x - _start_selection_global_position.x, get_global_mouse_position().y - _start_selection_global_position.y))
	elif Input.is_action_just_released("Add Item"):
		if _clicked_on_target:
			_target_selected_clicked = null
			
		else: ## NOT CLICKED ON TARGET
			_select_targets(_pathway_editor.get_global_targets_intersected_with(_mouse_selection.get_global_rect(), Song.get_time(), Song.get_time() + _pathway_editor.WIDTH_IN_SECS_BY_SPEED()))
			_mouse_selection.set_global_rect(Rect2(0, 0, 0, 0))

func _process_light_items(type : String) -> void:
	if not _is_mouse_inside():
		return
	_sample_target.visible = true
	_attach_mouse_display = true
	_sample_target.global_position = _get_mouse_position_locked_by_paths()
	
	var light_variant : LightTap.Variants
	
	match type:
		"Leve 1":
			light_variant = LightTap.Variants.ONE
			_sample_target.texture = SideEditor.LIGHT_1_TEXTURE
		"Leve 2":
			light_variant = LightTap.Variants.TWO
			_sample_target.texture = SideEditor.LIGHT_2_TEXTURE
		"Leve 3":
			light_variant = LightTap.Variants.THREE
			_sample_target.texture = SideEditor.LIGHT_3_TEXTURE
	
	if Input.is_action_just_pressed("Add Item"):
		var target : Target = LightTap.new(_get_closest_grid_time_to_mouse(), _get_path_type_at_mouse(), light_variant)
		target.create_target_editor()
		_pathway_editor.add_target_at(_get_path_type_at_mouse(), target)

func _process_medium_items(type : String) -> void:
	if not _is_mouse_inside():
		return
	_sample_target.visible = true
	_attach_mouse_display = true
	_sample_target.global_position = _get_mouse_position_locked_by_paths()
	
	var medium_variant : MediumTap.Variants
	
	match type:
		"Médio 1":
			medium_variant = MediumTap.Variants.ONE
			_sample_target.texture = SideEditor.MEDIUM_1_TEXTURE
		"Médio 2":
			medium_variant = MediumTap.Variants.TWO
			_sample_target.texture = SideEditor.MEDIUM_2_TEXTURE
	
	if Input.is_action_just_pressed("Add Item"):
		var target : Target = MediumTap.new(_get_closest_grid_time_to_mouse(), _get_path_type_at_mouse(), medium_variant)
		target.create_target_editor()
		_pathway_editor.add_target_at(_get_path_type_at_mouse(), target)

func _process_heavy_item() -> void:
	if not _is_mouse_inside():
		return
	_sample_target.visible = true
	_attach_mouse_display = true
	_sample_target.global_position = _get_mouse_position_locked_by_paths()
	
	if _get_path_type_at_mouse() == Path.Types.GROUND:
		_sample_target.global_position.y += - Path.HEIGHT
	else: ## AIR
		_sample_target.global_position.y += Path.HEIGHT
	
	_sample_target.texture = SideEditor.HEAVY_TEXTURE
	
	if Input.is_action_just_pressed("Add Item"):
		_current_hold_target = Spam.new(_get_closest_grid_time_to_mouse(), _get_closest_grid_time_to_mouse(), _get_path_type_at_mouse())
		_current_hold_target.create_target_editor()
		_pathway_editor.add_target_at(_get_path_type_at_mouse(), _current_hold_target)
		_current_hold_target.set_process.call_deferred(true)
		_current_hold_target.is_pressing_left_edit_button.connect(_is_pressing_left_edit_button_hold)
		_current_hold_target.is_pressing_right_edit_button.connect(_is_pressing_right_edit_button_hold)
		_current_hold_target.released_left_edit_button.connect(_hold_left_edit_button_released)
		_current_hold_target.released_right_edit_button.connect(_hold_right_edit_button_released)
	elif _current_hold_target != null and Input.is_action_pressed("Add Item"):
		_sample_target.visible = false
		_current_hold_target.set_end_time(_get_closest_grid_time_to_mouse())

func _process_twins_item() -> void:
	if not _is_mouse_inside():
		return
	_sample_target.visible = true
	_attach_mouse_display = true
	_sample_target.global_position = _get_mouse_position_locked_by_paths()
	
	if _get_path_type_at_mouse() == Path.Types.GROUND:
		_sample_target.global_position.y += - Path.HEIGHT
	else: ## AIR
		_sample_target.global_position.y += Path.HEIGHT
	
	_sample_target.texture = SideEditor.TWINS_TEXTURE
	
	if Input.is_action_just_pressed("Add Item"):
		var target : Target = TwinTap.new(_get_closest_grid_time_to_mouse(), _get_path_type_at_mouse(), true)
		target.create_target_editor()
		_pathway_editor.add_target_at(_get_path_type_at_mouse(), target)

func _process_shield_item(type : String) -> void:
	if not _is_mouse_inside():
		return
	_sample_target.visible = true
	_attach_mouse_display = true
	_sample_target.global_position = _get_mouse_position_locked_by_paths()
	
	if type == "Shield":
		_sample_target.texture = SideEditor.SHIELD_1_TEXTURE
	else:
		_sample_target.texture = SideEditor.SHIELD_2_TEXTURE
	
	if Input.is_action_just_pressed("Add Item"):
		if type == "Shield":
			var shield_target = OneTimeDelayEditor.new(_get_closest_grid_time_to_mouse(), _get_next_avaliabe_time_from(_get_closest_grid_time_to_mouse()), _get_path_type_at_mouse())
			shield_target.create_target_editor()
			_pathway_editor.add_target_at(_get_path_type_at_mouse(), shield_target)
		elif type == "Fortified":
			var fortified_target = TwoTimesDelayEditor.new(_get_closest_grid_time_to_mouse(), _get_next_avaliabe_time_from(_get_closest_grid_time_to_mouse()), 0, _get_path_type_at_mouse())
			fortified_target.create_target_editor()
			fortified_target.set_second_time_delay(_get_next_avaliabe_time_from(fortified_target.get_first_time_delay()))
			_pathway_editor.add_target_at(_get_path_type_at_mouse(), fortified_target)

func _process_clone_item() -> void:
	if not _is_mouse_inside():
		return
	_sample_target.visible = true
	_attach_mouse_display = true
	_sample_target.global_position = _get_mouse_position_locked_by_paths()
	
	_sample_target.texture = SideEditor.CLONE_FINAL_TEXTURE
	
	if Input.is_action_just_pressed("Add Item"):
		var target : Target = RealClone.new(_get_closest_grid_time_to_mouse(), _get_path_type_at_mouse())
		target.create_target_editor()
		_pathway_editor.add_target_at(_get_path_type_at_mouse(), target)

func _process_hammer_item() -> void:
	if not _is_mouse_inside():
		return
	_sample_target.visible = true
	_attach_mouse_display = true
	_sample_target.global_position = _get_mouse_position_locked_by_paths()
	
	_sample_target.texture = SideEditor.HAMMER_TEXTURE
	
	_sample_target.flip_v = _get_path_type_at_mouse() == Path.Types.GROUND
	
	if Input.is_action_just_pressed("Add Item"):
		var target : Target = HammerTap.new(_get_closest_grid_time_to_mouse(), _get_path_type_at_mouse())
		target.create_target_editor()
		_pathway_editor.add_target_at(_get_path_type_at_mouse(), target)

func _process_hold_item() -> void:
	if not _is_mouse_inside():
		return
	_sample_target.visible = true
	_attach_mouse_display = true
	_sample_target.global_position = _get_mouse_position_locked_by_paths()
	
	_sample_target.texture = SideEditor.START_HOLD_TEXTURE
	
	if Input.is_action_just_pressed("Add Item"):
		_current_hold_target = HoldManual.new(_get_closest_grid_time_to_mouse(), _get_closest_grid_time_to_mouse(), _get_path_type_at_mouse())
		_current_hold_target.create_target_editor()
		_pathway_editor.add_target_at(_get_path_type_at_mouse(), _current_hold_target)
		_current_hold_target.set_process.call_deferred(true)
		_current_hold_target.is_pressing_left_edit_button.connect(_is_pressing_left_edit_button_hold)
		_current_hold_target.is_pressing_right_edit_button.connect(_is_pressing_right_edit_button_hold)
		_current_hold_target.released_left_edit_button.connect(_hold_left_edit_button_released)
		_current_hold_target.released_right_edit_button.connect(_hold_right_edit_button_released)
	elif _current_hold_target != null and Input.is_action_pressed("Add Item"):
		_sample_target.visible = false
		_current_hold_target.set_end_time(_get_closest_grid_time_to_mouse())

func _process_trap_item() -> void:
	if not _is_mouse_inside():
		return
	_sample_target.visible = true
	_attach_mouse_display = true
	_sample_target.global_position = _get_mouse_position_locked_by_paths()
	
	_sample_target.texture = SideEditor.TRAP_TEXTURE
	
	if Input.is_action_just_pressed("Add Item"):
		var target = Trap.new(_get_closest_grid_time_to_mouse(), _get_path_type_at_mouse())
		target.create_target_editor()
		_pathway_editor.add_target_at(_get_path_type_at_mouse(), target)

func _process_axe_item() -> void:
	if not _is_mouse_inside():
		return
	_sample_target.visible = true
	_attach_mouse_display = true
	_sample_target.global_position = _get_mouse_position_locked_by_paths()
	
	_sample_target.texture = SideEditor.AXE_TEXTURE
	
	_sample_target.flip_v = _get_path_type_at_mouse() == Path.Types.GROUND
	
	if Input.is_action_just_pressed("Add Item"):
		var target = AxeTrap.new(_get_closest_grid_time_to_mouse(), _get_path_type_at_mouse())
		target.create_target_editor()
		_pathway_editor.add_target_at(_get_path_type_at_mouse(), target)

func _process_note_item(type : String) -> void:
	if not _is_mouse_inside():
		return
	_sample_target.visible = true
	_attach_mouse_display = true
	_sample_target.global_position = _get_mouse_position_locked_by_paths()
	
	var note_variant : MusicalNote.Variants
	
	match type:
		"Nota 1":
			note_variant = MusicalNote.Variants.ONE
			_sample_target.texture = SideEditor.NOTE_1_TEXTURE
		"Nota 2":
			note_variant = MusicalNote.Variants.TWO
			_sample_target.texture = SideEditor.NOTE_2_TEXTURE
	
	if Input.is_action_just_pressed("Add Item"):
		var target = MusicalNote.new(_get_closest_grid_time_to_mouse(), _get_path_type_at_mouse(), note_variant)
		target.create_target_editor()
		_pathway_editor.add_target_at(_get_path_type_at_mouse(), target)

func _process_heart_item() -> void:
	if not _is_mouse_inside():
		return
	_sample_target.visible = true
	_attach_mouse_display = true
	_sample_target.global_position = _get_mouse_position_locked_by_paths()
	
	_sample_target.texture = SideEditor.HEART_TEXTURE
	
	if Input.is_action_just_pressed("Add Item"):
		var target = Heart.new(_get_closest_grid_time_to_mouse(), _get_path_type_at_mouse())
		target.create_target_editor()
		_pathway_editor.add_target_at(_get_path_type_at_mouse(), target)

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

func _select_targets(targets : Array[Target]) -> void:
	_has_both_paths_selected = false
	var has_air_target : bool = false
	var has_ground_target : bool = false
	
	for target in targets:
		_righest_or_leftest_selected(target)
		if target is Spam or target is TwinTap:
			has_air_target = true
			has_ground_target = true
		elif target.get_path_type() == Path.Types.AIR:
			has_air_target = true
		else:
			has_ground_target = true
		
		target.target_editor.set_selected_highlight(true)
		_selected_targets.append(target)
	
	_has_both_paths_selected = has_air_target and has_ground_target

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

func _get_next_avaliabe_time_from(time : float) -> float:
	return clampf(time + SideMenuBarComposer.get_divisor(), 0, _highest_grid_time) 

func _adjust_mouse_time_display() -> void:
	var pos_x : float
	var mouse_time : float
	
	if _attach_mouse_display:
		mouse_time = _get_closest_grid_time_to_mouse()
		pos_x = Path.get_pos_x(Song.get_time(), Song.get_time() + _pathway_editor.WIDTH_IN_SECS_BY_SPEED(), mouse_time, Path.hitzone, Path.width)
	else:
		pos_x = _get_limited_by_pathway_mouse_position().x
		mouse_time = Path.get_time_x(Path.hitzone, Path.width, pos_x, Song.get_time(), Song.get_time() + _pathway_editor.WIDTH_IN_SECS_BY_SPEED())
	
	_mouse_time_display_panel.position.x = pos_x - _mouse_time_display_panel.get_rect().size.x / 2
	_mouse_time_display_panel.position.y = _pathway_editor.get_ground_path_global_position().y - global_position.y + Path.HEIGHT / 2 + MOUSE_DISPLAY_DISTANCE
	
	_mouse_time_display_text.text = Global.time_to_text(mouse_time)

func _get_limited_by_pathway_mouse_position() -> Vector2:
	var mouse_pos := get_local_mouse_position()
	
	if mouse_pos.x < Path.hitzone:
		mouse_pos.x = Path.hitzone
	elif mouse_pos.x > Path.width:
		mouse_pos.x = Path.width
	
	var min_y = _pathway_editor.get_air_path_global_position().y - global_position.y - Path.HEIGHT / 2
	var max_y = _pathway_editor.get_ground_path_global_position().y - global_position.y + Path.HEIGHT / 2
	
	if mouse_pos.y < min_y:
		mouse_pos.y = min_y
	elif mouse_pos.y > max_y:
		mouse_pos.y = max_y
	
	mouse_pos.y = mouse_pos.y if mouse_pos.y <= get_rect().size.y else get_rect().size.y
	return mouse_pos

func _get_mouse_position_locked_by_paths() -> Vector2:
	var mouse_pos := get_global_mouse_position()
	var path_type_at_mouse : Path.Types = _get_path_type_at_mouse()
	
	if path_type_at_mouse == Path.Types.AIR:
		mouse_pos.y = _pathway_editor.get_air_path_global_position().y
	else: ## GROUND
		mouse_pos.y = _pathway_editor.get_ground_path_global_position().y
	
	mouse_pos.x = _get_closest_grid_time_to_mouse_in_x()
	
	return mouse_pos

func _get_path_type_at_mouse() -> Path.Types:
	if (_pathway_editor.get_air_path_global_position().distance_squared_to(get_global_mouse_position()) < 
		_pathway_editor.get_ground_path_global_position().distance_squared_to(get_global_mouse_position())):
		
		return Path.Types.AIR
	else:
		return Path.Types.GROUND

func _get_closest_grid_time_to_mouse_in_x() -> float:
	var time : float = clampf(_get_closest_grid_time_to_mouse(), 0, _highest_grid_time)
	return Path.get_pos_x(Song.get_time(), Song.get_time() + _pathway_editor.WIDTH_IN_SECS_BY_SPEED(),time, Path.hitzone, Path.width)

func _get_closest_grid_time_to_mouse() -> float:
	return clampf(get_closest_grid_time_pos(Path.get_time_x(Path.hitzone, Path.width, get_global_mouse_position().x, Song.get_time(), Song.get_time() + _pathway_editor.WIDTH_IN_SECS_BY_SPEED())), 0, _highest_grid_time)

func _calculate_highest_grid_time() -> void:
	var time : float = get_closest_grid_time_pos(Song.get_duration())
	if time > Song.get_duration():
		_highest_grid_time = time - SideMenuBarComposer.get_divisor()
	else:
		_highest_grid_time = time

static func _get_highest_grid_time() -> float:
	return _highest_grid_time

static func get_closest_grid_time_pos(time_pos : float) -> float:
	if time_pos < Song.offset:
		return Song.offset
	else:
		time_pos -= Song.offset
		
	var value := SideMenuBarComposer.get_divisor()
	var rest := fmod(time_pos, value)
	if rest <= value / 2.0:
		time_pos -= rest
	else:
		time_pos += value - rest
	return time_pos + Song.offset

static func get_next_grid_time_pos(time_pos : float) -> float:
	var grid_time_pos = get_closest_grid_time_pos(time_pos)
	return clampf(get_closest_grid_time_pos(grid_time_pos + SideMenuBarComposer.get_divisor()), 0.0, _highest_grid_time)

func _is_mouse_inside() -> bool:
	return get_global_rect().has_point(get_global_mouse_position())

func _draw() -> void:
	var min_y = _pathway_editor.get_air_path_global_position().y - global_position.y - Path.HEIGHT / 2
	var max_y = _pathway_editor.get_ground_path_global_position().y - global_position.y + Path.HEIGHT / 2
	
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
				draw_line(Vector2(pos_x, min_y), Vector2(pos_x, min_y + Path.HEIGHT), Color.WHITE, 1, true)
				draw_line(Vector2(pos_x, max_y - Path.HEIGHT), Vector2(pos_x, max_y), Color.WHITE, 1, true)
			else:
				draw_line(Vector2(pos_x, min_y), Vector2(pos_x, min_y + Path.HEIGHT), Color.MEDIUM_SPRING_GREEN, 5, true)
				draw_line(Vector2(pos_x, max_y - Path.HEIGHT), Vector2(pos_x, max_y), Color.MEDIUM_SPRING_GREEN, 5, true)
		else:
			draw_line(Vector2(pos_x, min_y), Vector2(pos_x, min_y + Path.HEIGHT), Color.CRIMSON, 5, true)
			draw_line(Vector2(pos_x, max_y - Path.HEIGHT), Vector2(pos_x, max_y), Color.CRIMSON, 5, true)

func _on_focus_entered() -> void:
	_focus_effect.visible = true

func _on_focus_exited() -> void:
	_focus_effect.visible = false
