extends MarginContainer

class_name Combo

@onready var combo_text: RichTextLabel = $ComboText
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func set_combo(combo : int, animate : bool = true) -> void:
	combo_text.text = "Combo " + str(combo)
	if animate:
		animation_player.play("Pop")
