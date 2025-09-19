extends Control

func _ready() -> void:
	Global.set_window_title(Global.TitleType.BASE)
	$VBoxContainer/Play.grab_focus()

func _on_play_pressed() -> void:
	pass

func _on_editor_pressed() -> void:
	get_tree().change_scene_to_packed(Global._EDITOR_SCREEN_SCENE)

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_packed(Global._SETTING_SCREEN_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()
