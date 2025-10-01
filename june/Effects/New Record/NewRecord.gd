extends MarginContainer

class_name NewRecord

@onready var _animation : AnimationPlayer = $AnimationPlayer

enum Records {NONE, SCORE, COMBO, BOTH}

func pop_animation() -> void:
	_animation.play("POP")
