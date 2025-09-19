extends Control

class_name GearSkin

@onready var precision_container : VBoxContainer = $Precision
@onready var precision_speed_text : RichTextLabel = $Precision/Speed
@onready var precision_percentage_text : RichTextLabel = $Precision/MarginContainer/Percentage

@onready var text_animation : AnimationPlayer = $TextAnimation
@onready var beat_animation : AnimationPlayer = $BeatAnimation

@onready var score_text : RichTextLabel = $MarginContainer/VBoxContainer/Score
@onready var speed_text : RichTextLabel = $MarginContainer/VBoxContainer/MarginContainer/Speed

@onready var fever_bar : TextureProgressBar = $Gear/Control/FeverBar
@onready var star : NinePatchRect = $Gear/Control/Star

const _FIRST_FEVER_TEXTURE := preload("res://assets/Gear/JuneV1/base_estrela_1x.png")
const _SECOND_FEVER_TEXTURE := preload("res://assets/Gear/JuneV1/base_estrela_2x.png")
const _THIRD_FEVER_TEXTURE := preload("res://assets/Gear/JuneV1/base_estrela_3x.png")
const _FOURTH_FEVER_TEXTURE := preload("res://assets/Gear/JuneV1/base_estrela_4x.png")
const _FIFTH_FEVER_TEXTURE := preload("res://assets/Gear/JuneV1/base_estrela_5x.png")
const _ZONE_FEVER_TEXTURE := preload("res://assets/Gear/JuneV1/base_estrela_zona.png")

@onready var fever_gradient : TextureRect = $Gear/Control/Base/FeverGradient

const _FIRST_FEVER_GRADIENT_TEXTURE := preload("res://Effects/Fever/Fever_1X.tres")
const _SECOND_FEVER_GRADIENT_TEXTURE := preload("res://Effects/Fever/Fever_2X.tres")
const _THIRD_FEVER_GRADIENT_TEXTURE := preload("res://Effects/Fever/Fever_3X.tres")
const _FOURTH_FEVER_GRADIENT_TEXTURE := preload("res://Effects/Fever/Fever_4X.tres")
const _FIFTH_FEVER_GRADIENT_TEXTURE := preload("res://Effects/Fever/Fever_5X.tres")
const _ZONE_FEVER_GRADIENT_TEXTURE := preload("res://Effects/Fever/Fever_ZONE.tres")

@onready var _fever_line_left : TextureRect = $Gear/Control/Base/FeverLineLeft
@onready var _fever_line_right : TextureRect = $Gear/Control/Base/FeverLineRight

@onready var _fever_star_effect_animation : AnimationPlayer = $"Fever Star Effect"

var _bpm : float
var _last_time_beat : float = 0.0

const STAR_ROTATION_SPEED : float = PI / 32

var _current_fever : Note.Fever = Note.Fever.NONE

func _ready() -> void:
	_bpm = 60.0 / Song.BPM

func _process(delta: float) -> void:
	if Song.get_time() >= _last_time_beat + _bpm:
		_last_time_beat = Song.get_time()
		if beat_animation.is_playing():
			beat_animation.play("RESET")
		beat_animation.play("Beat")
	
	star.rotation += STAR_ROTATION_SPEED * delta

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
	if text_animation.is_playing():
		text_animation.play("RESET")
	text_animation.play("Pop Up Precision")

func set_fever_value(value : float, fever : Note.Fever) -> void:
	fever_bar.value = value
	match fever:
		Note.Fever.NONE:
			if _current_fever != fever:
				_fever_star_effect_animation.play("RESET")
				_current_fever = fever
				fever_gradient.texture = null
				_fever_line_left.visible = false
				_fever_line_right.visible = false
		Note.Fever.X1:
			if _current_fever != fever:
				_fever_star_effect_animation.play("RESET")
				_current_fever = fever
				fever_gradient.texture = null
				_fever_line_left.visible = false
				_fever_line_right.visible = false
			fever_bar.texture_progress = _FIRST_FEVER_TEXTURE
		Note.Fever.X2:
			if _current_fever != fever:
				_fever_star_effect_animation.play("Fever 1X")
				_current_fever = fever
				fever_gradient.texture = _FIRST_FEVER_GRADIENT_TEXTURE
				_fever_line_left.visible = true
				_fever_line_right.visible = true
			fever_bar.texture_progress = _SECOND_FEVER_TEXTURE
		Note.Fever.X3:
			if _current_fever != fever:
				_fever_star_effect_animation.play("Fever 2X")
				_current_fever = fever
				fever_gradient.texture = _SECOND_FEVER_GRADIENT_TEXTURE
				_fever_line_left.visible = true
				_fever_line_right.visible = true
			fever_bar.texture_progress = _THIRD_FEVER_TEXTURE
		Note.Fever.X4:
			if _current_fever != fever:
				_fever_star_effect_animation.play("Fever 3X")
				_current_fever = fever
				fever_gradient.texture = _THIRD_FEVER_GRADIENT_TEXTURE
				_fever_line_left.visible = true
				_fever_line_right.visible = true
			fever_bar.texture_progress = _FOURTH_FEVER_TEXTURE
		Note.Fever.X5:
			if _current_fever != fever:
				_fever_star_effect_animation.play("Fever 4X")
				_current_fever = fever
				fever_gradient.texture = _FOURTH_FEVER_GRADIENT_TEXTURE
				_fever_line_left.visible = true
				_fever_line_right.visible = true
			fever_bar.texture_progress = _FIFTH_FEVER_TEXTURE
		Note.Fever.ZONE:
			if _current_fever != fever:
				_fever_star_effect_animation.play("Fever 5X")
				_current_fever = fever
				fever_gradient.texture = _FIFTH_FEVER_GRADIENT_TEXTURE
				_fever_line_left.visible = true
				_fever_line_right.visible = true
			fever_bar.texture_progress = _ZONE_FEVER_TEXTURE
		Note.Fever.MAX_ZONE:
			if _current_fever != fever:
				_fever_star_effect_animation.play("Fever Zone")
				_current_fever = fever
				fever_gradient.texture = _ZONE_FEVER_GRADIENT_TEXTURE
				_fever_line_left.visible = true
				_fever_line_right.visible = true
			fever_bar.texture_progress = _ZONE_FEVER_TEXTURE

func set_score(score : int) -> void:
	score_text.text = "Score: " + str(score)

func set_speed(speed : float) -> void:
	speed_text.text = "Speed: " + str(speed) + "x"
