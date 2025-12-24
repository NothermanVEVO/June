extends VBoxContainer

class_name EditorComposer

static var editor_menu_bar : EditorMenuBar

static var song_time_pos : float = 0.0

func _ready() -> void:
	editor_menu_bar = $MenuBar
