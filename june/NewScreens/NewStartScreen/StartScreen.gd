extends MarginContainer

const TITLE_STAR_ROTATION_SPEED : float = PI / 16
var icon_reset_tween : Tween

@onready var title_star: Sprite2D = $MarginContainer/TitleStar
@onready var title_star_gradient: TextureRect = $MarginContainer/TitleStar/TitleStarGradient

@export_group("Parallax")
@export var parallax_strength: float = 20.0
@export var smooth_speed: float = 3.0

@export_group("Layers")
@export var background_elements: Control
@export var background_material: ShaderMaterial
@export var middle_elements: Control

var mouse_direction := Vector2.ZERO

var layers: Array[Control]
var original_positions: Array[Vector2]
var layer_multipliers := [0.35, 0.75]

var background_original_offset: Vector2

func _ready() -> void:
	layers = [
		background_elements,
		middle_elements,
	]

	for layer in layers:
		original_positions.append(layer.offset_transform_position)

	background_original_offset = background_material.get_shader_parameter("offset")

func _process(delta: float) -> void:
	title_star.rotation += TITLE_STAR_ROTATION_SPEED * delta
	title_star_gradient.offset_transform_rotation -= TITLE_STAR_ROTATION_SPEED * delta

	var viewport_center := get_viewport_rect().size / 2.0

	# Direção do mouse normalizada entre -1 e 1
	mouse_direction = (get_global_mouse_position() - global_position - viewport_center) / viewport_center
	
	# Parallax do background via shader
	var background_target_offset := background_original_offset - (
		mouse_direction * 50
	)

	var current_offset: Vector2 = background_material.get_shader_parameter("offset")

	background_material.set_shader_parameter(
		"offset",
		current_offset.lerp(
			background_target_offset,
			1.0 - exp(-smooth_speed * delta)
		)
	)

	for i in range(layers.size()):
		var mult : int = 1
		if layers[i] in [background_elements]: ## EVERY ELEMENT HERE MOVES IN THE OPPOSITE DIRECTION
			mult *= -1
		
		var target_offset = mouse_direction * parallax_strength * layer_multipliers[i]

		var target_position = original_positions[i] - (target_offset * mult)

		layers[i].offset_transform_position = layers[i].offset_transform_position.lerp(
			target_position,
			1.0 - exp(-smooth_speed * delta)
		)
