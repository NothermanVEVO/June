
extends MarginContainer

@export var shine_color_rect : ColorRect
@export var button : Button
@export var side_lines : ColorRect
@export var color_progress_bar : ProgressBar
@export var icon_texture_rect : TextureRect
@export var description : MarginContainer

# Configurações
const HOVER_SCALE := 1.1
const SCALE_DURATION := 0.18

const PROGRESS_DURATION := 0.45

const FLASH_DURATION := 0.1
const FLASH_OPACITY := 1.0

const SHINE_DURATION := 0.25

const PRESS_DURATION := 0.08
const RELEASE_DURATION := 0.18

const PRESS_SCALE := Vector2(1.05, 0.92)

const CLICK_FLASH_DURATION := 0.08
const CLICK_FLASH_OPACITY := 0.65

# Floating do ícone
const FLOAT_DISTANCE := Vector2(2.0, 2.0)
const FLOAT_DURATION := 5
const FLOAT_ROTATION := 1.5

const NORMAL_SIDE_LINES_SPEED := 16
const FAST_SIDE_LINES_SPEED := 3

var scale_tween : Tween
var float_tween : Tween
var shine_tween : Tween
var progress_tween : Tween
var icon_reset_tween : Tween

var base_position : Vector2
var original_material : Material

var icon_base_offset_position : Vector2
var icon_base_offset_rotation : float

func _ready() -> void:
	await get_tree().process_frame

	base_position = position
	pivot_offset = size / 2.0

	icon_base_offset_position = icon_texture_rect.offset_transform_position
	icon_base_offset_rotation = icon_texture_rect.offset_transform_rotation

	original_material = shine_color_rect.material

	shine_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shine_color_rect.modulate.a = 0.0

	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)
	
	button.button_down.connect(_on_button_down)
	button.button_up.connect(_on_button_up)


func _on_mouse_entered() -> void:
	_stop_tween(scale_tween)
	_stop_floating()
	_stop_tween(shine_tween)
	
	description.visible = true

	position = base_position

	# Aumenta o tamanho
	scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_BACK)
	scale_tween.set_ease(Tween.EASE_OUT)

	scale_tween.tween_property(
		self,
		"scale",
		Vector2.ONE * HOVER_SCALE,
		SCALE_DURATION
	)

	side_lines.material.set_shader_parameter(
		"time_per_cycle",
		FAST_SIDE_LINES_SPEED
	)

	# Inicia a flutuação do ícone
	_start_floating()

	# Executa flash e shine
	_play_shine()

	# Preenche a barra
	_fill_color_bar()

func _on_button_down() -> void:
	_stop_tween(scale_tween)

	scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_SINE)
	scale_tween.set_ease(Tween.EASE_OUT)

	scale_tween.tween_property(
		self,
		"scale",
		Vector2(
			HOVER_SCALE * PRESS_SCALE.x,
			HOVER_SCALE * PRESS_SCALE.y
		),
		PRESS_DURATION
	)
	
	_play_click_flash()

func _on_button_up() -> void:
	_stop_tween(scale_tween)

	scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_BACK)
	scale_tween.set_ease(Tween.EASE_OUT)

	var target_scale := Vector2.ONE * HOVER_SCALE if button.is_hovered() else Vector2.ONE

	scale_tween.tween_property(
		self,
		"scale",
		target_scale,
		RELEASE_DURATION
	)

func _play_click_flash() -> void:
	var flash_tween := create_tween()

	# Interrompe qualquer animação anterior do flash
	_stop_tween(shine_tween)

	shine_color_rect.material = null
	shine_color_rect.color = Color(18.892, 18.892, 18.892)
	shine_color_rect.modulate.a = 0.0

	flash_tween.tween_property(
		shine_color_rect,
		"modulate:a",
		CLICK_FLASH_OPACITY,
		CLICK_FLASH_DURATION * 0.3
	)

	flash_tween.tween_property(
		shine_color_rect,
		"modulate:a",
		0.0,
		CLICK_FLASH_DURATION * 0.7
	)

	flash_tween.tween_callback(
		func():
			shine_color_rect.material = original_material
			shine_color_rect.modulate.a = 0.0
	)

