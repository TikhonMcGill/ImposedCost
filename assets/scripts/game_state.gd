class_name GameState
extends Resource

##A Resource representing the Game State

signal card_drawn(card: Card) ##Emitted when a Card is drawn

const SMALL_PORT: String = "Small Port"
const LARGE_PORT: String = "Large Port"

const SMALL_AIRPORT: String = "Small Airport"

enum PLAYER {
	BLUE,
	RED
}

enum PHASE {
	SETUP,
	DRAW_CARDS,
	OPERATIONS,
	PROJECTS,
	HN_INFLUENCE,
	TURN_END
}

@export var projects_to_complete: int = 4 ##No. Projects to Complete before Game Ends (determined by players - 4 or 5 will give a short game, more than 8 will give a long and somewhat repetitive game))

var victory_level: int = 0 ##The No. Victory Points Blue has

var draw_pile: Array[Card] ##The Draw Pile
var discard_pile: Array[Card] ##The Discard Pile

var host_nation_influence: int = 0 ##The Influence of each team in the Host Nation - negative = Red Influence, Positive = Blue Influence

var current_player: PLAYER = PLAYER.BLUE ##The Current Player

var blue_hand: Array[Card] = [] ##The Hand of the Blue Player
var red_hand: Array[Card] = [] ##The Hand of the Red Player

var turn: int = 1 ##The Current Turn
var phase: PHASE = PHASE.DRAW_CARDS ##The Current Phase of the Game

#region Function Cards
const FUNCTION_BUILD_MANAGE_NETWORK: FunctionCard = preload("res://assets/resources/default_cards/function_cards/build_manage_network.tres")
const FUNCTION_INFLUENCE_HOST_NATION: FunctionCard = preload("res://assets/resources/default_cards/function_cards/influence_host_nation.tres")
const FUNCTION_MAINTAIN_NETWORK: FunctionCard = preload("res://assets/resources/default_cards/function_cards/maintain_network.tres")
const FUNCTION_REVEAL_CONCEAL: FunctionCard = preload("res://assets/resources/default_cards/function_cards/reveal_conceal.tres")
#endregion

#region Action Cards
const ACTION_1: ActionCard = preload("res://assets/resources/default_cards/action_cards/action_1.tres")
const ACTION_2: ActionCard = preload("res://assets/resources/default_cards/action_cards/action_2.tres")
const ACTION_3: ActionCard = preload("res://assets/resources/default_cards/action_cards/action_3.tres")
#endregion

#region Project Cards
const PROJECT_ADMINISTRATIVE_SYSTEM: ProjectCard = preload("res://assets/resources/default_cards/projects/administrative_system.tres")
const PROJECT_FINANCE_SYSTEM: ProjectCard = preload("res://assets/resources/default_cards/projects/finance_system.tres")
const PROJECT_HIGHWAY_SYSTEM: ProjectCard = preload("res://assets/resources/default_cards/projects/highway_system.tres")

const PROJECT_SMALL_AIRPORT: ProjectCard = preload("res://assets/resources/default_cards/projects/small_airport.tres")
const PROJECT_LARGE_AIRPORT: ProjectCard = preload("res://assets/resources/default_cards/projects/large_airport.tres")

const PROJECT_SMALL_PORT: ProjectCard = preload("res://assets/resources/default_cards/projects/small_port.tres")
const PROJECT_LARGE_PORT: ProjectCard = preload("res://assets/resources/default_cards/projects/large_port.tres")

const PROJECT_MINE: ProjectCard = preload("res://assets/resources/default_cards/projects/mine.tres")
#endregion

##Set up the Game
func setup_game() -> void:
	#TODO Let the Country Team select 4 Projects to Play
	
	#Set up the Starting Draw Pile
	var starting_pile: Array[Card] = []
	
	#Add Function Cards to Pile
	starting_pile.append(FUNCTION_INFLUENCE_HOST_NATION)
	
	starting_pile.append(FUNCTION_REVEAL_CONCEAL)
	starting_pile.append(FUNCTION_REVEAL_CONCEAL)
	
	starting_pile.append(FUNCTION_BUILD_MANAGE_NETWORK)
	starting_pile.append(FUNCTION_BUILD_MANAGE_NETWORK)
	
	starting_pile.append(FUNCTION_MAINTAIN_NETWORK)
	
	#Add Action Cards to Pile
	starting_pile.append(ACTION_1)
	starting_pile.append(ACTION_1)
	starting_pile.append(ACTION_1)
	starting_pile.append(ACTION_2)
	starting_pile.append(ACTION_2)
	starting_pile.append(ACTION_3)
	
	assert(len(starting_pile) == 12, "Starting Draw Pile not 12 Cards")
	
	#Shuffle the Pile, making the Draw Pile it
	starting_pile.shuffle()
	draw_pile = starting_pile

##Draw a Card, assuming it is in the Draw Pile
func draw_card(card: Card, player: PLAYER) -> void:
	assert(card in draw_pile,"Card %s not in Draw Pile" % card.card_name)
	
	draw_pile.erase(card)
	
	if player == PLAYER.BLUE:
		blue_hand.append(card)
	else:
		red_hand.append(card)
	
	#If the Draw Pile is empty, shuffle the discard pile and add it to the draw pile
	if len(draw_pile) == 0:
		discard_pile.shuffle()
		for c in discard_pile:
			draw_pile.append(c)
	discard_pile = []

##Draw Random Card
func draw_random_card(player: PLAYER) -> void:
	draw_card(draw_pile[0], player)

##Do Draw Cards Phase
func do_draw_cards_phase() -> void:
	draw_random_card(PLAYER.BLUE)
	draw_random_card(PLAYER.RED)

##Do Operations Phase
func do_operations_phase() -> void:
	pass

##Do Projects Phase
func do_projects_phase() -> void:
	pass

##Do HN Influence Phase
func do_hn_influence_phase() -> void:
	victory_level += host_nation_influence

##Do Turn End Phase
func do_turn_end_phase() -> void:
	pass

##Do the Next Phase of the Game
func do_next_phase() -> void:
	if phase == PHASE.DRAW_CARDS:
		do_draw_cards_phase()
		phase = PHASE.OPERATIONS
	elif phase == PHASE.OPERATIONS:
		do_operations_phase()
		phase = PHASE.PROJECTS
	elif phase == PHASE.PROJECTS:
		do_projects_phase()
		phase = PHASE.HN_INFLUENCE
	elif phase == PHASE.HN_INFLUENCE:
		do_hn_influence_phase()
		phase = PHASE.TURN_END
	elif phase == PHASE.TURN_END:
		do_turn_end_phase()
		phase = PHASE.DRAW_CARDS

class Project:
	var time: int
	var budget: int
	var project_name: String
	
	func _init(min_time: int, min_budget: int, _project_name: String) -> void:
		time = min_time
		budget = min_budget
		project_name = _project_name
