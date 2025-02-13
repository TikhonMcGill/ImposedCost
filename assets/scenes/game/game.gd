extends Node

var game_state: GameState = GameState.new()

func _ready() -> void:
	randomize()
	game_state.setup_game()
