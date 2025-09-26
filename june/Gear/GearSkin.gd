extends Control

class_name GearSkin

@onready var precision_container : VBoxContainer = $FullGear/Precision
@onready var precision_speed_text : RichTextLabel = $FullGear/Precision/Speed
@onready var precision_percentage_text : RichTextLabel = $FullGear/Precision/MarginContainer/Percentage

@onready var text_animation : AnimationPlayer = $FullGear/TextAnimation
@onready var beat_animation : AnimationPlayer = $FullGear/BeatAnimation

@onready var score_text : RichTextLabel = $FullGear/Base/VBoxContainer/Score
@onready var speed_text : RichTextLabel = $FullGear/Base/VBoxContainer/MarginContainer/Speed

@onready var fever_bar : TextureProgressBar = $FullGear/Gear/Control/FeverBar
@onready var star : NinePatchRect = $FullGear/Gear/Control/Star

const _FIRST_FEVER_TEXTURE := preload("res://assets/Gear/JuneV1/base_estrela_1x.png")
const _SECOND_FEVER_TEXTURE := preload("res://assets/Gear/JuneV1/base_estrela_2x.png")
const _THIRD_FEVER_TEXTURE := preload("res://assets/Gear/JuneV1/base_estrela_3x.png")
const _FOURTH_FEVER_TEXTURE := preload("res://assets/Gear/JuneV1/base_estrela_4x.png")
const _FIFTH_FEVER_TEXTURE := preload("res://assets/Gear/JuneV1/base_estrela_5x.png")
const _ZONE_FEVER_TEXTURE := preload("res://assets/Gear/JuneV1/base_estrela_zona.png")

@onready var fever_gradient : TextureRect = $FullGear/Gear/Control/Base/FeverGradient

const _FIRST_FEVER_GRADIENT_TEXTURE := preload("res://Effects/Fever/Fever_1X.tres")
const _SECOND_FEVER_GRADIENT_TEXTURE := preload("res://Effects/Fever/Fever_2X.tres")
const _THIRD_FEVER_GRADIENT_TEXTURE := preload("res://Effects/Fever/Fever_3X.tres")
const _FOURTH_FEVER_GRADIENT_TEXTURE := preload("res://Effects/Fever/Fever_4X.tres")
const _FIFTH_FEVER_GRADIENT_TEXTURE := preload("res://Effects/Fever/Fever_5X.tres")
const _ZONE_FEVER_GRADIENT_TEXTURE := preload("res://Effects/Fever/Fever_ZONE.tres")

@onready var _fever_line_left : TextureRect = $FullGear/Gear/Control/Base/FeverLineLeft
@onready var _fever_line_right : TextureRect = $FullGear/Gear/Control/Base/FeverLineRight

@onready var _fever_star_effect_animation : AnimationPlayer = $FullGear/"Fever Star Effect"

@onready var _combo_animation : AnimationPlayer = $FullGear/ComboAnimation

@onready var _precision_texture_rect : TextureRect = $FullGear/Precision/MarginContainer/Percentage/TextureRect
const _SIDE_SHINE_SHADER_MATERIAL := preload("res://shaders/ShaderMaterial/SideShine.tres")

const _100_PRECISION_GRADIENT := preload("res://Effects/JuneGearV1Letter/100 MAX.tres")
const _90_PRECISION_GRADIENT := preload("res://Effects/JuneGearV1Letter/90 MAX.tres")
const _BREAK_PRECISION_GRADIENT := preload("res://Effects/JuneGearV1Letter/BREAK.tres")

@onready var _explosion_particles : CPUParticles2D = $"FullGear/Gear/Control/Fever Effect Star/Explosion"

var _bpm : float
var _last_time_beat : float = 0.0

const STAR_ROTATION_SPEED : float = PI / 32

var _current_fever : Note.Fever = Note.Fever.NONE

@onready var _finalization_animation : AnimationPlayer = $FullGear/FinalizationAnimation
enum Finalization{CLEAR, MAX_COMBO, PERFECT_COMBO}

signal loaded

func _ready() -> void:
	_bpm = 60.0 / Song.BPM
	
	#_shader_material.shader = Global.SHINE_HIGHLIGHT
	#_shader_material.set_shader_parameter("is_horizontal", true)
	#_shader_material.set_shader_parameter("speed", -1.0)
	#_shader_material.set_shader_parameter("highlight_strength", 4)
	
	#if Global.get_settings_dictionary()["particles"]:
	#_fever_star_effect_animation.play("RESET")
	#beat_animation.play("RESET")
	#text_animation.play("RESET")
	#_finalization_animation.play("RESET")
	
	var dict := Global.get_settings_dictionary()
	
	if dict["game_gear_position"] == GameSettingsScreen.GearPositions.LEFT:
		$FullGear.position.x -= 625
	elif dict["game_gear_position"] == GameSettingsScreen.GearPositions.RIGHT:
		$FullGear.position.x += 625
	
	$FullGear/Gear/Control/Base/Background.color.a = 1 - dict["game_gear_transparency"]

