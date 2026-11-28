extends MarginContainer

const SHINE_DURATION := 0.35
const SCALE_DURATION := 0.18
const HOVER_SCALE := Vector2(1.08, 1.08)
const PRESS_SCALE := Vector2(0.94, 0.94)
const PRESS_DURATION := 0.08
const FLASH_DURATION := 0.2
const FLASH_MAX_ALPHA := 0.8

var shine_tween: Tween
var scale_tween: Tween
var flash_tween: Tween

@onready var shine: ColorRect = $PanelContainer/MarginContainer/HBoxContainer/IconContainer/PanelContainer/Shine
@onready var icon_container: MarginContainer = $PanelContainer/MarginContainer/HBoxContainer/IconContainer
@onready var flash: ColorRect = $PanelContainer/MarginContainer/HBoxContainer/IconContainer/PanelContainer/Flash

func _ready() -> void:
	shine.visible = false
	flash.color.a = 0.0

func _on_button_mouse_entered() -> void:
	# Shine
	if shine_tween:
		shine_tween.kill()

	shine.visible = true

	shine_tween = create_tween()

	shine_tween.tween_method(
		func(value: float):
			shine.material.set_shader_parameter("progress", value),
		0.0,
		1.0,
		SHINE_DURATION
	)

	shine_tween.tween_callback(func(): shine.visible = false)

	# Scale
	if scale_tween:
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_BACK)
	scale_tween.set_ease(Tween.EASE_OUT)

	scale_tween.tween_property(
		icon_container,
		"offset_transform_scale",
		HOVER_SCALE,
		SCALE_DURATION
	)


func _on_button_mouse_exited() -> void:
	if scale_tween:
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_BACK)
	scale_tween.set_ease(Tween.EASE_OUT)

	scale_tween.tween_property(
		icon_container,
		"offset_transform_scale",
		Vector2.ONE,
		SCALE_DURATION
	)


func _on_button_button_down() -> void:
	# Efeito de escala
	if scale_tween:
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_QUAD)
	scale_tween.set_ease(Tween.EASE_OUT)

	scale_tween.tween_property(
		icon_container,
		"offset_transform_scale",
		PRESS_SCALE,
		PRESS_DURATION
	)

	# Efeito de flash
	if flash_tween:
		flash_tween.kill()

	flash.color.a = 0.0

	flash_tween = create_tween()
	flash_tween.tween_property(
		flash,
		"color:a",
		FLASH_MAX_ALPHA,
		0.04
	)

	flash_tween.tween_property(
		flash,
		"color:a",
		0.0,
		FLASH_DURATION
	)


func _on_button_button_up() -> void:
	if scale_tween:
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_BACK)
	scale_tween.set_ease(Tween.EASE_OUT)

	var target_scale := HOVER_SCALE if get_global_rect().has_point(get_global_mouse_position()) else Vector2.ONE

	scale_tween.tween_property(
		icon_container,
		"offset_transform_scale",
		target_scale,
		SCALE_DURATION
	)
