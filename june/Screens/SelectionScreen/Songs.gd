extends MarginContainer

class_name SongsSelection

const _SONG_BUTTON_SCENE = preload("res://Screens/SelectionScreen/SongButton/SongButton.tscn")

@onready var _songs_container : VBoxContainer = $HBoxContainer/Songs/ScrollContainer/SongsContainer

var _song_resources : Array[SongResource] = []
var _song_buttons : Array[SongButton] = []

@onready var video_stream_player : VideoStreamPlayer = $"../../VideoStreamPlayer"

@onready var quit_button : Button = $"../MarginContainer/Quit"
@onready var selected_song_container : TabContainer = $HBoxContainer/MarginContainer/SelectedSong

@onready var four_buttons : TabButton = $"HBoxContainer/MarginContainer/SelectedSong/4 Botões"
@onready var five_buttons : TabButton = $"HBoxContainer/MarginContainer/SelectedSong/5 Botões"
@onready var six_buttons : TabButton = $"HBoxContainer/MarginContainer/SelectedSong/6 Botões"

var tab_bar_selection : TabBar

var _currently_selected_gear_type : Gear.Type = Gear.Type.FOUR_KEYS

var _last_song_button : SongButton

enum Buttons {FOUR, FIVE, SIX}

var _currently_playing_uuid : String = ""

var _request_background_id : int = 0

func _ready() -> void:
	Song.finished.connect(_on_song_finished)
	Song.pitch_scale = 1.0
	
	for child in selected_song_container.get_children(true):
		if not child is TabButton and child is TabBar:
			tab_bar_selection = child
			break
	
	four_buttons.load_difficulty_save.connect(_load_difficulty_save)
	four_buttons.play_difficulty.connect(_play_difficulty)
	four_buttons.settings_pressed.connect(_settings_pressed)
	
	five_buttons.load_difficulty_save.connect(_load_difficulty_save)
	five_buttons.play_difficulty.connect(_play_difficulty)
	five_buttons.settings_pressed.connect(_settings_pressed)
	
	six_buttons.load_difficulty_save.connect(_load_difficulty_save)
	six_buttons.play_difficulty.connect(_play_difficulty)
	six_buttons.settings_pressed.connect(_settings_pressed)
	
	four_buttons.facil.focus_neighbor_top = tab_bar_selection.get_path()
	four_buttons.normal.focus_neighbor_top = tab_bar_selection.get_path()
	four_buttons.hard.focus_neighbor_top = tab_bar_selection.get_path()
	four_buttons.maximus.focus_neighbor_top = tab_bar_selection.get_path()
	four_buttons.settings.focus_neighbor_bottom = quit_button.get_path()
	
	five_buttons.facil.focus_neighbor_top = tab_bar_selection.get_path()
	five_buttons.normal.focus_neighbor_top = tab_bar_selection.get_path()
	five_buttons.hard.focus_neighbor_top = tab_bar_selection.get_path()
	five_buttons.maximus.focus_neighbor_top = tab_bar_selection.get_path()
	five_buttons.settings.focus_neighbor_bottom = quit_button.get_path()
	
	six_buttons.facil.focus_neighbor_top = tab_bar_selection.get_path()
	six_buttons.normal.focus_neighbor_top = tab_bar_selection.get_path()
	six_buttons.hard.focus_neighbor_top = tab_bar_selection.get_path()
	six_buttons.maximus.focus_neighbor_top = tab_bar_selection.get_path()
	six_buttons.settings.focus_neighbor_bottom = quit_button.get_path()
	
	var song_resource_paths := _check_folder(Global.SONGS_PATH)
	for path in song_resource_paths:
		var file := FileAccess.open(path, FileAccess.READ)
		var content := file.get_as_text()
		file.close()
		
		var json := JSON.new()
		var result = json.parse(content)
		if result == OK:
			var json_data = json.get_data()
			var validate_wrong = SongResource.validate_dictionary(json_data)
			if validate_wrong:
				DialogConfirmation.pop_up("Cancelar", "Ok", "O Song Map está inválido: " + path + "\nErro: " + validate_wrong)
				continue
			else:
				_song_resources.append(SongResource.dictionary_to_resource(json_data))
		else:
			DialogConfirmation.pop_up("Cancelar", "Ok", "Erro de parse do Song Map: " + path)
	
	for song_resource in _song_resources:
		var song_button : SongButton = _SONG_BUTTON_SCENE.instantiate()
		var image_texture : ImageTexture = null
		if song_resource.icon and FileAccess.file_exists(song_resource.icon):
			var icon := Image.load_from_file(song_resource.icon)
			image_texture = ImageTexture.create_from_image(icon)
		
		song_button.setup(song_resource.ID, image_texture, song_resource.name, song_resource.author)
		song_button.on_focus_entered.connect(_song_button_on_focus_entered)
		_song_buttons.append(song_button)
		_songs_container.add_child(song_button)
		
	if not _song_buttons.is_empty():
		_song_buttons[0].grab_focus()
	
	_song_buttons[0].focus_neighbor_top = _song_buttons[_song_buttons.size() - 1].get_path()
	_song_buttons[_song_buttons.size() - 1].focus_neighbor_bottom = _song_buttons[0].get_path()
	
	if Game.has_selection_state_saved():
		Game.load_selection_state_saved(self)

