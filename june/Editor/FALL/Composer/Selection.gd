extends NinePatchRect

class_name Selection

const IMAGE := preload("res://assets/selection.png")

func _ready() -> void:
	texture = IMAGE
	patch_margin_left = 1
	patch_margin_top = 1
	patch_margin_right = 1
	patch_margin_bottom = 1
	size = Vector2.ZERO
	z_index = 5

func set_rect(rect : Rect2) -> void:
	rect = rect.abs()
	position = rect.position
	size = rect.size
