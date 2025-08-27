extends Resource

class_name SongMap

enum Difficulty {FACIL = 0, NORMAL = 1, HARD = 2, MAXIMUS = 3}

var gear_type : int ## Gear.Type
var difficulty : int ## Difficulty
var notes : Array[NoteResource]
var long_notes : Array[LongNoteResource]

@warning_ignore("shadowed_variable")
func _init(gear_type : Gear.Type, difficulty : Difficulty, notes : Array[NoteResource], long_notes : Array[LongNoteResource]) -> void:
	self.gear_type = gear_type
	self.difficulty = difficulty
	self.notes = notes
	self.long_notes = long_notes

func get_dictionary() -> Dictionary:
	var dictionary : Dictionary = {"gear_type": gear_type, "difficulty": difficulty, "notes": [], "long_notes": []}
	
	for note in notes:
		dictionary["notes"].append(note.get_dictionary())
	for long_note in long_notes:
		dictionary["long_notes"].append(long_note.get_dictionary())
	
	return dictionary
