extends Button

var _pathway_editor := PathwayEditor.new()

@onready var _mouse_time_display_panel : PanelContainer = $MouseTimeDisplay
@onready var _mouse_time_display_text : RichTextLabel = $MouseTimeDisplay/MarginContainer/RichTextLabel
const MOUSE_DISPLAY_DISTANCE : float = 10.0

var _attach_mouse_display : bool = false

@onready var _focus_effect : ReferenceRect = $"Focus Effect"

func _init() -> void: ## TEMP
	Song.set_song(load("res://Sound Test Sample/Brutal, acabou pro beta versão globo.mp3"))
	Song.BPM = 60
	Song.offset = 1.0

func _ready() -> void:
	add_child(_pathway_editor)

func _on_resized() -> void:
	_pathway_editor.global_position.y = global_position.y + (get_global_rect().size.y / 2)
	
	Path.width = Pathway.MAX_WIDTH - SideGameComponents.get_width()
	Path.hitzone = Path.BASE_HITZONE * Global.get_percentage_between(Pathway.get_distance_from_border(), Pathway.MAX_WIDTH, Path.width)

func _process(delta: float) -> void:
	queue_redraw()
	_adjust_mouse_time_display()
	#print(Path.get_time_x(Path.hitzone, Path.width, get_global_mouse_position().x, Song.get_time(), Song.get_time() + Path.WIDTH_IN_SECS))

func _get_path_width_by_zoom() -> float:
	return Path.WIDTH_IN_SECS * SideMenuBarComposer.get_zoom_value()

func _adjust_mouse_time_display() -> void:
	var pos_x : float
	var mouse_time : float
	
	if _attach_mouse_display:
		mouse_time = _get_closest_grid_time_to_mouse()
		pos_x = Path.get_pos_x(Song.get_time(), Song.get_time() + _get_path_width_by_zoom(), mouse_time, Path.hitzone, Path.width)
	else:
		pos_x = _get_limited_by_pathway_mouse_position().x
		mouse_time = Path.get_time_x(Path.hitzone, Path.width, pos_x, Song.get_time(), Song.get_time() + _get_path_width_by_zoom())
	
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

func _get_closest_grid_time_to_mouse() -> float:
	var mouse_pos : Vector2 = _get_limited_by_pathway_mouse_position()
	return _get_closest_grid_time_pos(Path.get_time_x(Path.hitzone, Path.width, get_global_mouse_position().x, Song.get_time(), Song.get_time() + Path.WIDTH_IN_SECS))

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

func _draw() -> void:
	var min_y = _pathway_editor.get_air_path_global_position().y - global_position.y - Path.HEIGHT / 2
	var max_y = _pathway_editor.get_ground_path_global_position().y - global_position.y + Path.HEIGHT / 2
	
	var value := SideMenuBarComposer.get_divisor()
	var rest := fmod(Song.get_time() - Song.offset, value)
	var start_time_pos := Song.get_time() + value - rest
	var n_grids := int(_get_path_width_by_zoom() / value)
	
	for i in (n_grids + 2):
		var time : float = start_time_pos + (value * (i - 1))
		
		if time > _get_highest_grid_time():
			return
		elif time < Song.offset - 0.01: ## HAD TO DO THIS BECAUSE OF FLOAT ERROR
			continue
		
		var pos_x = Path.get_pos_x(Song.get_time(), Song.get_time() + _get_path_width_by_zoom(), time, Path.hitzone, Path.width)
		
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
