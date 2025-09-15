extends Control

func _on_video_pressed() -> void:
	get_tree().change_scene_to_packed(Global._VIDEO_SCREEN_SCENE)

func _on_audio_pressed() -> void:
	get_tree().change_scene_to_packed(Global._AUDIO_SCREEN_SCENE)

func _on_controle_pressed() -> void:
	get_tree().change_scene_to_packed(Global._CONTROL_SCREEN_SCENE)

func _on_return_pressed() -> void:
	get_tree().change_scene_to_packed(Global._START_SCREEN_SCENE)
