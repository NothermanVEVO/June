extends Note

class_name NoteEditor

var _text : RichTextLabel = RichTextLabel.new()

func _init(current_time : float, display : bool = false) -> void:
	_current_time = current_time
	
	texture = img
	custom_minimum_size = Vector2(NoteHolder.width, height)
	position = Vector2(-custom_minimum_size / 2)
	z_index = 1
	add_child(_text)
	_text.custom_minimum_size = custom_minimum_size
	_text.position = Vector2(custom_minimum_size.x / 2, -custom_minimum_size.y / 2)
	visible = display

func _physics_process(delta: float) -> void:
	_text.text = str(_current_time)

func display_text(display : bool) -> void:
	visible = display
