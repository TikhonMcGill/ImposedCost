extends Node

const RANDOM_PLAYER_SCENE: PackedScene = preload("res://assets/scenes/game/player/random_player/random_player.tscn")

var game_state: GameState = GameState.new()

var country_team_player: Player
var jedburgh_team_player: Player

func _ready() -> void:
	_setup_game()

#Based on GameManager set Players, set up the Players for each Team
func _setup_players() -> void:
	var random_player_1: RandomPlayer = RANDOM_PLAYER_SCENE.instantiate()
	add_child(random_player_1)
	
	var random_player_2: RandomPlayer = RANDOM_PLAYER_SCENE.instantiate()
	add_child(random_player_2)
	
	country_team_player = random_player_1
	jedburgh_team_player = random_player_2
	
	country_team_player.my_game = game_state
	jedburgh_team_player.my_game = game_state

func _setup_game() -> void:
	randomize()
	_setup_players()
	game_state.setup_game()
	
	country_team_player.take_turn()
