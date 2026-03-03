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

var _target : Target

func _init(target : Target) -> void:
	_shader_material.shader = Global.HIGHLIGHT_SHADER
	_target = target

func is_selected() -> bool:
	return _is_selected

func is_valid() -> bool:
	return _is_valid

func _set_highlight(highlight : bool) -> void:
	if highlight:
		_target.material = _shader_material
		for child in _target.get_children():
			if child is Button:
				continue
			child.material = _shader_material
	else:
		_target.material = null
		for child in _target.get_children():
			if child is Button:
				continue
			child.material = null

func set_selected_highlight(selected : bool) -> void:
	_is_selected = selected
	_set_highlight(selected)
	
	if _target is TwinTap and _target.is_older():
		_target.get_twin().target_editor.set_selected_highlight(selected)
	
	if selected:
		_target.z_index = 3
	else:
		_target.z_index = 2
	
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
