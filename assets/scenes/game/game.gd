extends Node

const MAIN_MENU_PATH: String = "uid://csqyjihnbesyu"

const RANDOM_PLAYER_SCENE: PackedScene = preload("uid://cl5rbc50mn6yi")

const PROJECT_CONTAINER_SCENE: PackedScene = preload("uid://cqmvug1vyaxk5")

var game_state: GameState = GameState.new()

var country_team_player: Player
var jedburgh_team_player: Player
var project_containers: Array[ProjectContainer]

@onready var current_turn_label: Label = $GameBoard/CurrentTurnLabel

@onready var project_container_container: HBoxContainer = $GameBoard/ProjectContainerContainer
@onready var host_nation_influence_track: HostNationInfluenceTrack = $GameBoard/HostNationInfluenceTrack

@onready var projects_to_complete_label: Label = $GameBoard/ProjectsToCompleteLabel
@onready var victory_points_label: Label = $GameBoard/VictoryPointsLabel

@onready var victor_label: Label = $GameBoard/VictorLabel
@onready var back_to_main_menu_button: Button = $GameBoard/BackToMainMenuButton

func _ready() -> void:
	_setup_game()

func _process(delta: float) -> void:
	current_turn_label.text = "Current Turn: %d" % game_state.current_turn
	projects_to_complete_label.text = "Projects Left to Complete: %d" % game_state.projects_to_complete
	victory_points_label.text = "%s's Victory Points: %d" % [game_state.get_player_name(GameState.TEAM.JEDBURGH), game_state.victory_points]

#Based on GameManager set Players, set up the Players for each Team
func _setup_players() -> void:
	assert(
		GameManager.settings.country_team_player in [GameManager.settings.PLAYER.RANDOM],
		"Human, Utility, Minimax not Implemented yet"
	)
	
	assert(
		GameManager.settings.jedburgh_team_player in [GameManager.settings.PLAYER.RANDOM],
		"Human, Utility, Minimax not Implemented yet"
	)
	
	var country_player: Player
	var jedburgh_player: Player
	
	if GameManager.settings.country_team_player == GameManager.settings.PLAYER.RANDOM:
		country_player = RANDOM_PLAYER_SCENE.instantiate()
	
	if GameManager.settings.jedburgh_team_player == GameManager.settings.PLAYER.RANDOM:
		jedburgh_player = RANDOM_PLAYER_SCENE.instantiate()
	
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

#Set a Project Container's Project In a Specific Slot
func set_container_project(project: Project, slot: int) -> void:
	project_containers[slot].set_project(project)

#Complete a Project Container, implying it is completed
func _complete_project_container(slot: int) -> void:
	project_containers[slot].my_project = null

#Handle Ending the Game
func _handle_game_over(ratio: float, v_text: String) -> void:
	victor_label.text = "Ratio: %.2f, %s" % [ratio, v_text]
	
	current_turn_label.hide()
	projects_to_complete_label.hide()
	project_container_container.hide()
	host_nation_influence_track.hide()
	
	victor_label.show()
	back_to_main_menu_button.show()

func _setup_game() -> void:
	randomize()
	
	for c: Node in project_container_container.get_children():
		assert(c is ProjectContainer, "Project Container Container has Node other than ProjectContainer")
		project_containers.append(c)
	
	_setup_players()
	
	game_state.setup_game()
	
	game_state.projects_to_complete = GameManager.settings.projects_to_complete
	game_state.move_taken.connect(handle_move_taken)
	game_state.project_set.connect(set_container_project)
	game_state.project_completed.connect(_complete_project_container)
	game_state.host_nation_influence_changed.connect(host_nation_influence_track.set_hn_influence)
	game_state.game_over.connect(_handle_game_over)
	
	country_team_player.take_turn()

#Go back to the Main Menu when the Button is Pressed
func _on_back_to_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
