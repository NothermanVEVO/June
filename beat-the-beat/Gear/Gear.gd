extends Node2D

class_name Gear

enum Type {FOUR_KEYS = 4, FIVE_KEYS = 5, SIX_KEYS = 6}
static var _type : int

static var _note_holders : Array[NoteHolder]

const width := 500

var _center_screen : bool = true

func _init(type : Type, center_screen : bool = true) -> void:
	_type = type
	_center_screen = center_screen

func _ready() -> void: #TODO HANDLE ANY POSITION FOR THE GEAR, NOT ONLY THE MIDDLE
	NoteHolder.width = width / _type
	var initial_x
	if _center_screen:
		initial_x = (get_viewport_rect().size.x / 2) - (width / 2) + (NoteHolder.width / 2)
	else:
		initial_x = -(width / 2) + (NoteHolder.width / 2)
	
	for i in range(_type):
		var note_holder := NoteHolder.new(str(i + 1) + "_" + str(_type) + "k", initial_x)
		initial_x += NoteHolder.width
		_note_holders.append(note_holder)
		add_child(note_holder)

func add_note_at(idx : int, note : Note) -> void:
	_note_holders[idx].add_note(note)

static func get_type() -> int:
	return _type

static func get_note_holders_global_position() -> Array[Vector2]:
	var array : Array[Vector2]
	for note_holder in _note_holders:
		array.append(note_holder.global_position)
	return array

func _draw() -> void:
	draw_circle(Vector2.ZERO, 10, Color.AQUA)
