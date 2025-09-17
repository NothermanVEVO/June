extends Node2D

class_name HitEffect

enum Type {MAXIMUM, NON}

@onready var explosion : CPUParticles2D = $Explosion
@onready var star : CPUParticles2D = $Star

func play_effect(type : Type) -> void:
	if not Global.get_settings_dictionary()["particles"]:
		return
	explosion.restart()
	star.restart()
	explosion.emitting = true
	explosion.emitting = true
