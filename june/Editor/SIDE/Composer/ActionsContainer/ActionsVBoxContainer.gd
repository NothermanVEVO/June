extends VBoxContainer

class_name ActionsVBoxContainer

var _pathway_editor : PathwayEditor

var _highest_grid_time : float

@onready var _actions_item_list : ItemList = $"../ActionListMarginContainer/ActionsItemList"

func setup(pathway_editor : PathwayEditor, highest_grid_time : float) -> void:
	_pathway_editor = pathway_editor
	_highest_grid_time = highest_grid_time

func _process(delta: float) -> void:
	queue_redraw()
	
	var selected_items := _actions_item_list.get_selected_items()
	
	if not selected_items.is_empty():
		_handle_selected_item(_actions_item_list.get_item_text(selected_items[0]))

func _handle_selected_item(item_text : String) -> void:
	match item_text:
		"Selecionar":
			pass
		"Comentário":
			pass
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
	pass

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
