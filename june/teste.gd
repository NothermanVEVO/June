extends Node2D

func _ready() -> void:
	var pathway_editor := PathwayEditor.new()
	add_child(pathway_editor)
	
	var spam := Spam.new(1, Path.Types.GROUND)
	
	print(spam.get_path_type())
	print(spam.get_blank().get_path_type())
	
	print(spam.get_start_time())
	print(spam.get_blank().get_start_time())
	
	spam.set_start_time(2)
	
	print(spam.get_start_time())
	print(spam.get_blank().get_start_time())
