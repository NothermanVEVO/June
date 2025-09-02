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
