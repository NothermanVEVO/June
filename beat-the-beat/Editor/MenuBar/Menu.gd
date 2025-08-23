extends MenuBar

class_name Menu

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