func _on_song_finished() -> void:
	if is_inside_tree():
		Song.play()

func load_state(UUID : String, tab_selected : int, difficulty : SongMap.Difficulty) -> void:
	selected_song_container.current_tab = tab_selected
	for song_button in _song_buttons:
		if song_button.UUID == UUID:
			song_button.grab_focus()
			if tab_selected == 0: ## FOUR BUTTONS
				four_buttons.set_difficulty_selected(difficulty)
			elif tab_selected == 1: ## FIVE BUTTONS
				five_buttons.set_difficulty_selected(difficulty)
			elif tab_selected == 2: ## SIX BUTTONS
				six_buttons.set_difficulty_selected(difficulty)
			break

func _song_button_on_focus_entered(song_button : SongButton) -> void:
	if _last_song_button == song_button:
		return
	
	if _last_song_button:
		_last_song_button.button_pressed = not _last_song_button.button_pressed
	song_button.button_pressed = true
	_last_song_button = song_button
	
	if not song_button.button_down.is_connected(_song_button_down):
		song_button.button_down.connect(_song_button_down)
	
	four_buttons.facil.focus_neighbor_left = song_button.get_path()
	four_buttons.maximus.focus_neighbor_right = song_button.get_path()
	four_buttons.settings.focus_neighbor_right = song_button.get_path()
	
	five_buttons.facil.focus_neighbor_left = song_button.get_path()
	five_buttons.maximus.focus_neighbor_right = song_button.get_path()
	five_buttons.settings.focus_neighbor_right = song_button.get_path()
	
	six_buttons.facil.focus_neighbor_left = song_button.get_path()
	six_buttons.maximus.focus_neighbor_right = song_button.get_path()
	six_buttons.settings.focus_neighbor_right = song_button.get_path()
	
	six_buttons.focus_neighbor_right = song_button.get_path()
	
	tab_bar_selection.focus_neighbor_right = song_button.get_path()
	
	for song_resource in _song_resources:
		if song_resource.ID == song_button.UUID:
			four_buttons.set_song_resource(song_resource)
			five_buttons.set_song_resource(song_resource)
			six_buttons.set_song_resource(song_resource)
			break
	
	if selected_song_container.current_tab == 0: ## 4 BUTTONS
		var difficulty := four_buttons.get_default_difficulty()
		song_button.focus_neighbor_left = four_buttons.get_difficulty_button(difficulty).get_path()
		song_button.focus_neighbor_right = four_buttons.get_difficulty_button(difficulty).get_path()
		_load_difficulty_save(difficulty)
	elif selected_song_container.current_tab == 1: ## 5 BUTTONS
		var difficulty := five_buttons.get_default_difficulty()
		song_button.focus_neighbor_left = five_buttons.get_difficulty_button(difficulty).get_path()
		song_button.focus_neighbor_right = five_buttons.get_difficulty_button(difficulty).get_path()
		_load_difficulty_save(difficulty)
	elif selected_song_container.current_tab == 2: ## 6 BUTTONS
		var difficulty := six_buttons.get_default_difficulty()
		song_button.focus_neighbor_left = six_buttons.get_difficulty_button(difficulty).get_path()
		song_button.focus_neighbor_right = six_buttons.get_difficulty_button(difficulty).get_path()
		_load_difficulty_save(difficulty)
	
	_request_background_id += 1
	var id := _request_background_id 
	
	await get_tree().create_timer(1).timeout
	
	if not is_inside_tree():
		return
	
	if _currently_playing_uuid == song_button.UUID or id != _request_background_id:
		return
	
	for song_resource in _song_resources:
		if song_resource.ID == song_button.UUID:
			if Global.get_settings_dictionary()["video"]:
				video_stream_player.stream = Loader.load_video_stream(song_resource.video)
				video_stream_player.play()
			Song.stream = Loader.load_music_stream(song_resource.song)
			Song.play()
			_currently_playing_uuid = song_resource.ID

