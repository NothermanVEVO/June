extends HoldNoteEditor

class_name SideNoteEditor

func _init(start_time : float, end_time : float) -> void:
	super(start_time, end_time)
	
	_holder_size_type = NoteHolder.Holder.SIDE_NOTES
	set_start_time(start_time)
	
	z_index = 0
	y_sort_enabled = true
	
	_start_note.texture = SideNote.START_SIDE_NOTE_IMG
	_middle_note.texture = SideNote.MIDDLE_SIDE_NOTE_IMG
	_end_note.texture = SideNote.END_SIDE_NOTE_IMG
