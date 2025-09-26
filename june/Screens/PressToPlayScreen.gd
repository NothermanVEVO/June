extends Control

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		get_tree().change_scene_to_packed(Global.START_SCREEN_SCENE)

func _unhandled_input(event: InputEvent) -> void:
	get_tree().change_scene_to_packed(Global.START_SCREEN_SCENE)
