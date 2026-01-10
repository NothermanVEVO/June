extends Button

var _pathway_editor := PathwayEditor.new()

@onready var _mouse_time_display_panel : PanelContainer = $MouseTimeDisplay
@onready var _mouse_time_display_text : RichTextLabel = $MouseTimeDisplay/MarginContainer/RichTextLabel
const MOUSE_DISPLAY_DISTANCE : float = 10.0

var _attach_mouse_display : bool = false

@onready var _focus_effect : ReferenceRect = $"Focus Effect"

var _sample_target := Sprite2D.new()

func _init() -> void: ## TEMP
	Song.set_song(load("res://Sound Test Sample/Brutal, acabou pro beta versão globo.mp3"))
	Song.BPM = 60
	Song.offset = 1.0

func _ready() -> void:
	add_child(_pathway_editor)
	
	_sample_target.global_position = Vector2(INF, INF)
	_sample_target.modulate.a = 0.5
	
	add_child(_sample_target)

func _on_resized() -> void:
	_pathway_editor.global_position.y = global_position.y + (get_global_rect().size.y / 2)
	
	Path.width = Pathway.MAX_WIDTH - SideGameComponents.get_width()
	Path.hitzone = Path.BASE_HITZONE * Global.get_percentage_between(Pathway.get_distance_from_border(), Pathway.MAX_WIDTH, Path.width)

func _process(delta: float) -> void:
	queue_redraw()
	
	_attach_mouse_display = false
	
	var selected_in_text : String = SideGameComponents.get_selected_in_text()
	if selected_in_text:
		_pathway_editor.set_speed(SideMenuBarComposer.get_zoom_value())
		_process_selected_game_component(selected_in_text)
	
	_adjust_mouse_time_display()
	
	#print(Path.get_time_x(Path.hitzone, Path.width, get_global_mouse_position().x, Song.get_time(), Song.get_time() + Path.WIDTH_IN_SECS))

func _process_selected_game_component(game_component : String) -> void:
	_sample_target.visible = false
	
	match game_component:
		"Leve 1", "Leve 2", "Leve 3":
			_process_light_items(game_component)
		"Médio 1", "Médio 2":
			_process_medium_items(game_component)
		"Pesado":
			pass
		"Dupla":
			pass
		"Shield", "Fortified":
			pass
		"Hammer":
			pass
		"Hold":
			pass
		"Trap":
			pass
		"Machado":
			pass
		"Nota 1", "Nota 2":
			pass
		"Coração":
			pass

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
		_pathway_editor.add_target_at(get_path_type_at_mouse(), LightTap.new(_get_closest_grid_time_to_mouse(), get_path_type_at_mouse(), light_variant))

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
		_pathway_editor.add_target_at(get_path_type_at_mouse(), MediumTap.new(_get_closest_grid_time_to_mouse(), get_path_type_at_mouse(), medium_variant))

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
	var path_type_at_mouse : Path.Types = get_path_type_at_mouse()
	
	if path_type_at_mouse == Path.Types.AIR:
		mouse_pos.y = _pathway_editor.get_air_path_global_position().y
	else: ## GROUND
		mouse_pos.y = _pathway_editor.get_ground_path_global_position().y
	
	mouse_pos.x = _get_closest_grid_time_to_mouse_in_x()
	
	return mouse_pos

func get_path_type_at_mouse() -> Path.Types:
	if (_pathway_editor.get_air_path_global_position().distance_squared_to(get_global_mouse_position()) < 
		_pathway_editor.get_ground_path_global_position().distance_squared_to(get_global_mouse_position())):
		
		return Path.Types.AIR
	else:
		return Path.Types.GROUND

func _get_closest_grid_time_to_mouse_in_x() -> float:
	var time : float = clampf(_get_closest_grid_time_to_mouse(), 0, _get_highest_grid_time())
	return Path.get_pos_x(Song.get_time(), Song.get_time() + _pathway_editor.WIDTH_IN_SECS_BY_SPEED(),time, Path.hitzone, Path.width)

func _get_closest_grid_time_to_mouse() -> float:
	var mouse_pos : Vector2 = _get_limited_by_pathway_mouse_position()
	return _get_closest_grid_time_pos(Path.get_time_x(Path.hitzone, Path.width, get_global_mouse_position().x, Song.get_time(), Song.get_time() + _pathway_editor.WIDTH_IN_SECS_BY_SPEED()))

func _get_highest_grid_time() -> float:
	var time : float = _get_closest_grid_time_pos(Song.get_duration())
	if time > Song.get_duration():
		return time - SideMenuBarComposer.get_divisor()
	return time

func _get_closest_grid_time_pos(time_pos : float) -> float:
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
		
		if time > _get_highest_grid_time():
			return
		elif time < Song.offset - 0.01: ## HAD TO DO THIS BECAUSE OF FLOAT ERROR
			continue
		
		var pos_x = Path.get_pos_x(Song.get_time(), Song.get_time() + _pathway_editor.WIDTH_IN_SECS_BY_SPEED(), time, Path.hitzone, Path.width)
		
		var is_start_line : bool = is_equal_approx(time, Song.offset)
		if not is_start_line:
			var is_end_line : bool = is_equal_approx(_get_highest_grid_time(), time)
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
