extends HoldNote

class_name SideNote

const START_SIDE_NOTE_IMG = preload("res://assets/Notes/SideNote/side_note_v1_bottom.png")
const MIDDLE_SIDE_NOTE_IMG = preload("res://assets/Notes/SideNote/side_note_v1_middle.png")
const END_SIDE_NOTE_IMG = preload("res://assets/Notes/SideNote/side_note_v1_top.png")

enum Side {LEFT, RIGHT}

var _side : Side

static var side_height : float = 40

func _init(start_time : float, end_time : float, side : int) -> void:
	super(start_time, end_time)
	
	_side = side
	
	_holder_size_type = NoteHolder.Holder.SIDE_NOTES
	set_start_time(start_time)
	
	_start_note.texture = START_SIDE_NOTE_IMG
	_middle_note.texture = MIDDLE_SIDE_NOTE_IMG
	_end_note.texture = END_SIDE_NOTE_IMG

func set_side(side : int) -> void:
	_side = side

func get_side() -> int:
	return _side

static func get_width() -> float:
	return Gear.width / 2
