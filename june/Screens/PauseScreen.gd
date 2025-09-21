extends Control

class_name PauseScreen

signal resume_pressed
signal restart_pressed
signal quit_pressed

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Escape") and Editor.editor_music_player.visible:
		_on_resume_pressed()

func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = not visible
	resume_pressed.emit()
	visible = not visible

func _on_restart_pressed() -> void:
	get_tree().paused = false
	visible = false
	restart_pressed.emit()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	visible = false
	quit_pressed.emit()

func _on_visibility_changed() -> void:
	if visible and $MarginContainer/VBoxContainer/Resume:
		get_tree().paused = true
		$MarginContainer/VBoxContainer/Resume.grab_focus()
	if is_inside_tree() and not visible:
		get_tree().paused = false
