extends MenuBar

class_name Menu

@onready var editor_menu_bar : EditorMenuBar = $".."

@onready var edit_menu := $Edit

var transfer_to := PopupMenu.new()

func _ready() -> void:
	transfer_to.name = "Transfer To"
	edit_menu.add_child(transfer_to)
	edit_menu.add_submenu_item("Transfer to", "Transfer To")
	
	transfer_to.add_item("Facil")
	transfer_to.add_item("Normal")
	transfer_to.add_item("Hard")
	transfer_to.add_item("Maximus")
	
	edit_menu.index_pressed.connect(edit_menu_index_pressed)
	transfer_to.index_pressed.connect(transfer_to_index_pressed)

func edit_menu_index_pressed(index : int) -> void:
	match edit_menu.get_item_text(index):
		"Settings":
			Editor.change_to_settings()
		"Power selected ones":
			editor_menu_bar.power_selected_ones()
		"Clear gear":
			editor_menu_bar.clear_gear()

func transfer_to_index_pressed(index : int) -> void:
	editor_menu_bar.transfer_to(transfer_to.get_item_id(index))
