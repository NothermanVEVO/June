extends PanelContainer

class_name FakeCloneContainer

@onready var _name_rich_text_label : RichTextLabel =  $MarginContainer/VBoxContainer/NameRichTextLabel
@onready var _start_time_line_edit : LineEdit = $MarginContainer/VBoxContainer/StartTimeContainer/StartTimeLineEdit

var _fake_clone : FakeClone
var _idx : int

func set_fake_clone(fake_clone : FakeClone, idx : int) -> void:
	_fake_clone = fake_clone
	_idx = idx
	_name_rich_text_label.text = "Fake Clone " + str(_idx + 1)
	_start_time_line_edit.text = Global.time_to_text(_fake_clone.get_start_time())
