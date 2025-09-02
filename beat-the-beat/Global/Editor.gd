extends Node

var _editor_menu_bar_scene := load("res://Editor/Editor Composer.tscn")
@onready var editor_menu_bar : VBoxContainer = _editor_menu_bar_scene.instantiate()

var _editor_settings_scene := load("res://Editor/EditorSettings.tscn")
@onready var editor_settings : SettingsEditor = _editor_settings_scene.instantiate()

func _ready() -> void: ## TEMP, REMOVE LATER
	get_tree().root.add_child.call_deferred(editor_menu_bar)
	get_tree().root.add_child.call_deferred(editor_settings)
	editor_menu_bar.visible = false
	editor_settings.visible = true

func change_to_composer() -> void:
	editor_menu_bar.visible = true
	editor_settings.visible = false

func change_to_settings() -> void:
	editor_menu_bar.visible = false
	editor_settings.visible = true
