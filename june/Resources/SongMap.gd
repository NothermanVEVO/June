extends Resource

class_name SongMap

enum Difficulty {FACIL = 0, NORMAL = 1, HARD = 2, MAXIMUS = 3}

var gear_type : int ## Gear.Type
var difficulty : int ## Difficulty
var stars : int
var notes : Array[NoteResource]
var long_notes : Array[LongNoteResource]

@warning_ignore("shadowed_variable")
func _init(gear_type : Gear.Type, difficulty : Difficulty, stars : int, notes : Array[NoteResource], long_notes : Array[LongNoteResource]) -> void:
	self.gear_type = gear_type
	self.difficulty = difficulty
	self.stars = stars
	self.notes = notes
	self.long_notes = long_notes

func copy_song_map(song_map : SongMap) -> void:
	self.gear_type = song_map.gear_type
	self.difficulty = song_map.difficulty
	self.stars = song_map.stars
	self.notes = song_map.notes
	self.long_notes = song_map.long_notes

func get_dictionary() -> Dictionary:
	var dictionary : Dictionary = {"gear_type": gear_type, "difficulty": difficulty, "stars": stars, "notes": [], "long_notes": []}
	
	for note in notes:
		dictionary["notes"].append(note.get_dictionary())
	for long_note in long_notes:
		dictionary["long_notes"].append(long_note.get_dictionary())
	
	return dictionary

static func is_equal(song_map1 : SongMap, song_map2 : SongMap) -> bool:
	return song_map1.gear_type == song_map2.gear_type and song_map1.difficulty == song_map2.difficulty

func has_notes() -> bool:
	return not notes.is_empty() or not long_notes.is_empty()

static func dictionary_to_resource(dictionary : Dictionary) -> SongMap:
	@warning_ignore("shadowed_variable")
	var notes : Array[NoteResource] = []
	@warning_ignore("shadowed_variable")
	var long_notes : Array[LongNoteResource] = []
	
	for dict in dictionary["notes"]:
		notes.append(NoteResource.dictionary_to_resource(dict))
	
	for dict in dictionary["long_notes"]:
		long_notes.append(LongNoteResource.dictionary_to_resource(dict))
	
	return SongMap.new(dictionary["gear_type"], dictionary["difficulty"], dictionary["stars"], notes, long_notes)

static func validate_dictionary(dictionary : Dictionary) -> String:
	if not dictionary.has("gear_type") or typeof(dictionary["gear_type"]) != TYPE_FLOAT:
		return  "\"gear_type\" not found or wrong format in SongMap"
	if not dictionary.has("difficulty") or typeof(dictionary["difficulty"]) != TYPE_FLOAT:
		return  "\"difficulty\" not found or wrong format in SongMap"
	if not dictionary.has("stars") or typeof(dictionary["stars"]) != TYPE_FLOAT:
		return  "\"stars\" not found or wrong format in SongMap"
	if not dictionary.has("notes") or typeof(dictionary["notes"]) != TYPE_ARRAY:
		return  "\"notes\" not found or wrong format in SongMap"
	for dict in dictionary["notes"]:
		var validate_wrong := NoteResource.validate_dictionary(dict)
		if validate_wrong:
			return validate_wrong
	if not dictionary.has("long_notes") or typeof(dictionary["long_notes"]) != TYPE_ARRAY:
		return  "\"long_notes\" not found or wrong format in SongMap"
	for dict in dictionary["long_notes"]:
		var validate_wrong := LongNoteResource.validate_dictionary(dict)
		if validate_wrong:
			return  validate_wrong
	return  ""

static func compare_to(original : SongMap, new : SongMap) -> Dictionary:
	var dict : Dictionary
	dict["to_remove_note"] = []
	dict["to_add_note"] = []
	dict["to_add_long_note"] = []
	dict["to_remove_long_note"] = []
	
	var temp_original_notes := original.notes.duplicate()
	for new_note in new.notes:
		var found_note := false
		for original_note in temp_original_notes:
			if new_note.idx == original_note.idx and new_note.type == original_note.type:
				if new_note.type == NoteResource.Type.TAP and new_note.start_time == original_note.start_time:
					found_note = true
					temp_original_notes.erase(original_note)
					break
				elif new_note.type == NoteResource.Type.HOLD and new_note.start_time == original_note.start_time and new_note.end_time == original_note.end_time:
					found_note = true
					temp_original_notes.erase(original_note)
					break
		if not found_note:
			dict["to_add_note"].append(new_note)
	
	var temp_original_long_notes := original.long_notes.duplicate()
	for new_long_note in new.long_notes:
		var found_note := false
		for original_long_note in temp_original_long_notes:
			if new_long_note.type == original_long_note.type and new_long_note.time == original_long_note.time:
				if new_long_note.type == LongNote.Type.ANNOTATION and new_long_note.value == original_long_note.value:
					found_note = true
					temp_original_long_notes.erase(original_long_note)
					break
				elif new_long_note.type == LongNote.Type.SECTION and new_long_note.value == original_long_note.value:
					found_note = true
					temp_original_long_notes.erase(original_long_note)
					break
				elif new_long_note.type == LongNote.Type.SPEED and new_long_note.value == original_long_note.value:
					found_note = true
					temp_original_long_notes.erase(original_long_note)
					break
				elif new_long_note.type == LongNote.Type.FADE and new_long_note.value == original_long_note.value:
					found_note = true
					original.notes.erase(original_long_note)
					break
		if not found_note:
			dict["to_add_long_note"].append(new_long_note)
	
	for original_note in original.notes:
		var found_note := false
		for new_note in new.notes:
			if new_note.idx == original_note.idx and new_note.type == original_note.type:
				if new_note.type == NoteResource.Type.TAP and new_note.start_time == original_note.start_time:
					found_note = true
					new.notes.erase(new_note)
					break
				elif new_note.type == NoteResource.Type.HOLD and new_note.start_time == original_note.start_time and new_note.end_time == original_note.end_time:
					found_note = true
					new.notes.erase(new_note)
					break
		if not found_note:
			dict["to_remove_note"].append(original_note)
	
	for original_long_note in original.long_notes:
		var found_note := false
		for new_long_note in new.long_notes:
			if new_long_note.type == original_long_note.type and new_long_note.time == original_long_note.time:
				if new_long_note.type == LongNote.Type.ANNOTATION and new_long_note.value == original_long_note.value:
					found_note = true
					new.long_notes.erase(new_long_note)
					break
				elif new_long_note.type == LongNote.Type.SECTION and new_long_note.value == original_long_note.value:
					found_note = true
					new.long_notes.erase(new_long_note)
					break
				elif new_long_note.type == LongNote.Type.SPEED and new_long_note.value == original_long_note.value:
					found_note = true
					new.long_notes.erase(new_long_note)
					break
				elif new_long_note.type == LongNote.Type.FADE and new_long_note.value == original_long_note.value:
					found_note = true
					new.long_notes.erase(new_long_note)
					break
		if not found_note:
			dict["to_remove_long_note"].append(original_long_note)
	
	return dict
