extends FlowContainer

class_name EditorMenuBar

@onready var snap_divisor := $FlowContainer/SnapDivisor
static var _snap_divisor_value : int = 1
enum Divisors{ONE = 1, TWO = 2, FOUR = 4, EIGHT = 8, TWELVE = 12, SIXTEEN = 16}

@onready var _gear_type := $"FlowContainer2/Gear Type"
static var _gear_type_value : int = 4

@onready var _difficulty := $FlowContainer2/Difficulty
static var _difficulty_type_value : int = 0

@onready var undo : Button = $Undo
@onready var redo : Button = $Redo
@onready var game : GameEditor = $"../Middle/Game/Game"

var _undo_song_maps : Array[SongMap] = []
var _redo_song_maps : Array[SongMap] = []

func _ready() -> void:
	game.changed.connect(_game_changed)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Undo") and not _undo_song_maps.is_empty():
		_on_undo_pressed()
	elif Input.is_action_just_pressed("Redo") and not _redo_song_maps.is_empty():
		_on_redo_pressed()

static func get_snap_divisor_value() -> int:
	return _snap_divisor_value

func _on_speed_value_changed(value: float) -> void:
	Gear.set_speed(value)

func _on_snap_divisor_item_selected(index: int) -> void:
	_snap_divisor_value = Divisors.values()[index]

static func get_divisor() -> float:
	return 60.0 / Song.BPM / _snap_divisor_value

func _game_changed() -> void:
	#print(to_resource().get_dictionary())
	_undo_song_maps.append(to_resource())
	undo.disabled = false
	_redo_song_maps.clear()
	redo.disabled = true

func _on_undo_pressed() -> void:
	if _undo_song_maps.is_empty(): # SHOULDN'T ENTER HERE...
		undo.disabled = true
		redo.disabled = true
		return
	
	var song_map : SongMap = _undo_song_maps.pop_back()
	_redo_song_maps.append(to_resource())
	load_song_map(song_map)
	#print(song_map.get_dictionary())
	redo.disabled = false
	if _undo_song_maps.is_empty():
		undo.disabled = true

func _on_redo_pressed() -> void:
	if _redo_song_maps.is_empty(): # SHOULDN'T ENTER HERE...
		undo.disabled = true
		redo.disabled = true
		return
	
	var song_map : SongMap = _redo_song_maps.pop_back()
	_undo_song_maps.append(to_resource())
	load_song_map(song_map)
	#print(song_map.get_dictionary())
	undo.disabled = false
	if _redo_song_maps.is_empty():
		redo.disabled = true

func _on_gear_type_item_selected(index: int) -> void:
	game.set_gear(_gear_type.get_item_id(index))

func _on_difficulty_item_selected(index: int) -> void:
	_difficulty_type_value = _difficulty.get_item_id(index)

func to_resource() -> SongMap:
	var notes_resource : Array[NoteResource] = []
	var long_notes_resource : Array[LongNoteResource] = []
	
	for note in game.gear.get_all_notes():
		notes_resource.append(note.to_resource())
	
	for long_note in game.gear.get_all_long_notes():
		long_notes_resource.append(long_note.to_resource())
	
	return SongMap.new(game.gear.get_type(), _difficulty_type_value, notes_resource, long_notes_resource)

func load_song_map(song_map : SongMap) -> void:
	var dictionary := song_map.get_dictionary()
	
	_difficulty.select(_difficulty.get_item_index(dictionary["difficulty"]))
	
	game.set_gear(dictionary["gear_type"])
	
	var notes_dict : Array = dictionary["notes"]
	for note_dict in notes_dict:
		var note = NoteResource.dictionary_to_resource(note_dict).to_note(dictionary["gear_type"])
		game.gear.add_note_at(note.get_idx(), note, true)
	
	var long_notes_dict : Array = dictionary["long_notes"]
	for long_note_dict in long_notes_dict:
		var long_note = LongNoteResource.dictionary_to_resource(long_note_dict)
		game.gear.add_long_note_at(long_note.get_idx(), long_note, true)

func _save_file() -> void:
	pass
