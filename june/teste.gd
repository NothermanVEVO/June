extends Node2D

func _ready() -> void:
	var pathway_editor := PathwayEditor.new()
	add_child(pathway_editor)
