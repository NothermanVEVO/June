extends MarginContainer

class_name ChooseMode

enum Paths {PLAY, EDITOR}

static var path_to_go : Paths

func _on_fall_button_pressed() -> void:
	match path_to_go:
		Paths.PLAY:
			pass
		Paths.EDITOR:
			get_tree().change_scene_to_packed(Global.EDITOR_SCREEN_SCENE)

func _on_side_button_pressed() -> void:
	match path_to_go:
		Paths.PLAY:
			pass
		Paths.EDITOR:
			get_tree().change_scene_to_packed(Global.SIDE_EDITOR_SCREEN_SCENE)

func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_packed(Global.START_SCREEN_SCENE)
