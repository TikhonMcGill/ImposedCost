extends Node

var game_state: GameState = GameState.new()

func _ready() -> void:
	randomize()
	_setup_game()

#TODO Based on GameManager set Players, set up the Players for each Team
func _setup_players() -> void:
	pass

func _setup_game() -> void:
	_setup_players()
	game_state.setup_game()
