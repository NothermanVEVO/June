extends Control

class_name GearSkin

@onready var precision_container : VBoxContainer = $Precision
@onready var precision_speed_text : RichTextLabel = $Precision/Speed
@onready var precision_percentage_text : RichTextLabel = $Precision/MarginContainer/Percentage

@onready var animation_player : AnimationPlayer = $Animations

@onready var score_text : RichTextLabel = $MarginContainer/VBoxContainer/Score
@onready var speed_text : RichTextLabel = $MarginContainer/VBoxContainer/MarginContainer/Speed

func pop_precision(precision : int) -> void:
	precision_container.visible = true
	
	var value : int = sign(precision)
	precision = abs(precision)
	
	if precision == 100:
		precision_speed_text.visible = false
		precision_percentage_text.text = str(precision) + "% MAX"
	elif precision > 0 and precision < 100:
		precision_speed_text.visible = true
		if value > 0:
			precision_speed_text.text = "Fast"
		else:
			precision_speed_text.text = "Slow"
		precision_percentage_text.text = str(precision) + "% MAX"
	elif precision == 0:
		precision_speed_text.visible = false
		precision_percentage_text.text = "BREAK"
	if animation_player.is_playing():
		animation_player.play("RESET")
	animation_player.play("Pop Up Precision")

func set_score(score : int) -> void:
	score_text.text = "Score: " + str(score)

func set_speed(speed : float) -> void:
	speed_text.text = "Speed: " + str(speed) + "x"
