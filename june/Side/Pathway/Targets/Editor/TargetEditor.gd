extends Node

class_name TargetEditor

#const _AXE_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/incomplete_axe.png")
#const _END_HOLD_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/end hold.png")
#const _HAMMER_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/incomplete_hammer.png")
#const _HEART_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/heart.png")
#const _HEAVY_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/heavy.png")
#const _MEDIUM_1_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/medium 1.png")
#const _MEDIUM_2_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/medium 2.png")
#const _MIDDLE_HOLD_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/middle hold.png")
#const _NOTE_1_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/note 1.png")
#const _NOTE_2_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/note 2.png")
#const _SHIELD_0_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/shield 0.png")
#const _SHIELD_1_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/shield 1.png")
#const _SHIELD_2_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/shield 2.png")
#const _START_HOLD_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/start hold.png")
#const _TRAP_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/trap.png")
#const _TWINS_TEXTURE : CompressedTexture2D = preload("res://assets/Side/sketch/twins.png")

enum Types {LIGHT_1, LIGHT_2, LIGHT_3, MEDIUM_1, MEDIUM_2, HEAVY, TWINS, SHIELD_0, SHIELD_1, SHIELD_2, HAMMER, HOLD,
			BOSS, TRAP, AXE, NOTE_1, NOTE_2, HEART}

var _previous_type : Types

var _type : Types

var _is_selected : bool = false
var _is_valid : bool = true

var _shader_material = ShaderMaterial.new()

var target : Target

func _init(type : Types, sample_version : bool = false) -> void:
	_shader_material.shader = Global.HIGHLIGHT_SHADER
	_previous_type = -1
	set_type(type, sample_version)

func set_type(type : Types, sample_version : bool = false) -> void:
	_type = type
	
	if _previous_type == _type:
		return
	
	_previous_type = _type
	
	var parent : Node
	
	if target:
		parent = target.get_parent()
		if parent:
			parent.remove_child(target)
			target.free()
	
	match type:
		Types.LIGHT_1:
			target = LightTap.new(0, 0, LightTap.Variants.ONE)
		Types.LIGHT_2:
			target = LightTap.new(0, 0, LightTap.Variants.TWO)
		Types.LIGHT_3:
			target = LightTap.new(0, 0, LightTap.Variants.THREE)
		Types.MEDIUM_1:
			target = ManualTarget.new(0, 0)
		Types.MEDIUM_2:
			target = ManualTarget.new(0, 0)
		Types.HEAVY:
			target = ManualTarget.new(0, 0)
		Types.TWINS:
			target = ManualTarget.new(0, 0)
		Types.SHIELD_0:
			target = ManualTarget.new(0, 0)
		Types.SHIELD_1:
			target = ManualTarget.new(0, 0)
		Types.SHIELD_2:
			target = ManualTarget.new(0, 0)
		Types.HAMMER:
			target = ManualTarget.new(0, 0)
		Types.HOLD:
			target = ManualTarget.new(0, 0)
		Types.TRAP:
			target = ManualTarget.new(0, 0)
		Types.AXE:
			target = ManualTarget.new(0, 0)
		Types.NOTE_1:
			target = ManualTarget.new(0, 0)
		Types.NOTE_2:
			target = ManualTarget.new(0, 0)
		Types.HEART:
			target = ManualTarget.new(0, 0)
	
	if sample_version:
		target.global_position = Vector2(INF, INF)
		target.modulate.a = 0.5
	
	if parent:
		parent.add_child(target)

func get_size() -> Vector2:
	return target.texture.get_size() if target.texture else Vector2.ZERO

func get_type() -> Types:
	return _type

func _set_highlight(highlight : bool) -> void:
	if highlight:
		target.material = _shader_material
	else:
		target.material = null

func set_selected_highlight(selected : bool) -> void:
	_is_selected = selected
	_set_highlight(selected)
	
	if selected:
		target.z_index = 3
	else:
		target.z_index = 2
	
	if selected:
		if _is_valid:
			_shader_material.set_shader_parameter("shade_color", Vector4(1.0, 1.0, 1.0, 0.5))
		else:
			_shader_material.set_shader_parameter("shade_color", Vector4(1.0, 0.4, 0.4, 0.5))
	elif not _is_valid:
		set_invalid_highlight(true)

func set_invalid_highlight(is_invalid : bool) -> void:
	_is_valid = not is_invalid
	_set_highlight(is_invalid)
	if is_invalid and not _is_selected:
			_shader_material.set_shader_parameter("shade_color", Vector4(1.0, 0.1, 0.1, 0.5))
	elif _is_selected:
		set_selected_highlight(true)
