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

static func dictionary_to_resource(dict : Dictionary) -> LongNoteResource:
	return LongNoteResource.new(dict["time"], dict["type"], dict["value"], dict["is_valid"], dict["is_selected"])

func to_long_note() -> LongNote:
	var long_note := LongNote.new(time, type)
	match type:
		LongNote.Type.ANNOTATION:
			long_note.set_annotation(value)
		LongNote.Type.SECTION:
			long_note.set_section(value)
		LongNote.Type.SPEED:
			var num = str_to_var(value)
			if not num is float:
				printerr("OPA OPA OPA ERRO NO TO_LONG_NOTE() DENTRO DO LONGNOTERESOURCE")
				num = 1.0
			long_note.set_speed(num)
	long_note.set_invalid_highlight(not is_valid)
	long_note.set_selected_highlight(is_selected)
	return long_note
