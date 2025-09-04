extends FlowContainer

class_name EditorMenuBar

@onready var snap_divisor := $FlowContainer/SnapDivisor
static var _snap_divisor_value : int = 1
enum Divisors{ONE = 1, TWO = 2, FOUR = 4, EIGHT = 8, TWELVE = 12, SIXTEEN = 16}

@onready var _gear_type : OptionButton = $"FlowContainer2/Gear Type"
static var _gear_type_value : int = 4

@onready var _difficulty := $FlowContainer2/Difficulty
static var _difficulty_type_value : int = 0

@onready var _stars := $FlowContainer2/Stars
static var _stars_value : int = 1

@onready var undo : Button = $Undo
@onready var redo : Button = $Redo
@onready var game : GameEditor = $"../Middle/Game/Game"

static var _saved_song_maps : Array[SongMap] = []

static var _undo_song_maps : Array[SongMap] = []
static var _redo_song_maps : Array[SongMap] = []

static var _holding_time : float = 0.0
const _FIRST_HOLDING_TIME_DELAY = 0.3
const _HOLDING_TIME_DELAY = 0.1

@onready var transfer_to_confirmation_scene := preload("res://Editor/TransferToConfirmation.tscn")
var _transfer_to_confirmation : TransferToConfirmation
var _transfer_to_difficulty : SongMap.Difficulty

func _ready() -> void:
	game.changed.connect(_game_changed)
	
	_transfer_to_confirmation = transfer_to_confirmation_scene.instantiate()
	_transfer_to_confirmation.visible = false
	_transfer_to_confirmation.choice_made.connect(_transfer_to_confirmation_choice_made)
	$"../TransferToHolder".add_child.call_deferred(_transfer_to_confirmation)

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
	
	_memory_save_song_map.call_deferred()

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
	
	_memory_save_song_map()

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
	
	_memory_save_song_map()

func _on_gear_type_item_selected(index: int) -> void:
	_game_changed()
	
	_gear_type_value = _gear_type.get_item_id(index)
	
	for sound_map in _saved_song_maps:
		if sound_map.gear_type == _gear_type_value and sound_map.difficulty == _difficulty_type_value:
			#print(sound_map.get_dictionary())
			load_song_map(sound_map)
			return
			
	game.set_gear(_gear_type_value)
	_stars_value = 1
	_stars.value = _stars_value

func _on_difficulty_item_selected(index: int) -> void:
	_game_changed()
	
	_difficulty_type_value = _difficulty.get_item_id(index)
	
	for sound_map in _saved_song_maps:
		if sound_map.gear_type == _gear_type_value and sound_map.difficulty == _difficulty_type_value:
			#print(sound_map.get_dictionary())
			load_song_map(sound_map)
			return
	
	game.set_gear(_gear_type_value)
	_stars_value = 1
	_stars.value = _stars_value

func _on_stars_value_changed(value: float) -> void:
	_stars_value = roundi(value)
	
	for s_map in _saved_song_maps: ## HAD TO USE THIS BECAUSE USING _MEMORY_SAVE_SONG_MAP OR _GAME_CHANGED WOULD BROKE THE UNDO AND REDO
		if SongMap.is_equal(s_map, to_resource()):
			s_map.stars = _stars_value

func _memory_save_song_map() -> void:
	var song_map := to_resource()
	if song_map.notes.is_empty() and song_map.long_notes.is_empty(): ## REMOVE EMPTY SONG MAPS
		var idx := -1
		for i in range(_saved_song_maps.size()):
			if SongMap.is_equal(_saved_song_maps[i], song_map):
				idx = i
				break
		if idx >= 0:
			_saved_song_maps.remove_at(idx)
		return
	
	#print(song_map.get_dictionary())
	
	for s_map in _saved_song_maps:
		if SongMap.is_equal(s_map, song_map):
			s_map.copy_song_map(song_map)
			return
	_saved_song_maps.append(song_map)

func to_resource() -> SongMap:
	var notes_resource : Array[NoteResource] = []
	var long_notes_resource : Array[LongNoteResource] = []
	
	for note in game.gear.get_all_notes():
		notes_resource.append(note.to_resource())
	
	for long_note in game.gear.get_all_long_notes():
		long_notes_resource.append(long_note.to_resource())
	
	return SongMap.new(game.gear.get_type(), _difficulty_type_value, _stars_value, notes_resource, long_notes_resource)

func load_song_map(song_map : SongMap) -> void:
	_difficulty.select(_difficulty.get_item_index(song_map.difficulty))
	_difficulty_type_value = song_map.difficulty
	
	game.set_gear(song_map.gear_type)
	_gear_type_value = song_map.gear_type
	_gear_type.select(_gear_type.get_item_index(_gear_type_value))
	
	_stars_value = song_map.stars
	_stars.value = _stars_value
	
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
		game.gear.add_long_note(long_nt, true)
		long_nt.value_changed.connect(_game_changed)
		if long_nt._is_selected:
			game._selected_long_notes.append(long_nt)

