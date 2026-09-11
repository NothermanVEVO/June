extends MenuBar

class_name SideEditorMenu

@onready var file : PopupMenu = $File
@onready var edit: PopupMenu = $Edit
@onready var file_dialog : FileDialog = $FileDialog

@onready var player_type: OptionButton = $"../Middle/PlayerType"
@onready var difficulty: OptionButton = $"../Middle/Difficulty"
@onready var stars_spin_box: SpinBox = $"../Middle/StarsSpinBox"

@onready var copy_song_map_window: Window = $"../../CopySongMapWindow"

@onready var _editor_settings_scene : PackedScene = load("res://Editor/SIDE/Settings/SideEditorSettings.tscn")

enum FileType {SAVE, EXPORT, OPEN}
var _last_file_type : FileType

func _ready() -> void:
	_adjust_mid_bar()
	
	SideEditor.created_new_file.connect(_side_editor_created_new_file)

func _adjust_mid_bar() -> void:
	var song_map : SideSongMap = SideEditor.current_song_map
	if song_map:
		player_type.select(song_map.player)
		difficulty.select(song_map.difficulty)
		stars_spin_box.value = song_map.stars

func _open_file(path : String) -> Error:
	return FAILED

func _on_file_id_pressed(id: int) -> void:
	match file.get_item_text(id):
		"Novo":
			SideEditor.new_file(true)
			player_type.select(0)
			difficulty.select(0)
			stars_spin_box.value = 1
		"Abrir":
			_last_file_type = FileType.OPEN
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			file_dialog.popup_file_dialog()
		"Salvar":
			if SideEditor.get_file_path():
				SideEditor.save_file(SideEditor.get_file_path())
				return
			
			_last_file_type = FileType.SAVE
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			file_dialog.popup_file_dialog()
		#"Exportar":
			#_last_file_type = FileType.EXPORT
			#file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			#file_dialog.popup_file_dialog()
		"Abrir Pasta":
			OS.shell_open(ProjectSettings.globalize_path(Global.SIDE_EDITOR_PATH))

func _on_file_dialog_file_selected(path: String) -> void:
	match _last_file_type:
		FileType.SAVE:
			SideEditor.save_file(path)
		FileType.EXPORT:
			pass
		FileType.OPEN:
			SideEditor.open_file(path)
			_adjust_mid_bar()

func _on_player_type_item_selected(index: int) -> void:
	var existed_song_map : SideSongMap = SideEditor.get_song_map(SideEditor.current_song_map.difficulty, index)
	
	if existed_song_map:
		SideEditor.set_current_song_map(existed_song_map)
	else:
		var song_map := SideEditor.create_new_song_map(index, SideEditor.current_song_map.difficulty)
		SideEditor.set_current_song_map(song_map)
	
	stars_spin_box.value = SideEditor.current_song_map.stars

func _on_difficulty_item_selected(index: int) -> void:
	var existed_song_map : SideSongMap = SideEditor.get_song_map(index, SideEditor.current_song_map.player)
	
	if existed_song_map:
		SideEditor.set_current_song_map(existed_song_map)
	else:
		var song_map := SideEditor.create_new_song_map(SideEditor.current_song_map.player, index)
		SideEditor.set_current_song_map(song_map)
	
	stars_spin_box.value = SideEditor.current_song_map.stars

func _on_settings_pressed() -> void:
	SideEditor.save_changes.emit()
	get_tree().change_scene_to_packed(_editor_settings_scene)

func _on_stars_spin_box_value_changed(value: float) -> void:
	if SideEditor.current_song_map:
		SideEditor.current_song_map.stars = int(value)

func _side_editor_created_new_file() -> void:
	get_tree().change_scene_to_packed(_editor_settings_scene)

func _on_edit_id_pressed(id: int) -> void:
	match edit.get_item_text(id):
		"Copiar para":
			SideEditor.save_changes.emit()
			copy_song_map_window.popup_centered()
