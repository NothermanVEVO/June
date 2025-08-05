extends Node2D

class_name MusicPlayer

var _gear : Gear

func _ready() -> void:
	# TEMP ===========
	_gear = Gear.new(Gear.Type.SIX_KEYS)
	add_child(_gear)
	# TEMP ===========

func _physics_process(delta: float) -> void:
	#if Input.is_action_just_pressed("ui_accept"):
		#_gear.add_note_at(0)
	pass

func _draw() -> void:
	draw_circle(get_viewport_rect().size / 2, 5, Color.BLACK)
