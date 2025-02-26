extends Node

const RANDOM_PLAYER_SCENE: PackedScene = preload("res://assets/scenes/game/player/random_player/random_player.tscn")

var game_state: GameState = GameState.new()

var country_team_player: Player
var jedburgh_team_player: Player

@onready var project_a_container: VBoxContainer = $GameBoard/HBoxContainer/ProjectAContainer
@onready var project_b_container: VBoxContainer = $GameBoard/HBoxContainer/ProjectBContainer
@onready var project_c_container: VBoxContainer = $GameBoard/HBoxContainer/ProjectCContainer
@onready var project_d_container: VBoxContainer = $GameBoard/HBoxContainer/ProjectDContainer

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

func handle_move_taken(move: Move) -> void:
	pass

func _setup_game() -> void:
	randomize()
	_setup_players()
	
	game_state.setup_game()
	game_state.move_taken.connect(handle_move_taken)
	
	country_team_player.take_turn()
