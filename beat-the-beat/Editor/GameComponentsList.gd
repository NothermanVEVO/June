extends ItemList

class_name GameComponents

const MINIMUM_SIZE_X : float = 25.0 # It's inside the SoundComponentsList too, needs to adjust that value

var is_resizing : bool = false
var mouse_position_when_down : Vector2
var start_minimum_size_x : float

@onready var sound_components := $"../Sound Components List"

static var _selected_item_text = ""

func _process(_delta: float) -> void:
	if is_resizing:
		custom_minimum_size.x = start_minimum_size_x + (mouse_position_when_down.x - get_global_mouse_position().x)
		custom_minimum_size.x = MINIMUM_SIZE_X if custom_minimum_size.x < MINIMUM_SIZE_X else custom_minimum_size.x
		var max_pos = sound_components.size.x + MINIMUM_SIZE_X
		var screen_difference_x := get_viewport_rect().size.x - custom_minimum_size.x
		if screen_difference_x < max_pos:
			sound_components.custom_minimum_size.x = screen_difference_x - MINIMUM_SIZE_X
			if sound_components.custom_minimum_size.x < MINIMUM_SIZE_X:
				sound_components.custom_minimum_size.x = MINIMUM_SIZE_X
				custom_minimum_size.x = get_viewport_rect().size.x - max_pos
	
	if Input.is_action_just_pressed("Select"):
		_selected_item_text = "Select (E)"
		select(1)
	elif Input.is_action_just_pressed("Tap"):
		_selected_item_text = "Tap (B)"
		select(4)
	elif Input.is_action_just_pressed("Hold"):
		_selected_item_text = "Hold (V)"
		select(5)
	elif Input.is_action_just_pressed("Power"):
		_selected_item_text = "Power (G)"
		select(7)
	elif Input.is_action_just_pressed("Speed") and not Input.is_action_pressed("Undo"):
		_selected_item_text = "Speed (Z)"
		select(8)
	elif Input.is_action_just_pressed("Fade"):
		_selected_item_text = "Fade (F)"
		select(9)
	elif Input.is_action_just_pressed("Note"):
		_selected_item_text = "Note (C)"
		select(12)
	elif Input.is_action_just_pressed("Section"):
		_selected_item_text = "Section (X)"
		select(13)

func _on_item_selected(index: int) -> void:
	
	_selected_item_text = get_item_text(index)
	
	#match get_item_text(index):
		#"Select":
			#pass
		#"Un/lock":
			#pass
		#"Tap":
			#pass
		#"Hold":
			#pass
		#"Power":
			#pass
		#"Speed":
			#pass
		#"Fade":
			#pass
		#"Sound":
			#pass
		#"Note":
			#pass
		#_:
			#print("epa, NÃO ERA PRA ESTAR ENTRANDO AQUI, FICA ESPERTO")

func _on_resize_button_button_down() -> void:
	is_resizing = true
	mouse_position_when_down = get_global_mouse_position()
	start_minimum_size_x = custom_minimum_size.x
	set_process(true)

func _on_resize_button_button_up() -> void:
	is_resizing = false
	set_process(false)

static func get_selected_item_text():
	return _selected_item_text
