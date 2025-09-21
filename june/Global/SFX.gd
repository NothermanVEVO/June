extends AudioStreamPlayer

const fever_impact := preload("res://assets/sfx/Fever Impact 7.wav")

func _ready() -> void:
	bus = &"Sound Effect"

func play_fever_impact() -> void:
	stop()
	stream = fever_impact
	play()
