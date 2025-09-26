extends Node2D

class_name HitEffect

enum Type {MAXIMUM, NON}

var _current_type : Type = Type.MAXIMUM

@onready var explosion : CPUParticles2D = $Explosion
@onready var star : CPUParticles2D = $Star

const MAXIMUM_COLOR := Color(1, 4, 4, 1)
const MAXIMUM_COLOR_RAMP : Gradient = preload("res://Effects/Hit/Maximum.tres")

const NON_COLOR := Color(0.1, 0.55, 3, 1)
const NON_COLOR_RAMP : Gradient = preload("res://Effects/Hit/Non.tres")

func play_effect(type : Type) -> void:
	if not Global.get_settings_dictionary()["particles"]:
		return
	
	if type != _current_type:
		if type == Type.MAXIMUM:
			explosion.amount = 100
			explosion.color = MAXIMUM_COLOR
			explosion.color_ramp = MAXIMUM_COLOR_RAMP
			star.color = MAXIMUM_COLOR
			star.angular_velocity_min = -180
			star.angular_velocity_max = -180
		else:
			explosion.amount = 50
			explosion.color = NON_COLOR
			explosion.color_ramp = NON_COLOR_RAMP
			star.color = NON_COLOR
			star.angular_velocity_min = -90
			star.angular_velocity_max = -90
	
	_current_type = type
	
	explosion.restart()
	star.restart()
	explosion.emitting = true
	star.emitting = true

static func calculate_type_in_precision(precision : int) -> Type:
	if precision == 100:
		return Type.MAXIMUM
	else:
		return Type.NON

func load_gear(loading_screen : LoadingScreen) -> int:
	explosion.amount = 100
	explosion.color = MAXIMUM_COLOR
	explosion.color_ramp = MAXIMUM_COLOR_RAMP
	star.color = MAXIMUM_COLOR
	star.angular_velocity_min = -180
	star.angular_velocity_max = -180
	
	explosion.emitting = true
	star.emitting = true
	
	explosion.finished.connect(loading_screen.loaded)
	star.finished.connect(loading_screen.loaded)
	
	return 2
