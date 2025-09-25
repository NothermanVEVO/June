extends Control

class_name SettingsScreen

static var SCENE_CALLER : PackedScene

func _ready() -> void:
	$VBoxContainer/Game.grab_focus()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Escape"):
		_on_return_pressed()

func _on_game_pressed() -> void:
	get_tree().change_scene_to_packed(Global.GAME_SETTING_SCREEN_SCENE)

func _on_video_pressed() -> void:
	get_tree().change_scene_to_packed(Global.VIDEO_SCREEN_SCENE)

func _on_audio_pressed() -> void:
	get_tree().change_scene_to_packed(Global.AUDIO_SCREEN_SCENE)

func _on_controle_pressed() -> void:
	get_tree().change_scene_to_packed(Global.CONTROL_SCREEN_SCENE)

func _on_return_pressed() -> void:
	get_tree().change_scene_to_packed(SCENE_CALLER)
