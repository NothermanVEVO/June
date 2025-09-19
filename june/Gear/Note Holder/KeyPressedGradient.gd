extends TextureRect

class_name KeyPressedGradient

const gradient := preload("res://assets/ClickGradient.tres")

var fade_tween : Tween = null

func _ready() -> void:
	#rotation = deg_to_rad(-90)
	_set_position_n_size()
	Global.changed_max_size_y.connect(_set_position_n_size)
	texture = gradient
	modulate.a = 0.0
	Global.changed_hitzone_y.connect(_set_position_n_size)

func _set_position_n_size() -> void:
	size.y = Gear.get_max_size_y() + float(Note.height) / 2
	size.x = NoteHolder.width
	position.x = -size.x / 2
	position.y = -size.y + float(Note.height)
	pivot_offset.x = size.x / 2
	pivot_offset.y = -size.y / 2

func key_just_pressed() -> void:
	_fade_in()

func key_just_released() -> void:
	_fade_out()

func _fade_in():
	scale.x = 1
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 1.0, 0.01) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN)

func _fade_out():
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.15) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	
	fade_tween.parallel().tween_property(self, "scale:x", 0.0, 0.15) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