func _song_button_down() -> void:
	if _last_song_button.button_pressed:
		_last_song_button.button_pressed = false
	pass

func _check_folder(path: String) -> Array[String]:
	var paths : Array[String] = []
	var dir := DirAccess.open(path)
	if dir == null:
		print("Não foi possível abrir a pasta: ", path)
		return paths
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with("."):
			# ignora "." e ".."
			file_name = dir.get_next()
			continue
		
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir():
			#print("📂 Pasta encontrada:", full_path)
			# Recursivamente checa dentro da pasta
			for recursive_path in _check_folder(full_path):
				paths.append(recursive_path)
		else:
			#print("📄 Arquivo encontrado:", full_path)
			if full_path.get_file() == "song_map.json":
				paths.append(full_path)
				#print("✅ Arquivo válido:", full_path)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return paths

func _load_difficulty_save(difficulty : SongMap.Difficulty) -> void:
	var save := Global.get_save()
	
	if not save.has(_last_song_button.UUID):
		save[_last_song_button.UUID] = Global.save_sample()
		Global.create_save(save)
	
	var difficulty_str : String = str(SongMap.Difficulty.keys()[difficulty])
	if selected_song_container.current_tab == 0: ## 4 BUTTONS
		four_buttons.score.text = "Pontuação: " + Global.formate_int_to_pontuation(save[_last_song_button.UUID]["4 buttons"][difficulty_str]["score"])
		four_buttons.combo.text = "Combo: " + Global.formate_int_to_pontuation(save[_last_song_button.UUID]["4 buttons"][difficulty_str]["combo"])
		_last_song_button.focus_neighbor_left = four_buttons.get_difficulty_button(difficulty).get_path()
		_last_song_button.focus_neighbor_right = four_buttons.get_difficulty_button(difficulty).get_path()
	elif selected_song_container.current_tab == 1: ## 5 BUTTONS
		five_buttons.score.text = "Pontuação: " + Global.formate_int_to_pontuation(save[_last_song_button.UUID]["5 buttons"][difficulty_str]["score"])
		five_buttons.combo.text = "Combo: " + Global.formate_int_to_pontuation(save[_last_song_button.UUID]["5 buttons"][difficulty_str]["combo"])
		_last_song_button.focus_neighbor_left = five_buttons.get_difficulty_button(difficulty).get_path()
		_last_song_button.focus_neighbor_right = five_buttons.get_difficulty_button(difficulty).get_path()
	elif selected_song_container.current_tab == 2: ## 6 BUTTONS
		six_buttons.score.text = "Pontuação: " + Global.formate_int_to_pontuation(save[_last_song_button.UUID]["6 buttons"][difficulty_str]["score"])
		six_buttons.combo.text = "Combo: " + Global.formate_int_to_pontuation(save[_last_song_button.UUID]["6 buttons"][difficulty_str]["combo"])
		_last_song_button.focus_neighbor_left = six_buttons.get_difficulty_button(difficulty).get_path()
		_last_song_button.focus_neighbor_right = six_buttons.get_difficulty_button(difficulty).get_path()

