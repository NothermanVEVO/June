extends HoldNote

class_name SideNote

const START_SIDE_NOTE_IMG = preload("res://assets/Notes/SideNote/side_note_v1_bottom.png")
const MIDDLE_SIDE_NOTE_IMG = preload("res://assets/Notes/SideNote/side_note_v1_middle.png")
const END_SIDE_NOTE_IMG = preload("res://assets/Notes/SideNote/side_note_v1_top.png")

func _init(start_time : float, end_time : float) -> void:
	super(start_time, end_time)
	_holder_size_type = NoteHolder.Holder.SIDE_NOTES
	_start_note.texture = START_SIDE_NOTE_IMG
	_middle_note.texture = MIDDLE_SIDE_NOTE_IMG
	_end_note.texture = END_SIDE_NOTE_IMG

static func get_width() -> float:
	return Gear.width / 2
