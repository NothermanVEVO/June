extends Window

@onready var from_player: OptionButton = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer/FromPlayer
@onready var from_difficulty: OptionButton = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer/FromDifficulty

@onready var to_player: OptionButton = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer/ToPlayer
@onready var to_difficulty: OptionButton = $MarginContainer/VBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer/ToDifficulty

func _on_about_to_popup() -> void:
	from_player.select(0)
	from_difficulty.select(0)
	to_player.select(0)
	to_difficulty.select(0)

func _on_close_requested() -> void:
	visible = false

func _on_copy_button_pressed() -> void:
	var from := SideEditor.get_song_map(from_difficulty.selected, from_player.selected)
	var to := SideEditor.get_song_map(to_difficulty.selected, to_player.selected)
	
	if not from:
		from = SideEditor.create_new_song_map(from_player.selected, from_difficulty.selected)
	
	if not to:
		to = SideEditor.create_new_song_map(to_player.selected, to_difficulty.selected)
	
	SideEditor.copy(from, to)
	
	if SideEditor.current_song_map == to:
		SideEditor.set_current_song_map(to)
	
	DialogConfirmation.pop_up("Cancelar", "Ok", "Songmap copiado com sucesso!")
	visible = false