func _play_difficulty(difficulty : SongMap.Difficulty) -> void:
	for song_resource in _song_resources:
		if song_resource.ID == _last_song_button.UUID:
			for song_map in song_resource.song_maps:
				if song_map.gear_type == _currently_selected_gear_type and song_map.difficulty == difficulty:
					Game.save_selection_state(_last_song_button.UUID, selected_song_container.current_tab, song_map.difficulty)
					
					Game.change_to_music_player(song_map.gear_type, song_map, Loader.load_music_stream(song_resource.song), 
						Loader.load_video_stream(song_resource.video), Loader.load_image(song_resource.image))
					break

func _on_selected_song_tab_changed(_tab: int) -> void:
	if selected_song_container.current_tab == 0: ## 4 BUTTONS
		_currently_selected_gear_type = Gear.Type.FOUR_KEYS
		var difficulty := four_buttons.get_default_difficulty()
		if four_buttons.has_difficulty():
			_load_difficulty_save(difficulty)
		_last_song_button.focus_neighbor_left = four_buttons.get_difficulty_button(difficulty).get_path()
		_last_song_button.focus_neighbor_right = four_buttons.get_difficulty_button(difficulty).get_path()
	elif selected_song_container.current_tab == 1: ## 5 BUTTONS
		_currently_selected_gear_type = Gear.Type.FIVE_KEYS
		var difficulty := five_buttons.get_default_difficulty()
		if five_buttons.has_difficulty():
			_load_difficulty_save(difficulty)
		_last_song_button.focus_neighbor_left = five_buttons.get_difficulty_button(difficulty).get_path()
		_last_song_button.focus_neighbor_right = five_buttons.get_difficulty_button(difficulty).get_path()
	elif selected_song_container.current_tab == 2: ## 6 BUTTONS
		_currently_selected_gear_type = Gear.Type.SIX_KEYS
		var difficulty := six_buttons.get_default_difficulty()
		if six_buttons.has_difficulty():
			_load_difficulty_save(difficulty)
		_last_song_button.focus_neighbor_left = six_buttons.get_difficulty_button(difficulty).get_path()
		_last_song_button.focus_neighbor_right = six_buttons.get_difficulty_button(difficulty).get_path()

func _settings_pressed() -> void:
	var difficulty : SongMap.Difficulty
	
	if selected_song_container.current_tab == 0: ## 4 BUTTONS
		difficulty = four_buttons.get_difficulty_selected()
	elif selected_song_container.current_tab == 1: ## 5 BUTTONS
		_currently_selected_gear_type = Gear.Type.FIVE_KEYS
		difficulty = five_buttons.get_difficulty_selected()
	elif selected_song_container.current_tab == 2: ## 6 BUTTONS
		difficulty = six_buttons.get_difficulty_selected()
	
	for song_resource in _song_resources:
		if song_resource.ID == _last_song_button.UUID:
			for song_map in song_resource.song_maps:
				if song_map.gear_type == _currently_selected_gear_type and song_map.difficulty == difficulty:
					Game.save_selection_state(_last_song_button.UUID, selected_song_container.current_tab, song_map.difficulty)
	SettingsScreen.SCENE_CALLER = Global.SELECTION_SCREEN_SCENE
	get_tree().change_scene_to_packed(Global.SETTING_SCREEN_SCENE)

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_packed(Global.START_SCREEN_SCENE)
