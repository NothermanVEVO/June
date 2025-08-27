extends Resource

class_name LongNoteResource

var time : float
var type : int ## LongNote.Type
var value : String
var is_valid : bool
var is_selected : bool

@warning_ignore("shadowed_variable")
func _init(time : float, type : LongNote.Type, value : String, is_valid : bool, is_selected : bool) -> void:
	self.time = time
	self.type = type
	self.value = value
	self.is_valid = is_valid
	self.is_selected = is_selected

func get_dictionary() -> Dictionary:
	return {"time": time, "type": type, "value": value, "is_valid": is_valid, "is_selected": is_selected}
