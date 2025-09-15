extends Control

class_name VideoScreen

enum Modes {WINDOW, WINDOW_FULLSCREEN, FULLSCREEN}

enum Vsync {ACTIVATED, DESACTIVATED}

enum MSAA {DISABLED, TWO_X, FOUR_X, EIGHT_X}

static var _mode : Modes

static var _vsync : Vsync

static var _msaa : MSAA

@onready var mode_option_button : OptionButton = $PanelContainer/MarginContainer/VBoxContainer/Mode/ModeOptionButton
@onready var vsync_option_button : OptionButton = $PanelContainer/MarginContainer/VBoxContainer/Vsync/VsyncOptionButton
@onready var msaa_option_button : OptionButton = $PanelContainer/MarginContainer/VBoxContainer/MSAA/MSAAOptionButton

func _ready() -> void:
	var dict := Global.get_settings_dictionary()
	mode_option_button.select(dict["video_mode"])
	vsync_option_button.select(dict["video_vsync"])
	msaa_option_button.select(dict["video_msaa"])

func set_mode(mode : Modes) -> void:
	_mode = mode
	var dict := Global.get_settings_dictionary()
	dict["video_mode"] = mode
	Global.save_settings(dict)

func set_vsync(vsync : Vsync) -> void:
	_vsync = vsync
	var dict := Global.get_settings_dictionary()
	dict["video_vsync"] = vsync
	Global.save_settings(dict)

func set_msaa(msaa : MSAA) -> void:
	_msaa = msaa
	var dict := Global.get_settings_dictionary()
	dict["video_msaa"] = msaa
	Global.save_settings(dict)

func _on_mode_option_button_item_selected(index: int) -> void:
	set_mode(index)

func _on_vsync_option_button_item_selected(index: int) -> void:
	set_vsync(index)

func _on_msaa_option_button_item_selected(index: int) -> void:
	set_msaa(index)

func _on_return_pressed() -> void:
	get_tree().change_scene_to_packed(Global._SETTING_SCREEN_SCENE)
