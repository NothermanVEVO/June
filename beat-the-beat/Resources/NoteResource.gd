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

static func dictionary_to_resource(dict : Dictionary) -> NoteResource:
	return NoteResource.new(dict["start_time"], dict["end_time"], dict["idx"], dict["type"], dict["powered"], dict["is_valid"], dict["is_selected"])

func to_note(gear_mode : Gear.Mode) -> Variant:
	var note = null
	if gear_mode == Gear.Mode.PLAYER:
		match type:
			Type.TAP:
				note = Note.new(start_time)
			Type.HOLD:
				note = HoldNote.new(start_time, end_time)
	else: ## GEAR MODE EDITOR
		match type:
			Type.TAP:
				note = NoteEditor.new(start_time)
			Type.HOLD:
				note = HoldNoteEditor.new(start_time, end_time)
	note.set_idx(idx)
	note.powered = powered
	note._is_valid = is_valid
	note._is_selected = is_selected
	
	return note

static func validate_dictionary(dictionary : Dictionary) -> String:
	if not dictionary.has("start_time") or typeof(dictionary["start_time"]) != TYPE_FLOAT:
		return "\"start_time\" not found or wrong format in NoteResource"
	if not dictionary.has("end_time") or typeof(dictionary["end_time"]) != TYPE_FLOAT:
		return "\"end_time\" not found or wrong format in NoteResource"
	if not dictionary.has("idx") or typeof(dictionary["idx"]) != TYPE_FLOAT:
		return "\"idx\" not found or wrong format in NoteResource"
	if not dictionary.has("type") or typeof(dictionary["type"]) != TYPE_FLOAT:
		return "\"type\" not found or wrong format in NoteResource"
	if not dictionary.has("powered") or typeof(dictionary["powered"]) != TYPE_BOOL:
		return "\"powered\" not found or wrong format in NoteResource"
	if not dictionary.has("is_valid") or typeof(dictionary["is_valid"]) != TYPE_BOOL:
		return "\"is_valid\" not found or wrong format in NoteResource"
	if not dictionary.has("is_selected") or typeof(dictionary["is_selected"]) != TYPE_BOOL:
		return "\"is_selected\" not found or wrong format in NoteResource"
	return ""
