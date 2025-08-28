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

var _saved_song_maps : Array[SongMap] = []

var _undo_song_maps : Array[SongMap] = []
var _redo_song_maps : Array[SongMap] = []

var _holding_time : float = 0.0
const _FIRST_HOLDING_TIME_DELAY = 0.3
const _HOLDING_TIME_DELAY = 0.1

func _ready() -> void:
	game.changed.connect(_game_changed)

func _process(delta: float) -> void:
	if not _undo_song_maps.is_empty():
		if Input.is_action_just_pressed("Undo"):
			_on_undo_pressed()
		elif Input.is_action_pressed("Undo"):
			_holding_time += delta
			if _holding_time >= _FIRST_HOLDING_TIME_DELAY:
				_on_undo_pressed()
				if _holding_time - _FIRST_HOLDING_TIME_DELAY >= _HOLDING_TIME_DELAY:
					_on_undo_pressed()
				_holding_time -= _HOLDING_TIME_DELAY
	if not _redo_song_maps.is_empty():
		if Input.is_action_just_pressed("Redo"):
			_on_redo_pressed()
		elif Input.is_action_pressed("Redo"):
			_holding_time += delta
			if _holding_time >= _FIRST_HOLDING_TIME_DELAY:
				_on_redo_pressed()
				if _holding_time - _FIRST_HOLDING_TIME_DELAY >= _HOLDING_TIME_DELAY:
					_on_redo_pressed()
				_holding_time -= _HOLDING_TIME_DELAY
	if Input.is_action_just_released("Undo") or Input.is_action_just_released("Redo"):
		_holding_time = 0.0

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
	var song_map := to_resource()
	_undo_song_maps.append(song_map)
	
	undo.disabled = false
	redo.disabled = true
	_redo_song_maps.clear()

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
	_memory_save_song_map()
	
	_gear_type_value = _gear_type.get_item_id(index)
	
	for sound_map in _saved_song_maps:
		if sound_map.gear_type == _gear_type_value and sound_map.difficulty == _difficulty_type_value:
			#print(sound_map.get_dictionary())
			load_song_map(sound_map)
			return
			
	game.set_gear(_gear_type_value)

func _on_difficulty_item_selected(index: int) -> void:
	_memory_save_song_map()
	
	_difficulty_type_value = _difficulty.get_item_id(index)
	
	for sound_map in _saved_song_maps:
		if sound_map.gear_type == _gear_type_value and sound_map.difficulty == _difficulty_type_value:
			print(sound_map.get_dictionary())
			load_song_map(sound_map)
			return
	
	game.set_gear(_gear_type_value)

func _memory_save_song_map() -> void:
	var song_map := to_resource()
	
	for s_map in _saved_song_maps:
		if SongMap.is_equal(s_map, song_map):
			print("sim")
			s_map.copy_song_map(song_map)
			return
	print("n")
	_saved_song_maps.append(song_map)

func to_resource() -> SongMap:
	var notes_resource : Array[NoteResource] = []
	var long_notes_resource : Array[LongNoteResource] = []
	
	for note in game.gear.get_all_notes():
		notes_resource.append(note.to_resource())
	
	for long_note in game.gear.get_all_long_notes():
		long_notes_resource.append(long_note.to_resource())
	
	return SongMap.new(game.gear.get_type(), _difficulty_type_value, notes_resource, long_notes_resource)

func load_song_map(song_map : SongMap) -> void:
	_difficulty.select(_difficulty.get_item_index(song_map.difficulty))
	
	game.set_gear(song_map.gear_type)
	
	var notes : Array = song_map.notes
	game._selected_notes.clear()
	for note in notes:
		var nt = note.to_note(song_map.gear_type)
		game.gear.add_note_at(note.idx, nt, true)
		if nt is HoldNoteEditor:
			nt.pressing_button.connect(game._pressing_some_hold_resize_button)
		if nt._is_selected:
			game._selected_notes.append(nt)
	
	var long_notes : Array = song_map.long_notes
	game._selected_long_notes.clear()
	for long_note in long_notes:
		var long_nt = long_note.to_long_note()
		game.gear.add_long_note(long_note.to_long_note())
		if long_nt._is_selected:
			game._selected_long_notes.append(long_nt)

func _save_file() -> void:
	pass
