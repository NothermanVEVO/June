extends Control

class_name PauseScreen

signal resume_pressed
signal restart_pressed
signal quit_pressed

func _on_resume_pressed() -> void:
	resume_pressed.emit()

func _on_restart_pressed() -> void:
	restart_pressed.emit()

func _on_quit_pressed() -> void:
	quit_pressed.emit()
