extends WorldEnvironment

func load_glow_environment() -> void:
	if Global.get_settings_dictionary()["glow"]:
		environment = load("res://Effects/GlowEnviroment.tres")

func unload() -> void:
	environment = null
