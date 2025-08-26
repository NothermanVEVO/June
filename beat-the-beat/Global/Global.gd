extends Node

## REFERS TO THE SPEED INSIDE THE GEAR CLASS
signal speed_changed

## REFERS TO THE MAX SIZE Y IN THE GEAR CLASS
signal changed_max_size_y

var _mouse_effect : MouseEffect

func _ready() -> void:
	_mouse_effect = MouseEffect.new()
	add_child(_mouse_effect)

func set_mouse_effect(effect : MouseEffect.Effect) -> void:
	_mouse_effect.set_type(effect)

func get_percentage_between(start: float, end: float, value: float) -> float:
	if end == start:
		return 0.0
	return (value - start) / (end - start)
