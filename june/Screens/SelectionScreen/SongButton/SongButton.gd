extends Button

class_name SongButton

var UUID : String = ""

signal on_focus_entered(song_button : SongButton)

func _ready() -> void:
	focus_entered.connect(_focus_entered)

@warning_ignore("shadowed_variable")
func setup(UUID : String, icon_texture : ImageTexture, song_name : String, author_name : String) -> void:
	self.UUID = UUID
	$HBoxContainer/Icon.texture = icon_texture
	$HBoxContainer/Texts/SongName.text = song_name
	$HBoxContainer/Texts/AuthorName.text = " " + author_name

func _focus_entered() -> void:
	on_focus_entered.emit(self)

func _on_button_up() -> void:
	if not has_focus():
		button_pressed = true
