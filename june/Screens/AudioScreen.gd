extends Control

class_name AudioScreen

@onready var _main_volume_text : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/MainVolume/MainVolumeText
@onready var _main_volume_slider : HSlider = $PanelContainer/MarginContainer/VBoxContainer/MainVolume/MainVolumeSlider

@onready var _sfx_volume_text : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/SFXVolume/SFXVolumeText
@onready var _sfx_volume_slider : HSlider = $PanelContainer/MarginContainer/VBoxContainer/SFXVolume/SFXVolumeSlider

func _ready() -> void:
	_main_volume_slider.grab_focus()
	
	var dict := Global.get_settings_dictionary()
	
	_main_volume_slider.value = dict["audio_main_volume"]
	_on_main_volume_slider_value_changed(dict["audio_main_volume"])
	
	_sfx_volume_slider.value = dict["audio_sfx"]
	_on_sfx_volume_slider_value_changed(dict["audio_sfx"])

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Escape"):
		_on_return_pressed()

func _on_main_volume_slider_value_changed(value: float) -> void:
	var volume_percentage = clampf(value, 0.0, 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Song"), linear_to_db(volume_percentage))
	var dict := Global.get_settings_dictionary()
	dict["audio_main_volume"] = volume_percentage
	Global.save_settings(dict)
	_main_volume_text.text = "Volume principal: " + ("%0.1f" % (dict["audio_main_volume"] * 100)) + "%"

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	var volume_percentage = clampf(value, 0.0, 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effect"), linear_to_db(volume_percentage))
	var dict := Global.get_settings_dictionary()
	dict["audio_sfx"] = volume_percentage
	Global.save_settings(dict)
	_sfx_volume_text.text = "Efeitos sonoros: " + ("%0.1f" % (dict["audio_sfx"] * 100)) + "%"

func _on_return_pressed() -> void:
	get_tree().change_scene_to_packed(Global._SETTING_SCREEN_SCENE)
