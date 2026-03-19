extends VBoxContainer

class_name ActionsVBoxContainer

var _pathway_editor : PathwayEditor
var _highest_grid_time : float

var _sample_action := Sprite2D.new()
var _current_hold_action : ManualTargetActionHold

var _actions_paths_containers : Array[ActionPathContainer]

@onready var _actions_item_list : ItemList = $"../ActionListMarginContainer/ActionsItemList"

func setup(pathway_editor : PathwayEditor, highest_grid_time : float, actions_paths_containers : Array[ActionPathContainer]) -> void:
	_pathway_editor = pathway_editor
	_highest_grid_time = highest_grid_time
	_actions_paths_containers = actions_paths_containers

func _ready() -> void:
	_sample_action.global_position = Vector2(INF, INF)
	_sample_action.modulate.a = 0.5
	_sample_action.scale *= 1.5
	
	add_child(_sample_action)

func _process(delta: float) -> void:
	queue_redraw()
	
	var selected_items := _actions_item_list.get_selected_items()
	
	if not selected_items.is_empty() and not _actions_paths_containers.is_empty():
		_handle_selected_item(_actions_item_list.get_item_text(selected_items[0]))

func _handle_selected_item(item_text : String) -> void:
	if not _is_mouse_inside():
		_sample_action.texture = null
	
	match item_text:
		"Selecionar":
			pass
		"Comentário":
			_process_comment() ## DOING
		"Seção":
			pass
		"Fade":
			pass
		"Speed":
			pass
		"Chefão":
			pass
		"Dialogo":
			pass
		"Cinemática":
			pass
		"Trocar cenário":
			pass
		"Trocar inimigos":
			pass
		"Tremor":
			pass
		"Câmera":
			pass
		"Vinheta":
			pass

func _process_comment() -> void:
	if not _is_mouse_inside():
		return
	
	_sample_action.texture = SideEditor.COMMENT_ICON_TEXTURE
	_sample_action.position = _get_global_locked_mouse_position()

func _get_global_locked_mouse_position() -> Vector2:
	var mouse_pos : Vector2
	
	mouse_pos.x = _get_closest_grid_time_to_mouse_in_x()
	mouse_pos.y = _get_closest_action_path_container_mouse_y()
	
	return mouse_pos

func _get_closest_action_path_container_mouse_y() -> float:
	var closest_distance : float = INF
	var closest_y : float = INF
	
	for action_path_container in _actions_paths_containers:
		var current_distance : float = (action_path_container.global_position + (action_path_container.get_global_rect().size / 2)).distance_squared_to(get_global_mouse_position())
		if current_distance < closest_distance:
			closest_y = action_path_container.get_middle_y()
			closest_distance = current_distance
	
	return closest_y

func _get_closest_grid_time_to_mouse_in_x() -> float:
	var time : float = clampf(_get_closest_grid_time_to_mouse(), 0, _highest_grid_time)
	return Path.get_pos_x(Song.get_time(), Song.get_time() + _pathway_editor.WIDTH_IN_SECS_BY_SPEED(),time, Path.hitzone, Path.width)

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
