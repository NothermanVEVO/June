extends FlowContainer

class_name EditorMenuBar

func _on_speed_value_changed(value: float) -> void:
	Gear.set_speed(value)
