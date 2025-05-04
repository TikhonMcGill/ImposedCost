extends Node

const MAIN_MENU_PATH: String = "uid://csqyjihnbesyu"

const RANDOM_PLAYER_SCENE: PackedScene = preload("uid://cl5rbc50mn6yi")
const HUMAN_PLAYER_SCENE: PackedScene = preload("uid://xsqhafv5gbm1")

var game_state: GameState = GameState.new()

var country_team_player: Player
var jedburgh_team_player: Player

var no_humans: bool = true #Whether there are any Human-Controlled Players

@onready var observer_board: ObserverBoard = $ObserverBoard
@onready var back_to_main_menu_button: Button = $GameBoard/BackToMainMenuButton

func _ready() -> void:
	_setup_game()

#Based on GameManager set Players, set up the Players for each Team
func _setup_players() -> void:
	assert(
		GameManager.settings.country_team_player in [GameManager.settings.PLAYER.RANDOM, GameManager.settings.PLAYER.HUMAN],
		"Utility not Implemented yet"
	)
	
	assert(
		GameManager.settings.jedburgh_team_player in [GameManager.settings.PLAYER.RANDOM, GameManager.settings.PLAYER.HUMAN],
		"Utility not Implemented yet"
	)
	
	var country_player: Player
	var jedburgh_player: Player
	
	if GameManager.settings.country_team_player == GameManager.settings.PLAYER.RANDOM:
		country_player = RANDOM_PLAYER_SCENE.instantiate()
	elif GameManager.settings.country_team_player == GameManager.settings.PLAYER.HUMAN:
		country_player = HUMAN_PLAYER_SCENE.instantiate()
		no_humans = false
	
	if GameManager.settings.jedburgh_team_player == GameManager.settings.PLAYER.RANDOM:
		jedburgh_player = RANDOM_PLAYER_SCENE.instantiate()
	elif GameManager.settings.jedburgh_team_player == GameManager.settings.PLAYER.HUMAN:
		jedburgh_player = HUMAN_PLAYER_SCENE.instantiate()
		no_humans = false
	
	add_child(country_player)
	add_child(jedburgh_player)
	
	country_team_player = country_player
	jedburgh_team_player = jedburgh_player
	
	country_team_player.game_state = game_state
	jedburgh_team_player.game_state = game_state
	
	country_team_player.my_team = GameState.TEAM.COUNTRY
	jedburgh_team_player.my_team = GameState.TEAM.JEDBURGH
	
	country_team_player.player_move_taken.connect(handle_country_player_move)
	jedburgh_team_player.player_move_taken.connect(handle_jedburgh_player_move)

#Handle a Move being taken by the Game
func handle_move_taken(_move: Move) -> void:
	await(get_tree().create_timer(0.1).timeout)
	do_next_move()

#Do the next move
func do_next_move() -> void:
	if country_team_player.is_my_turn() == true:
		country_team_player.take_turn()
	else:
		jedburgh_team_player.take_turn()

#Handle the Country Team Player taking their Move
func handle_country_player_move(move: Move) -> void:
	game_state.make_move(move)

#Handle the Jedburgh Team Player taking their Move
func handle_jedburgh_player_move(move: Move) -> void:
	game_state.make_move(move)

func _setup_game() -> void:
	randomize()
	
	_setup_players()
	
	game_state.setup_game()
	
	game_state.projects_to_complete = GameManager.settings.projects_to_complete
	game_state.move_taken.connect(handle_move_taken)
	game_state.game_over.connect(_handle_game_over)
	
	#If there are no humans, show the observer board
	if no_humans == true:
		observer_board.game_state = game_state
		observer_board.show()
	else:
		observer_board.hide()
	
	country_team_player.take_turn()

func _handle_game_over(_ratio: float, _text: String) -> void:
	back_to_main_menu_button.show()

#Go back to the Main Menu when the Button is Pressed
func _on_back_to_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
