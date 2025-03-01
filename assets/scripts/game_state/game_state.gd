class_name GameState
extends Resource

##A Resource representing the Game State

signal card_drawn(card: Card) ##Emitted when a Card is drawn
signal move_taken(move: Move) ##Emitted when a Move has been Taken

enum TEAM{
	COUNTRY,
	JEDBURGH
}

enum PHASE {
	SETUP, ##In the Setup Phase, the Country Team Player places 4 Project Cards in the ABCD Boxes
	DRAW_CARDS_JEDBURGH, ##Part 1 of the Draw Cards Phase - Jedburgh Drawing a Card
	DRAW_CARDS_COUNTRY, ##Part 2 of the Draw Cards Phase - Country Drawing a Card
	OPERATIONS_COUNTRY, ##Country Team's Turn in the Operations Phase
	OPERATIONS_JEDBURGH, ##Jedburgh's Turn in the Operations Phase
	PROJECTS,
	HN_INFLUENCE,
	TURN_END,
	GAME_END
}

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

@export var projects_to_complete: int = 4 ##No. Projects to Complete before Game Ends (determined by players - 4 or 5 will give a short game, more than 8 will give a long and somewhat repetitive game))

var combinatorics: CombinatoricsUtilities = CombinatoricsUtilities.new() ## Utilities for Calculating Combinatorics Calculations

var victory_level: int = 0 ##The No. Victory Points Blue has

var draw_pile: Array[Card] ##The Draw Pile
var discard_pile: Array[Card] ##The Discard Pile

var host_nation_influence: int = 0 ##The Influence of each team in the Host Nation - negative = Red Influence, Positive = Blue Influence

var current_turn_team: TEAM = TEAM.COUNTRY ##The Team whose Current Turn it is

var country_hand: Array[Card] = [] ##The Hand of the Country Team Player
var jedburgh_hand: Array[Card] = [] ##The Hand of the Jedburgh Team Player

var turn: int = 1 ##The Current Turn
var phase: PHASE = PHASE.SETUP ##The Current Phase of the Game - game starts with Country Team Selecting 4 Project Cards to place

var projects: Array[Project] = [] ##All Projects left to be played

##Set up the Game
func setup_game() -> void:
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
	
	print("Game set up")

##Draw a Card, assuming it is in the Draw Pile
func draw_card(card: Card, team: TEAM) -> void:
	assert(card in draw_pile, "Card %s not in Draw Pile" % card.card_name)
	
	draw_pile.erase(card)
	
	if team == TEAM.COUNTRY:
		print("Country Team Drew Card: %s" % card.card_name)
		country_hand.append(card)
	else:
		print("Jedburgh Team Drew Card: %s" % card.card_name)
		jedburgh_hand.append(card)
	
	#If the Draw Pile is empty, shuffle the discard pile and add it to the draw pile
	if len(draw_pile) == 0:
		discard_pile.shuffle()
		for c in discard_pile:
			draw_pile.append(c)
	
	discard_pile = []

##Draw Random Card
func draw_random_card(team: TEAM) -> void:
	draw_card(draw_pile[0], team)

##TODO Get all Possible Game Moves
func get_possible_moves() -> Array[Move]:
	#In the Setup Phase, the only Possible Moves are the different Combinations of Project Cards
	#that the Country Team could place down, so we return all possible combinations of those
	if phase == PHASE.SETUP:
		var possible_arrangements: Array[Move] = []
		
		var all_projects: Array = [
			PROJECT_ADMINISTRATIVE_SYSTEM,
			PROJECT_FINANCE_SYSTEM,
			PROJECT_HIGHWAY_SYSTEM,
			PROJECT_LARGE_AIRPORT,
			PROJECT_LARGE_PORT,
			PROJECT_MINE,
			PROJECT_SMALL_AIRPORT,
			PROJECT_SMALL_PORT
		]
		
		var all_combinations: Array = combinatorics.generate_combinations(all_projects, 4, false, true)
		
		for a: Array in all_combinations:
			var new_move: SelectProjectsMove = SelectProjectsMove.new()
			new_move.projects_to_select.assign(a)
			possible_arrangements.append(new_move)
		
		return possible_arrangements
	elif phase == PHASE.DRAW_CARDS_JEDBURGH or phase == PHASE.DRAW_CARDS_COUNTRY:
		return [DrawCardMove.new()]
	
	return []

##TODO Carry out the Selected Move
func do_move(move: Move) -> void:
	if move is SelectProjectsMove:
		print("SelectProjectsMove Played")
		
		var projects_selected: PackedStringArray = []
		
		for p: ProjectCard in move.projects_to_select:
			var new_project: Project = Project.new(p)
			projects.append(new_project)
			projects_selected.append(p.card_name)
		
		print("Projects Selected: %s" % ", ".join(projects_selected))
		
		
		print("Moving onto Draw Cards Phase!")
		
		#Move onto Draw Cards Phase once game Set Up
		phase = PHASE.DRAW_CARDS_JEDBURGH
		current_turn_team = TEAM.JEDBURGH
		
	elif move is DrawCardMove:
		print("Drawing Card!")
		draw_random_card(current_turn_team)
		
		#If it is Jedburgh that drew a card, time for the Country Team to do so as well
		if phase == PHASE.DRAW_CARDS_JEDBURGH:
			phase = PHASE.DRAW_CARDS_COUNTRY
			current_turn_team = TEAM.COUNTRY
		#Otherwise, if it was the Country Team that drew a card, move onto Operations phase
		elif phase == PHASE.DRAW_CARDS_COUNTRY:
			print("Draw Cards Phase over!")
			
			#Determine who plays first in the Operations Phase
			if host_nation_influence < 0:
				print("Country Team plays first in Operations Phase!")
				phase = PHASE.OPERATIONS_COUNTRY
				current_turn_team = TEAM.COUNTRY
			else:
				print("Jedburgh Team plays first in Operations Phase!")
				phase = PHASE.OPERATIONS_JEDBURGH
				current_turn_team = TEAM.JEDBURGH
	
	move_taken.emit(move)