func power_selected_ones() -> void:
	var song_map = to_resource()
	
	var every_note_is_powered := true
	
	for note in song_map.notes:
		if not note.is_selected:
			continue
		if not note.powered:
			every_note_is_powered = false
		note.powered = true
	
	if every_note_is_powered:
		for note in song_map.notes:
			if not note.is_selected:
				continue
			note.powered = false
	
	_game_changed()
	load_song_map(song_map)

func clear_gear() -> void:
	var song_map = to_resource()
	if song_map.notes.is_empty() and song_map.long_notes.is_empty():
		return
	else:
		song_map.notes.clear()
		song_map.long_notes.clear()
		_game_changed()
		load_song_map(song_map)

func transfer_to(difficulty : SongMap.Difficulty) -> void:
	var song_map := to_resource()
	_transfer_to_confirmation.set_text(SongMap.Difficulty.keys()[song_map.difficulty], SongMap.Difficulty.keys()[difficulty])
	_transfer_to_confirmation.visible = true
	_transfer_to_difficulty = difficulty

func _transfer_to_confirmation_choice_made(choice : TransferToConfirmation.Choices) -> void:
	var song_map := to_resource()
	match choice:
		TransferToConfirmation.Choices.REPLACE:
			_memory_save_song_map()
			for s_map in _saved_song_maps:
				if s_map.difficulty == song_map.difficulty:
					_saved_song_maps.erase(s_map)
					break
			
			song_map.difficulty = _transfer_to_difficulty
			for s_map in _saved_song_maps:
				if s_map.difficulty == _transfer_to_difficulty:
					s_map.copy_song_map(song_map)
					_transfer_to_confirmation.visible = false
					_game_changed()
					load_song_map(s_map)
					return
			_game_changed()
			_saved_song_maps.append(song_map)
			load_song_map(song_map)
			
		TransferToConfirmation.Choices.CHANGE:
			_memory_save_song_map()
			for s_map in _saved_song_maps:
				if s_map.difficulty == _transfer_to_difficulty:
					@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
					var copy_map := SongMap.new(0, 0, 0, [], [])
					copy_map.copy_song_map(s_map)
					copy_map.difficulty = song_map.difficulty
					
					s_map.copy_song_map(song_map)
					s_map.difficulty = _transfer_to_difficulty
					
					_transfer_to_confirmation.visible = false
					_game_changed()
					load_song_map(copy_map)
					return
			
			for s_map in _saved_song_maps:
				if s_map.difficulty == song_map.difficulty:
					_saved_song_maps.erase(s_map)
					break
			song_map.difficulty = _transfer_to_difficulty
			load_song_map(song_map)
		
	_transfer_to_confirmation.visible = false

static func is_editor_empty() -> bool:
	return _saved_song_maps.is_empty() and _undo_song_maps.is_empty() and _redo_song_maps.is_empty()

func reset() -> void:
	snap_divisor.select(0)
	_snap_divisor_value = 1
	_gear_type.select(0)
	_gear_type_value = 4
	game.set_gear(_gear_type_value)
	_difficulty.select(0)
	_difficulty_type_value = 0
	_stars.value = 1
	_stars_value = 1
	_saved_song_maps.clear()
	_undo_song_maps.clear()
	_redo_song_maps.clear()
	undo.disabled = true
	redo.disabled = true

static func get_memory_saved_song_maps() -> Array[SongMap]:
	return _saved_song_maps

func load_song_maps(song_maps : Array[SongMap]) -> void:
	reset()
	
	for s_map in song_maps:
		_saved_song_maps.append(s_map)
	
	if _saved_song_maps:
		load_song_map(_saved_song_maps[0])

func is_valid_for_export() -> String:
	if _saved_song_maps.is_empty():
		return "There's no songs maps to export."
	for song_map in _saved_song_maps:
		if song_map.notes.is_empty():
			return "Can't export song map with \"empty notes\". Error in Gear: " + Gear.Type.find_key(song_map.gear_type) + (
			"; Difficulty: " + SongMap.Difficulty.keys()[song_map.difficulty] + ";")
		for note in song_map.notes:
			if not note.is_valid:
				var error : String = ""
				match note.type:
					NoteResource.Type.TAP:
						error = "Tap Note; Time: " + str(note.start_time) + "; Idx: " + str(note.idx) + ";"
					NoteResource.Type.HOLD:
						error = "Hold Note; Start Time: " + str(note.start_time) + "; End Time: " + str(note.end_time) + "; Idx: " + str(note.idx) + ";"
						if note.end_time <= note.start_time:
							error += " The End Time can't be equal or lower than the Start Time;"
				return "Can't export song map with \"wrong note\". Error in Gear: " + Gear.Type.find_key(song_map.gear_type) + (
					"; Difficulty: " + SongMap.Difficulty.keys()[song_map.difficulty] + "; " + error)
		for long_note in song_map.long_notes:
			if not long_note.is_valid:
				return "Can't export song map with \"wrong long note\". Error in Gear: " + Gear.Type.find_key(song_map.gear_type) + (
					"; Difficulty: " + SongMap.Difficulty.keys()[song_map.difficulty] + "; Time: " + str(long_note.time) + "; Type: " + 
					LongNote.Type.keys()[long_note.type] + ";")
	return ""
