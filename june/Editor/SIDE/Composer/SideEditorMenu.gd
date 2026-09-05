extends MenuBar

class_name SideEditorMenu

@onready var file : PopupMenu = $File
@onready var file_dialog : FileDialog = $FileDialog

enum FileType {SAVE, EXPORT, OPEN}
var _last_file_type : FileType

func _open_file(path : String) -> Error:
	return FAILED

func _on_file_id_pressed(id: int) -> void:
	match file.get_item_text(id):
		"Novo":
			SideEditor.new_file()
		"Abrir":
			_last_file_type = FileType.OPEN
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			file_dialog.popup_file_dialog()
		"Salvar":
			_last_file_type = FileType.SAVE
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			file_dialog.popup_file_dialog()
		"Exportar":
			_last_file_type = FileType.EXPORT
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			file_dialog.popup_file_dialog()
		"Abrir Pasta":
			OS.shell_open(ProjectSettings.globalize_path(Global.SIDE_EDITOR_PATH))

func _on_file_dialog_file_selected(path: String) -> void:
	match _last_file_type:
		FileType.SAVE:
			SideEditor.save_file(path)
			pass
		FileType.EXPORT:
			pass
		FileType.OPEN:
			pass

func _on_player_type_item_selected(index: int) -> void:
	var existed_song_map : SideSongMap = SideEditor.get_song_map(SideEditor.current_song_map.difficulty, index)
	
	if existed_song_map:
		SideEditor.set_current_song_map(existed_song_map)
	else:
		var song_map := SideSongMap.new()
		song_map.difficulty = SideEditor.current_song_map.difficulty
		song_map.player = index
		SideEditor.current_editor_save.song_maps.append(song_map)
		SideEditor.set_current_song_map(song_map)

func _on_difficulty_item_selected(index: int) -> void:
	var existed_song_map : SideSongMap = SideEditor.get_song_map(index, SideEditor.current_song_map.player)
	
	if existed_song_map:
		SideEditor.set_current_song_map(existed_song_map)
	else:
		var song_map := SideSongMap.new()
		song_map.difficulty = index
		song_map.player = SideEditor.current_song_map.player
		SideEditor.current_editor_save.song_maps.append(song_map)
		SideEditor.set_current_song_map(song_map)
