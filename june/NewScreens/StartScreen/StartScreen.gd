extends Control

const CURRENT_VERSION : String = "0.01.00-beta"
const GITHUB_API : String = "https://api.github.com/repos/NothermanVEVO/June/releases/latest"

@onready var background: Control = $Background
@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var press_to_play: Control = $PressToPlay

@onready var latest_version_label: RichTextLabel = $MarginContainer/VBoxContainer/LatestVersionLabel
@onready var current_version_label: Label = $MarginContainer/VBoxContainer/CurrentVersionLabel

static var _first_time = true

static var _latest_version : String = ""

var _choose_mode_scene := load("res://NewScreens/ChooseGame/ChooseMode.tscn")

func _ready() -> void:
	Song.stop()
	
	Global.set_window_title(Global.TitleType.BASE)
	SideEditor.is_on_editor = false
	
	if _first_time:
		var http := HTTPRequest.new()
		add_child(http)
	
		current_version_label.text = "Versão atual: " + CURRENT_VERSION
	
		http.request_completed.connect(_on_version_check_completed)
		http.request(GITHUB_API)
		return
	
	update_latest_version_text()
	
	_change_to_normal_display()

func _change_to_normal_display() -> void:
	$VBoxContainer/MarginContainer/VBoxContainer/PlayButton.grab_focus()
	background.modulate.a = 1.0
	v_box_container.visible = true
	press_to_play.visible = false

func _input(event: InputEvent) -> void:
	if _first_time and event is InputEventMouseButton:
		_first_time = false
		_change_to_normal_display()

func _unhandled_input(_event: InputEvent) -> void:
	if _first_time:
		_first_time = false
		_change_to_normal_display()

func _on_play_button_pressed() -> void:
	ChooseMode.path_to_go = ChooseMode.Paths.PLAY
	get_tree().change_scene_to_packed(_choose_mode_scene)

func _on_edit_button_pressed() -> void:
	ChooseMode.path_to_go = ChooseMode.Paths.EDITOR
	get_tree().change_scene_to_packed(_choose_mode_scene)

func _on_settings_button_pressed() -> void:
	Settings.last_scene_before = Settings.LastSceneBefore.START
	get_tree().change_scene_to_packed(Global.SETTING_SCREEN_SCENE)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_version_check_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if response_code != 200:
		print("Não foi possível verificar a versão.")
		return

	var data = JSON.parse_string(body.get_string_from_utf8())

	if data == null:
		return

	_latest_version = data["tag_name"].trim_prefix("v")
	#var release_url: String = data["html_url"]

	update_latest_version_text()

func update_latest_version_text() -> void:
	if not _latest_version:
		return
	
	if _is_newer_version(_latest_version, CURRENT_VERSION):
		latest_version_label.visible = true
		latest_version_label.text = "[color=#95ff78][pulse freq=1.0 color=#539c40 ease=-2.0][wave amp=10.0 freq=2.0 connected=1]Nova versão disponível: " + str(_latest_version) + "[/wave][/pulse]"

func _is_newer_version(latest: String, current: String) -> bool:
	latest = latest.trim_suffix("-beta")
	current = current.trim_suffix("-beta")
	
	var latest_parts := latest.split(".")
	var current_parts := current.split(".")

	for i in range(3):
		var latest_number := int(latest_parts[i])
		var current_number := int(current_parts[i])

		if latest_number > current_number:
			return true

		if latest_number < current_number:
			return false

	return false
