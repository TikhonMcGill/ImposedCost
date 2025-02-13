extends Control

const GAME_PATH: String = "res://assets/scenes/game/game.tscn"

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(GAME_PATH)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