func _on_mouse_exited() -> void:
	_stop_floating()
	_stop_tween(scale_tween)
	_stop_tween(progress_tween)
	
	description.visible = false

	side_lines.material.set_shader_parameter(
		"time_per_cycle",
		NORMAL_SIDE_LINES_SPEED
	)

	color_progress_bar.value = color_progress_bar.min_value

	# Retorna à posição original
	var return_tween := create_tween()
	return_tween.set_trans(Tween.TRANS_SINE)
	return_tween.set_ease(Tween.EASE_OUT)

	return_tween.tween_property(
		self,
		"position",
		base_position,
		SCALE_DURATION
	)

	# Retorna ao tamanho original
	scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_BACK)
	scale_tween.set_ease(Tween.EASE_OUT)

	scale_tween.tween_property(
		self,
		"scale",
		Vector2.ONE,
		SCALE_DURATION
	)


func _start_floating() -> void:
	_stop_tween(icon_reset_tween)

	float_tween = create_tween()
	float_tween.set_loops()

	var phase := randf_range(0.0, TAU)

	float_tween.tween_method(
		func(t: float):
			var vertical := sin(t) * FLOAT_DISTANCE.y
			var horizontal := sin(t * 2.0) * FLOAT_DISTANCE.x
			var rotation := sin(t) * deg_to_rad(FLOAT_ROTATION)

			icon_texture_rect.offset_transform_position = (
				icon_base_offset_position +
				Vector2(horizontal, vertical)
			)

			icon_texture_rect.offset_transform_rotation = (
				icon_base_offset_rotation + rotation
			),
		phase,
		phase + TAU,
		FLOAT_DURATION
	).set_trans(Tween.TRANS_LINEAR)

func _stop_floating() -> void:
	_stop_tween(float_tween)
	_stop_tween(icon_reset_tween)

	icon_reset_tween = create_tween()
	icon_reset_tween.set_trans(Tween.TRANS_SINE)
	icon_reset_tween.set_ease(Tween.EASE_OUT)
	icon_reset_tween.set_parallel(true)

	icon_reset_tween.tween_property(
		icon_texture_rect,
		"offset_transform_position",
		icon_base_offset_position,
		0.2
	)

	icon_reset_tween.tween_property(
		icon_texture_rect,
		"offset_transform_rotation",
		icon_base_offset_rotation,
		0.2
	)

# FLASH E SHINE
func _play_shine() -> void:
	shine_tween = create_tween()

	# 1. Remove o shader para mostrar o ColorRect branco
	shine_color_rect.material = null
	shine_color_rect.color = Color(18.892, 18.892, 18.892)
	shine_color_rect.modulate.a = 0.0

	shine_tween.tween_property(
		shine_color_rect,
		"modulate:a",
		FLASH_OPACITY,
		FLASH_DURATION * 0.35
	)

	shine_tween.tween_property(
		shine_color_rect,
		"modulate:a",
		0.0,
		FLASH_DURATION * 0.65
	)

	# 2. Recoloca o shader
	shine_tween.tween_callback(
		func():
			shine_color_rect.material = original_material
			shine_color_rect.modulate.a = 1.0

			var mat := original_material as ShaderMaterial
			mat.set_shader_parameter("progress", 0.0)
	)

	# 3. Executa o shine
	shine_tween.tween_method(
		func(value: float):
			var mat := original_material as ShaderMaterial
			mat.set_shader_parameter("progress", value),
		0.0,
		1.0,
		SHINE_DURATION
	)

	# 4. Finaliza
	shine_tween.tween_callback(
		func():
			var mat := original_material as ShaderMaterial
			mat.set_shader_parameter("progress", -1.0)
			shine_color_rect.modulate.a = 0.0
	)


# PREENCHIMENTO DA BARRA
func _fill_color_bar() -> void:
	_stop_tween(progress_tween)

	progress_tween = create_tween()

	color_progress_bar.value = color_progress_bar.min_value

	progress_tween.tween_property(
		color_progress_bar,
		"value",
		color_progress_bar.max_value,
		PROGRESS_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


# UTILITÁRIO
func _stop_tween(tween: Tween) -> void:
	if tween and tween.is_running():
		tween.kill()