func _process(delta: float) -> void:
	if Song.get_time() >= _last_time_beat + _bpm:
		_last_time_beat = Song.get_time()
		if Global.get_settings_dictionary()["particles"]:
			if beat_animation.is_playing():
				beat_animation.play("RESET")
			beat_animation.play("Beat")
	
	star.rotation += STAR_ROTATION_SPEED * delta

func pop_precision(precision : int) -> void:
	precision_container.visible = true
	
	var value : int = sign(precision)
	precision = abs(precision)
	
	if precision == 100:
		_precision_texture_rect.texture = _100_PRECISION_GRADIENT
		_precision_texture_rect.material = _SIDE_SHINE_SHADER_MATERIAL
		precision_speed_text.visible = false
		precision_percentage_text.text = str(precision) + "% MAX"
	elif precision > 0 and precision < 100:
		_precision_texture_rect.texture = _90_PRECISION_GRADIENT
		_precision_texture_rect.material = null
		precision_speed_text.visible = true
		if value > 0:
			precision_speed_text.text = "Fast"
		else:
			precision_speed_text.text = "Slow"
		precision_percentage_text.text = str(precision) + "% MAX"
	elif precision == 0:
		_precision_texture_rect.texture = _BREAK_PRECISION_GRADIENT
		_precision_texture_rect.material = null
		precision_speed_text.visible = false
		precision_percentage_text.text = "BREAK"
	if text_animation.is_playing():
		text_animation.play("RESET")
	text_animation.play("Pop Up Precision")

func set_fever_value(value : float, fever : Note.Fever, hit_again : bool = false, _no_effect : bool = false) -> void:
	fever_bar.value = value
	match fever:
		Note.Fever.NONE:
			if _current_fever != fever:
				if Global.get_settings_dictionary()["particles"]:
					_fever_star_effect_animation.play("RESET")
				_current_fever = fever
				fever_gradient.texture = null
				_fever_line_left.visible = false
				_fever_line_right.visible = false
		Note.Fever.X1:
			if _current_fever != fever:
				if Global.get_settings_dictionary()["particles"]:
					_fever_star_effect_animation.play("RESET")
				_current_fever = fever
				fever_gradient.texture = null
				_fever_line_left.visible = false
				_fever_line_right.visible = false
			fever_bar.texture_progress = _FIRST_FEVER_TEXTURE
		Note.Fever.X2:
			if _current_fever != fever:
				if Global.get_settings_dictionary()["particles"]:
					if _fever_star_effect_animation.is_playing():
						_fever_star_effect_animation.play("RESET")
						_explosion_particles.restart()
					_fever_star_effect_animation.play("Fever 1X")
					Sfx.play_fever_impact()
				_current_fever = fever
				fever_gradient.texture = _FIRST_FEVER_GRADIENT_TEXTURE
				_fever_line_left.visible = true
				_fever_line_right.visible = true
			fever_bar.texture_progress = _SECOND_FEVER_TEXTURE
		Note.Fever.X3:
			if _current_fever != fever:
				if Global.get_settings_dictionary()["particles"]:
					if _fever_star_effect_animation.is_playing():
						_fever_star_effect_animation.play("RESET")
						_explosion_particles.restart()
					_fever_star_effect_animation.play("Fever 2X")
					Sfx.play_fever_impact()
				_current_fever = fever
				fever_gradient.texture = _SECOND_FEVER_GRADIENT_TEXTURE
				_fever_line_left.visible = true
				_fever_line_right.visible = true
			fever_bar.texture_progress = _THIRD_FEVER_TEXTURE
		Note.Fever.X4:
			if _current_fever != fever:
				if Global.get_settings_dictionary()["particles"]:
					if _fever_star_effect_animation.is_playing():
						_fever_star_effect_animation.play("RESET")
						_explosion_particles.restart()
					_fever_star_effect_animation.play("Fever 3X")
					Sfx.play_fever_impact()
				_current_fever = fever
				fever_gradient.texture = _THIRD_FEVER_GRADIENT_TEXTURE
				_fever_line_left.visible = true
				_fever_line_right.visible = true
			fever_bar.texture_progress = _FOURTH_FEVER_TEXTURE
		Note.Fever.X5:
			if _current_fever != fever:
				if Global.get_settings_dictionary()["particles"]:
					if _fever_star_effect_animation.is_playing():
						_fever_star_effect_animation.play("RESET")
						_explosion_particles.restart()
					_fever_star_effect_animation.play("Fever 4X")
					Sfx.play_fever_impact()
				_current_fever = fever
				fever_gradient.texture = _FOURTH_FEVER_GRADIENT_TEXTURE
				_fever_line_left.visible = true
				_fever_line_right.visible = true
			fever_bar.texture_progress = _FIFTH_FEVER_TEXTURE
		Note.Fever.ZONE:
			if _current_fever != fever or hit_again:
				if Global.get_settings_dictionary()["particles"] and not _no_effect:
					if _fever_star_effect_animation.is_playing():
						_fever_star_effect_animation.play("RESET")
						_explosion_particles.restart()
					_fever_star_effect_animation.play("Fever 5X")
					Sfx.play_fever_impact()
				if _no_effect:
					_fever_star_effect_animation.play("5X JUST SHINE")
				_current_fever = fever
				fever_gradient.texture = _FIFTH_FEVER_GRADIENT_TEXTURE
				_fever_line_left.visible = true
				_fever_line_right.visible = true
			fever_bar.texture_progress = _ZONE_FEVER_TEXTURE
		Note.Fever.MAX_ZONE:
			if _current_fever != fever or hit_again:
				if Global.get_settings_dictionary()["particles"]:
					if _fever_star_effect_animation.is_playing():
						_fever_star_effect_animation.play("RESET")
						_explosion_particles.restart()
					_fever_star_effect_animation.play("Fever Zone")
					Sfx.play_fever_impact()
				_current_fever = fever
				fever_gradient.texture = _ZONE_FEVER_GRADIENT_TEXTURE
				_fever_line_left.visible = true
				_fever_line_right.visible = true
			fever_bar.texture_progress = _ZONE_FEVER_TEXTURE

