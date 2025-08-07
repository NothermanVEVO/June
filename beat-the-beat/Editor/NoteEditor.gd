extends Note

class_name NoteEditor

var _text : RichTextLabel = RichTextLabel.new()

func _init(current_time : float, display : bool = false) -> void:
	_current_time = current_time
	
	texture = NORMAL_NOTE_IMG
	size = Vector2(NoteHolder.width, height)
	position = Vector2(-size / 2)
	z_index = 1
	add_child(_text)
	_text.custom_minimum_size = size
	_text.position = Vector2(size.x / 2, -size.y / 2)
	visible = display

func _physics_process(delta: float) -> void:
	_text.text = str(_current_time)

func display_text(display : bool) -> void:
	visible = display
