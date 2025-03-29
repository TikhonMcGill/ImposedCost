extends Node

const RANDOM_PLAYER_SCENE: PackedScene = preload("res://assets/scenes/game/player/random_player/random_player.tscn")

const PROJECT_CONTAINER_SCENE: PackedScene = preload("res://assets/scenes/game/project_container/project_container.tscn")

var game_state: GameState = GameState.new()

var country_team_player: Player
var jedburgh_team_player: Player

@onready var project_container_container: HBoxContainer = $GameBoard/ProjectContainerContainer
@onready var host_nation_influence_track: HostNationInfluenceTrack = $GameBoard/HostNationInfluenceTrack

func _ready() -> void:
	_setup_game()

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
	
	var random_player_2: RandomPlayer = RANDOM_PLAYER_SCENE.instantiate()
	
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
func handle_move_taken(move: Move) -> void:
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

#Create a Project Container, inserting it into a specific slot
func create_project_container(project: Project, slot: int) -> ProjectContainer:
	var letter_indices: PackedStringArray = ["A","B","C","D"]
	
	#Create a Project Container for the Project
	var new_container: ProjectContainer = PROJECT_CONTAINER_SCENE.instantiate()
	
	#If the Container for the relevant Project Slot is occupied, delete its children
	var project_container: PanelContainer = project_container_container.get_child(slot)
	if project_container.get_child_count() > 0:
		for c: Node in project_container.get_children():
			c.queue_free()
	project_container.add_child(new_container)
	
	new_container.set_project(project)
	new_container.project_label.text = "Project %s" % letter_indices[slot]
	
	return new_container

func _setup_game() -> void:
	randomize()
	_setup_players()
	
	game_state.setup_game()
	
	game_state.projects_to_complete = GameManager.settings.projects_to_complete
	game_state.move_taken.connect(handle_move_taken)
	game_state.project_set.connect(create_project_container)
	game_state.host_nation_influence_changed.connect(host_nation_influence_track.set_hn_influence)
	
	country_team_player.take_turn()
