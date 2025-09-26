extends WorldEnvironment

const _GLOW_ENVIROMENT := preload("res://Effects/GlowEnviroment.tres")

func load_glow_environment() -> void:
	if Global.get_settings_dictionary()["glow"]:
		environment = _GLOW_ENVIROMENT

func unload() -> void:
	environment = null
