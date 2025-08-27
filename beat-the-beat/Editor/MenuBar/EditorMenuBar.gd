extends FlowContainer

class_name EditorMenuBar

@onready var snap_divisor := $FlowContainer/SnapDivisor
static var _snap_divisor_value : int = 1
enum Divisors{ONE = 1, TWO = 2, FOUR = 4, EIGHT = 8, TWELVE = 12, SIXTEEN = 16}

@onready var _gear_type := $"FlowContainer2/Gear Type"
static var _gear_type_value : int = 4

@onready var _difficulty := $FlowContainer2/Difficulty
static var _difficulty_type_value : int = 0

#@onready var undo : Button = $Undo
#@onready var do : Button = $Redo
@onready var game : GameEditor = $"../Middle/Game/Game"

var undo_redo := UndoRedo.new()

func _ready() -> void:
	game.changed.connect(_game_changed)

static func get_snap_divisor_value() -> int:
	return _snap_divisor_value

func _on_speed_value_changed(value: float) -> void:
	Gear.set_speed(value)

func _on_snap_divisor_item_selected(index: int) -> void:
	_snap_divisor_value = Divisors.values()[index]

static func get_divisor() -> float:
	return 60.0 / Song.BPM / _snap_divisor_value

func _game_changed() -> void:
	#print("oi")
	print(to_resource().get_dictionary()) # TODO TODO TODO TODO TODO
	pass

func _on_undo_pressed() -> void:
	print("undo")
	pass

func _on_redo_pressed() -> void:
	print("redo")
	pass

func _on_gear_type_item_selected(index: int) -> void:
	print(index)

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

func _save_file() -> void:
	pass
