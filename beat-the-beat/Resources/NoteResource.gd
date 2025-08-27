extends Resource

class_name NoteResource

enum Type {TAP = 0, HOLD = 1}

var start_time : float
var end_time : float
var idx : int
var type : int ## Type
var powered : bool
var is_valid : bool
var is_selected : bool

@warning_ignore("shadowed_variable")
func _init(start_time : float, end_time : float, idx : int, type : Type, powered : bool, is_valid : bool, is_selected : bool) -> void:
	self.start_time = start_time
	self.end_time = end_time
	self.idx = idx
	self.type = type
	self.powered = powered
	self.is_valid = is_valid
	self.is_selected = is_selected

func get_dictionary() -> Dictionary:
	return {"start_time": start_time, "end_time": end_time, "idx": idx, "type": type, "powered": powered, "is_valid": is_valid, 
		"is_selected": is_selected}
