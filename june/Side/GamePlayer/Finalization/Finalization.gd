extends MarginContainer

class_name SideFinalization

enum Type {CLEAR, MAX_COMBO, PERFECT_COMBO}

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func pop(type : Type) -> void:
	match type:
		Type.CLEAR:
			animation_player.play("Clear")
		Type.MAX_COMBO:
			animation_player.play("MaxCombo")
		Type.PERFECT_COMBO:
			animation_player.play("PerfectCombo")
