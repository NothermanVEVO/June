extends Node2D

class_name MouseEffect

enum Effect{NONE, POWER_ITEM}

var _effect : Effect = Effect.NONE

const mouse_trail_effect_scene := preload("res://Effects/MouseTrailEffect.tscn")
var _mouse_trail_effect : CPUParticles2D

const mouse_click_effect_scene := preload("res://Effects/MouseClickEffect.tscn")
var _mouse_click_effect : CPUParticles2D

const mouse_power_effect_color_ramp := preload("res://Effects/PowerColorRamp.tres")

var _last_global_mouse_position : Vector2

func _ready() -> void:
	_mouse_trail_effect = mouse_trail_effect_scene.instantiate()
	_mouse_click_effect = mouse_click_effect_scene.instantiate()
	z_index = 10

func set_type(effect : Effect) -> void:
	_effect = effect
	match _effect:
		Effect.POWER_ITEM:
			_mouse_click_effect.color_ramp = mouse_power_effect_color_ramp
			_mouse_trail_effect.color_ramp = mouse_power_effect_color_ramp
	_last_global_mouse_position = get_global_mouse_position()

func _process(_delta: float) -> void:
	if _effect == Effect.NONE:
		return
		
	if get_global_mouse_position() != _last_global_mouse_position:
		var effect : CPUParticles2D = _mouse_trail_effect.duplicate()
		effect.global_position = get_global_mouse_position()
		effect.direction = _last_global_mouse_position.direction_to(get_global_mouse_position())
		add_child(effect)
		effect.emitting = true
		effect.finished.connect(effect.queue_free)
	_last_global_mouse_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("Add Item"):
		var effect : CPUParticles2D = _mouse_click_effect.duplicate()
		effect.global_position = get_global_mouse_position()
		add_child(effect)
		effect.emitting = true
		effect.finished.connect(effect.queue_free)
