extends Control

class_name AudioScreen

static var _main_volume_percentage : float

func _ready() -> void:
	$PanelContainer/MarginContainer/VBoxContainer/MainVolumeSlider.grab_focus()
	
	var dict := Global.get_settings_dictionary()
	$PanelContainer/MarginContainer/VBoxContainer/MainVolumeSlider.value = dict["audio_main_volume"]
	set_main_volume_percentage(dict["audio_main_volume"] * 100)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Escape"):
		_on_return_pressed()

func set_main_volume_percentage(percentage : float) -> void:
	_main_volume_percentage = clampf(percentage, 0.0, 100.0) / 100
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Song"), linear_to_db(_main_volume_percentage))
	var dict := Global.get_settings_dictionary()
	dict["audio_main_volume"] = _main_volume_percentage
	Global.save_settings(dict)
	$PanelContainer/MarginContainer/VBoxContainer/MainVolumeText.text = "Volume principal: " + ("%0.1f" % (dict["audio_main_volume"] * 100)) + "%"

func _on_main_volume_slider_value_changed(value: float) -> void:
	set_main_volume_percentage(value * 100) ## YEAH YEAH I KNOW

func _on_return_pressed() -> void:
	get_tree().change_scene_to_packed(Global._SETTING_SCREEN_SCENE)
