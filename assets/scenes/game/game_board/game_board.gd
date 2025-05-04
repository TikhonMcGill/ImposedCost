class_name GameBoard
extends VBoxContainer

##A UI Element representing a visualization of an Imposed Cost Game Board

var game_state: GameState: set = _set_game_state ##The Game State this Game Board is visualizing

@onready var victor_label: VictorLabel = $VictorLabel
@onready var current_turn_label: CurrentTurnLabel = $CurrentTurnLabel
@onready var projects_to_complete_label: ProjectsToCompleteLabel = $ProjectsToCompleteLabel
@onready var victory_points_label: VictoryPointsLabel = $VictoryPointsLabel
@onready var project_container_container: ProjectContainerContainer = $ProjectContainerContainer
@onready var host_nation_influence_track: HostNationInfluenceTrack = $HostNationInfluenceTrack

func _set_game_state(state: GameState) -> void:
	game_state = state
	
	game_state.game_over.connect(victor_label.show_winner_text)
	game_state.game_over.connect(_handle_game_over)
	
	game_state.turn_over.connect(current_turn_label.show_current_turn)
	game_state.victory_points_changed.connect(victory_points_label.show_victory_points)
	
	game_state.project_set.connect(project_container_container.set_container_project)
	game_state.project_completed.connect(project_container_container.complete_project_container)
	game_state.project_completed.connect(_handle_project_complete)
	
	game_state.host_nation_influence_changed.connect(host_nation_influence_track.set_hn_influence)
	
	current_turn_label.show_current_turn(game_state.current_turn)
	victory_points_label.show_victory_points(game_state.victory_points)
	projects_to_complete_label.show_projects_left(game_state.projects_to_complete)

##Handle a Project Completing and Updating the Label
func _handle_project_complete(_slot: int) -> void:
	projects_to_complete_label.show_projects_left(game_state.projects_to_complete)

##Handle Ending the Game
func _handle_game_over(_ratio: float, _v_text: String) -> void:
	current_turn_label.hide()