func set_score(score : int) -> void:
	score_text.text = "Score: " + str(score)

func set_speed(speed : float) -> void:
	speed_text.text = "Speed: " + str(speed) + "x"

func set_combo(combo : int) -> void:
	$FullGear/Combo/ComboText.text = "COMBO " + str(combo)
	if _combo_animation.is_playing():
		_combo_animation.play("RESET")
	_combo_animation.play("Pop")

func play_finalization(finalization : Finalization) -> void:
	Sfx.play_finalization()
	_finalization_animation.play(str(Finalization.keys()[finalization]))

func load_gear(loading_screen : LoadingScreen) -> int:
	var quantity : int = 0
	
	_combo_animation.play("Pop")
	quantity += 1
	
	text_animation.play("Pop Up Precision")
	quantity += 1
	
	beat_animation.play("Beat")
	quantity += 1
	
	quantity += _load_fever_star_effect_animations(loading_screen)
	
	quantity += _load_finalization_animations(loading_screen)
	
	_combo_animation.animation_finished.connect(loading_screen.loaded)
	text_animation.animation_finished.connect(loading_screen.loaded)
	beat_animation.animation_finished.connect(loading_screen.loaded)
	
	return quantity

func _load_fever_star_effect_animations(loading_screen : LoadingScreen) -> int:
	_fever_star_effect_animation.animation_finished.connect(loading_screen.loaded)
	_fever_star_effect_animation.speed_scale = 4
	
	_play_all_fever_animations()
	
	return 6

func _play_all_fever_animations() -> void:
	_fever_star_effect_animation.play("Fever 1X")
	await _fever_star_effect_animation.animation_finished
	
	_fever_star_effect_animation.play("Fever 2X")
	await _fever_star_effect_animation.animation_finished
	
	_fever_star_effect_animation.play("Fever 3X")
	await _fever_star_effect_animation.animation_finished
	
	_fever_star_effect_animation.play("Fever 4X")
	await _fever_star_effect_animation.animation_finished
	
	_fever_star_effect_animation.play("Fever 5X")
	await _fever_star_effect_animation.animation_finished
	
	_fever_star_effect_animation.play("Fever Zone")

func _load_finalization_animations(loading_screen : LoadingScreen) -> int:
	_finalization_animation.animation_finished.connect(loading_screen.loaded)
	_finalization_animation.speed_scale = 4
	
	_play_all_finalization_animations()
	
	return 3

func _play_all_finalization_animations() -> void:
	_finalization_animation.play("CLEAR")
	await _finalization_animation.animation_finished
	
	_finalization_animation.play("MAX_COMBO")
	await _finalization_animation.animation_finished
	
	_finalization_animation.play("PERFECT_COMBO")
