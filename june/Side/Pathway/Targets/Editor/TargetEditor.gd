extends ManualTarget

class_name TargetEditor

const _AXE_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/incomplete_axe.png")
const _END_HOLD_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/end hold.png")
const _HAMMER_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/incomplete_hammer.png")
const _HEART_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/heart.png")
const _HEAVY_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/heavy.png")
const _LIGHT_1_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/light 1.png")
const _LIGHT_2_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/light 2.png")
const _LIGHT_3_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/light 3.png")
const _MEDIUM_1_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/medium 1.png")
const _MEDIUM_2_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/medium 2.png")
const _MIDDLE_HOLD_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/middle hold.png")
const _NOTE_1_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/note 1.png")
const _NOTE_2_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/note 2.png")
const _SHIELD_0_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/shield 0.png")
const _SHIELD_1_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/shield 1.png")
const _SHIELD_2_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/shield 2.png")
const _START_HOLD_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/start hold.png")
const _TRAP_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/trap.png")
const _TWINS_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/twins.png")

enum Types {LIGHT_1, LIGHT_2, LIGHT_3, MEDIUM_1, MEDIUM_2, HEAVY, TWINS, SHIELD_0, SHIELD_1, SHIELD_2, HAMMER, HOLD,
			BOSS, TRAP, AXE, NOTE_1, NOTE_2, HEART}

var _type : Types

var _end_time : float

var min_hits : float
var max_hits : float

var first_time_delay : float
var second_time_delay : float

var _middle : NinePatchRect
var _end : Sprite2D

var _blank : Blank

func _init(start_time : float, path_type : Path.Types, type : Types) -> void:
	super._init(start_time, path_type)
	set_type(type)

func set_type(type : Types) -> void:
	_type = type
	
	match type:
		Types.LIGHT_1:
			texture = _LIGHT_1_TEXTURE
		Types.LIGHT_2:
			texture = _LIGHT_2_TEXTURE
		Types.LIGHT_3:
			texture = _LIGHT_3_TEXTURE
		Types.MEDIUM_1:
			texture = _MEDIUM_1_TEXTURE
		Types.MEDIUM_2:
			texture = _MEDIUM_2_TEXTURE
		Types.HEAVY:
			texture = _HEAVY_TEXTURE
			
			_middle = NinePatchRect.new()
			_middle.texture = _MIDDLE_HOLD_TEXTURE
			
			_end = Sprite2D.new()
			_end.texture = _HEAVY_TEXTURE
		Types.TWINS:
			texture = _TWINS_TEXTURE
		Types.SHIELD_0:
			texture = _SHIELD_0_TEXTURE
		Types.SHIELD_1:
			texture = _SHIELD_1_TEXTURE
		Types.SHIELD_2:
			texture = _SHIELD_2_TEXTURE
		Types.HAMMER:
			texture = _HAMMER_TEXTURE
		Types.HOLD:
			texture = _START_HOLD_TEXTURE
			
			_middle = NinePatchRect.new()
			_middle.texture = _MIDDLE_HOLD_TEXTURE
			
			_end = Sprite2D.new()
			_end.texture = _END_HOLD_TEXTURE
		Types.TRAP:
			texture = _TRAP_TEXTURE
		Types.AXE:
			texture = _AXE_TEXTURE
		Types.NOTE_1:
			texture = _NOTE_1_TEXTURE
		Types.NOTE_2:
			texture = _NOTE_2_TEXTURE
		Types.HEART:
			texture = _HEART_TEXTURE

func get_size() -> Vector2:
	return texture.get_size() if texture else Vector2.ZERO

func get_type() -> Types:
	return _type

func set_end_time(end_time : float) -> void:
	_end_time = end_time

func get_end_time() -> float:
	return _end_time
