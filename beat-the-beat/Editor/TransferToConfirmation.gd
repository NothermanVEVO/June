extends PanelContainer

class_name TransferToConfirmation

enum Choices{REPLACE = 0, CHANGE = 1, CANCEL = 2}

var difficulty_left : String = ""
var difficulty_right : String = ""

signal choice_made(choice : Choices)

func _ready() -> void:
	_center()

func set_text(difficulty_left : String, difficulty_right : String) -> void:
	self.difficulty_left = difficulty_left
	self.difficulty_right = difficulty_right
	$MarginContainer/VBoxContainer/Difficulties.text = difficulty_left + " -> " + difficulty_right
	_center()

func _center() -> void:
	global_position = get_viewport_rect().size / 2 - size / 2

func _on_replace_pressed() -> void:
	choice_made.emit(Choices.REPLACE)

func _on_change_pressed() -> void:
	choice_made.emit(Choices.CHANGE)

func _on_cancel_pressed() -> void:
	choice_made.emit(Choices.CANCEL)
