extends Control

func _ready() -> void:
	Editor.is_on_editor = true
	Editor.editor_settings = $Settings
	Editor.editor_composer = $"Editor Composer"
