extends VBoxContainer
 
class_name Precision

const _100_PRECISION_GRADIENT := preload("res://Effects/JuneGearV1Letter/100 MAX.tres")
const _90_PRECISION_GRADIENT := preload("res://Effects/JuneGearV1Letter/90 MAX.tres")
const _BREAK_PRECISION_GRADIENT := preload("res://Effects/JuneGearV1Letter/BREAK.tres")

const _SIDE_SHINE_SHADER_MATERIAL := preload("res://shaders/ShaderMaterial/SideShine.tres")

@onready var _speed_text: RichTextLabel = $SpeedText
@onready var _precision_percentage: RichTextLabel = $MarginContainer/PrecisionPercentage
@onready var _precision_texture_rect: TextureRect = $MarginContainer/PrecisionPercentage/PrecisionTextureRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	modulate.a = 0.0

func pop_precision(precision : int) -> void:
	visible = true
	
	#var value : int = sign(precision)
	precision = abs(precision)
	
	if precision > 50:
		_precision_texture_rect.texture = _100_PRECISION_GRADIENT
		_precision_texture_rect.material = _SIDE_SHINE_SHADER_MATERIAL
		_speed_text.visible = false
		_precision_percentage.text = "MAX"
	elif precision > 0:
		_precision_texture_rect.texture = _90_PRECISION_GRADIENT
		_precision_texture_rect.material = null
		_precision_percentage.text = "OK"
	elif precision == 0:
		_precision_texture_rect.texture = _BREAK_PRECISION_GRADIENT
		_precision_texture_rect.material = null
		_speed_text.visible = false
		_precision_percentage.text = "BREAK"
	
	var modulate_a := modulate.a
	
	animation_player.stop()
	if modulate_a == 0.0:
		animation_player.play("PopAppear")
	else:
		animation_player.play("Pop")
