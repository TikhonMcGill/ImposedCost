extends Node

#Singleton

const SETTINGS_PATH: String = "user://settings.tres" #Path to the Game Settings, where Settings are saved

var settings: GameSettings = GameSettings.new()

func _ready() -> void:
	_load_settings()

#Save Game Settings
func save_settings() -> void:
	ResourceSaver.save(settings, SETTINGS_PATH)

#Load Game Settings
func _load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_PATH) == false:
		save_settings()
		return
	
	settings = ResourceLoader.load(SETTINGS_PATH)
