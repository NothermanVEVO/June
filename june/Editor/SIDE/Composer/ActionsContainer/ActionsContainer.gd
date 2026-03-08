extends MarginContainer

class_name ActionsContainer

@onready var _actions_vbox_container : ActionsVBoxContainer = $ScrollContainer/VBoxContainer/CenterContainer/ActionsVBoxContainer

func setup(pathway_editor : PathwayEditor, highest_grid_time : float) -> void:
	_actions_vbox_container.setup(pathway_editor, highest_grid_time)
