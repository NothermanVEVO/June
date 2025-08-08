extends PanelContainer

class_name NoteInfo

@onready var _start_time := $"InfoVBox/Start Time"
@onready var _end_time := $"InfoVBox/End Time"
@onready var _sfx := $InfoVBox/SFX
@onready var _locked := $InfoVBox/Locked
@onready var _power := $InfoVBox/Power

enum Type{TAP, HOLD}

func set_type(type : Type) -> void:
	match type:
		Type.TAP:
			_end_time.visible = false
		Type.HOLD:
			_end_time.visible = true

func set_start_time(start_time : String) -> void:
	pass

func set_end_time(end_time : String) -> void:
	pass

func _on_start_time_text_changed() -> void:
	pass # Replace with function body.

func _on_end_time_text_changed() -> void:
	pass # Replace with function body.

func _on_locked_pressed() -> void:
	pass # Replace with function body.

func _on_power_pressed() -> void:
	pass # Replace with function body.
