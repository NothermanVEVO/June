extends Node

var _current_file_path : String = ""

var current_editor_save := SideEditorResource.new()
var current_song_map := SideSongMap.new()

var _is_saved : bool = false

var is_on_editor : bool = true ## TODO WARNING NOTE THIS SHOULD BE ''FALSE''
var _last_confirmation_id : int = -1
var _last_file_dialog_id : int = -1

enum SaveBefore {LEAVE, NEW_FILE}
var _last_save_before_type

signal created_new_file
signal changed_current_song_map
signal save_changes

func _ready() -> void:
	new_file()
	
	get_tree().root.close_requested.connect(_on_close_requested)
	DialogConfirmation.confirmed.connect(_confirmation_dialog_confirmed)
	DialogConfirmation.custom_action.connect(_confirmation_dialog_canceled)
	
	get_tree().set_auto_accept_quit(false)
	
	DialogFile.file_selected.connect(_dialog_file_file_selected)

func new_file(ask_for_save : bool = false) -> void:
	if ask_for_save:
		_last_save_before_type = SaveBefore.NEW_FILE
		_last_confirmation_id = DialogConfirmation.pop_up("Cancelar", "Salvar", "Você tem modificações não salvas.", "Não salvar")
		return
	
	SideGameEditor.reset_song_vars.call_deferred()
	
	_current_file_path = ""
	current_editor_save = SideEditorResource.new()
	
	current_song_map = SideSongMap.new()
	current_song_map.difficulty = SideSongMap.Difficulty.EASY
	current_song_map.player = SideSongMap.Player.ONE
	
	Song.BPM = 60
	Song.offset = 0.0
	
	current_editor_save.song_maps.append(current_song_map)
	
	changed_current_song_map.emit()
	created_new_file.emit()

func save_file(path : String) -> Error:
	save_changes.emit()
	
	var status = ResourceSaver.save(current_editor_save, path)
	if status == OK:
		_current_file_path = path
		_is_saved = true
		DialogConfirmation.pop_up("Cancelar", "Ok", "O arquivo foi salvo com sucesso!")
	else:
		DialogConfirmation.pop_up("Cancelar", "Ok", "Erro ao salvar o arquivo. Status " + str(status))
	
	return status

func open_file(path : String) -> Error:
	var resource = ResourceLoader.load(path)
	
	if not resource or not resource is SideEditorResource:
		return FAILED
	
	current_editor_save = resource
	if current_editor_save and current_editor_save is SideEditorResource and not current_editor_save.song_maps.is_empty():
		_current_file_path = path
		_is_saved = true
		if current_editor_save.song_stream:
			Song.set_song(current_editor_save.song_stream)
		Song.BPM = current_editor_save.BPM
		Song.offset = current_editor_save.song_offset
		set_current_song_map(current_editor_save.song_maps[0])
		return OK
	return FAILED

func set_current_song_map(song_map : SideSongMap) -> void:
	current_song_map = song_map
	changed_current_song_map.emit()

func get_song_map(difficulty : int, player : int) -> SideSongMap:
	for song_map in SideEditor.current_editor_save.song_maps:
		if song_map.difficulty == difficulty and song_map.player == player:
			return song_map
	
	return null

func create_new_song_map(player : int, difficulty : int) -> SideSongMap:
	var song_map := SideSongMap.new()
	song_map.difficulty = difficulty
	song_map.player = player
	current_editor_save.song_maps.append(song_map)
	
	return song_map

func copy(from : SideSongMap, to : SideSongMap) -> void:
	to.targets.clear()
	for target in from.targets:
		to.targets.append(target.duplicate(true))

func is_saved() -> bool:
	return _is_saved

func changed_file() -> void:
	_is_saved = false

func get_file_path() -> String:
	return _current_file_path

func _on_close_requested() -> void:
	_last_save_before_type = SaveBefore.LEAVE
	_last_confirmation_id = DialogConfirmation.pop_up("Cancelar", "Salvar e sair", "Você tem modificações não salvas.", "Sair sem salvar")

func _confirmation_dialog_confirmed() -> void:
	if _last_confirmation_id == DialogConfirmation.get_last_caller():
		if _current_file_path:
			var status = save_file(_current_file_path)
			
			if _last_save_before_type == SaveBefore.LEAVE: ## TODO E SE DER ERRO E NÃO SALVAR O ARQUIVO??
				get_tree().quit()
			elif _last_save_before_type == SaveBefore.NEW_FILE:
				if status == OK:
					new_file()
		else:
			_last_file_dialog_id = DialogFile.pop_up(FileDialog.FILE_MODE_SAVE_FILE, FileDialog.ACCESS_USERDATA, Global.SIDE_EDITOR_PATH)

func _confirmation_dialog_canceled(_custom_action : StringName) -> void:
	if _last_confirmation_id == DialogConfirmation.get_last_caller():
		DialogConfirmation.remove_last_caller()
		if _last_save_before_type == SaveBefore.LEAVE:
			get_tree().quit()
		elif _last_save_before_type == SaveBefore.NEW_FILE:
			new_file()

func _dialog_file_file_selected(path: String) -> void:
	if DialogFile.get_last_caller() != _last_file_dialog_id:
		return
	
	DialogFile.remove_last_caller()
	
	var status = save_file(path)
	
	if status == OK:
		get_tree().quit()
