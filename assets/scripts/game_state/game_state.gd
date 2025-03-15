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
	MAINTAIN_NETWORK_JEDBURGH, ##Jedburgh Drew the "Maintain Network" Card, and its effects are executed,
	MAINTAIN_NETWORK_COUNTRY, ##The Country Team drew the "Maintain Network" Card, and its effects are executed
	OPERATIONS_COUNTRY, ##Country Team's Turn in the Operations Phase
	OPERATIONS_JEDBURGH, ##Jedburgh's Turn in the Operations Phase
	PROJECTS,
	HN_INFLUENCE,
	TURN_END,
	GAME_END
}

#region Cards

#region Base Cards
const BASE_COUNTRY: BaseCard = preload("res://assets/resources/default_cards/base_cards/country_team.tres")
const BASE_JEDBURGH: BaseCard = preload("res://assets/resources/default_cards/base_cards/jedburgh_team.tres")
#endregion

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

#endregion

#region Card Names

const MAINTAIN_NETWORK_NAME: String = "Maintain Network"

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

var country_network: Array[Card] = [BASE_COUNTRY.duplicate()] ##The Network of the Country Team Player (initially just their base, later on Action Cards)
var jedburgh_network: Array[Card] = [BASE_JEDBURGH.duplicate()] ##The Network of the Jedburgh Team Player (initially just their base, later on Action Cards)

var current_turn: int = 1 ##The Current Turn
var current_phase: PHASE = PHASE.SETUP ##The Current Phase of the Game - game starts with Country Team Selecting 4 Project Cards to place

var projects: Array[Project] = [] ##All Projects left to be played

##Set up the Game
func setup_game() -> void:
	#Set up the Starting Draw Pile
	var starting_pile: Array[Card] = []
	
	#Add Function Cards to Pile
	starting_pile.append(FUNCTION_INFLUENCE_HOST_NATION.duplicate())
	
	starting_pile.append(FUNCTION_REVEAL_CONCEAL.duplicate())
	starting_pile.append(FUNCTION_REVEAL_CONCEAL.duplicate())
	
	starting_pile.append(FUNCTION_BUILD_MANAGE_NETWORK.duplicate())
	starting_pile.append(FUNCTION_BUILD_MANAGE_NETWORK.duplicate())
	
	starting_pile.append(FUNCTION_MAINTAIN_NETWORK.duplicate())
	
	#Add Action Cards to Pile
	starting_pile.append(ACTION_1.duplicate())
	starting_pile.append(ACTION_1.duplicate())
	starting_pile.append(ACTION_1.duplicate())
	starting_pile.append(ACTION_2.duplicate())
	starting_pile.append(ACTION_2.duplicate())
	starting_pile.append(ACTION_3.duplicate())
	
	assert(len(starting_pile) == 12, "Starting Draw Pile not 12 Cards")
	
	#Shuffle the Pile, making the Draw Pile it
	starting_pile.shuffle()
	draw_pile = starting_pile
	
	print("Game set up")

##Draw a Card, assuming it is in the Draw Pile
func draw_card(card: Card, team: TEAM) -> Card:
	assert(card in draw_pile, "Card %s not in Draw Pile" % card.card_name)
	
	draw_pile.erase(card)
	
	if team == TEAM.COUNTRY:
		print("Country Team Drew Card: %s" % card.card_name)
		country_hand.append(card)
		return card
	else:
		print("Jedburgh Team Drew Card: %s" % card.card_name)
		jedburgh_hand.append(card)
		return card
	
	#If the Draw Pile is empty, shuffle the discard pile and add it to the draw pile
	if len(draw_pile) == 0:
		discard_pile.shuffle()
		for c in discard_pile:
			draw_pile.append(c)
	
	discard_pile = []
	
	return null

##Draw Random Card
func draw_random_card(team: TEAM) -> Card:
	return draw_card(draw_pile[0], team)

##Get the Current Player's Name, as "Player Name (Color)", e.g. "Jedburgh (Blue)"
func get_current_player_name() -> String:
	if current_turn_team == TEAM.COUNTRY:
		return GameManager.settings.country_team_name + " (Red)"
	else:
		return GameManager.settings.jedburgh_team_name + " (Blue)"

##Get the Current Player's Network
func get_current_player_network() -> Array[Card]:
	if current_turn_team == TEAM.COUNTRY:
		return country_network
	else:
		return jedburgh_network

##Get the Current Player's Hand
func get_current_player_hand() -> Array[Card]:
	if current_turn_team == TEAM.COUNTRY:
		return country_hand
	else:
		return jedburgh_hand

##Discard a Particular Card from a Particular Team Player's Hand
func discard_card(card: Card, team: TEAM) -> void:
	if team == TEAM.COUNTRY:
		assert(card in country_hand,"Card to be discarded by Country Player not in Country Player's hand")
		country_hand.erase(card)
		discard_pile.append(card)
	elif team == TEAM.JEDBURGH:
		assert(card in jedburgh_hand,"Card to be discarded by Jedburgh Player not in Jedburgh Player's hand")
		jedburgh_hand.erase(card)
		discard_pile.append(card)

##TODO Get all Possible Game Moves
func get_possible_moves() -> Array[Move]:
	#In the Setup Phase, the only Possible Moves are the different Combinations of Project Cards
	#that the Country Team could place down, so we return all possible combinations of those
	if current_phase == PHASE.SETUP:
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
	elif current_phase == PHASE.DRAW_CARDS_JEDBURGH or current_phase == PHASE.DRAW_CARDS_COUNTRY:
		return [DrawCardMove.new()]
	elif current_phase == PHASE.MAINTAIN_NETWORK_COUNTRY or current_phase == PHASE.MAINTAIN_NETWORK_JEDBURGH:
		var possible_maintenances: Array[Move] = []
		
		var network_without_base: Array = get_current_player_network().slice(1)
		
		var network_rearrangements: Array = combinatorics.generate_combinations(
			network_without_base, len(network_without_base), false, true
		)
		
		if len(get_current_player_network()) > 5:
			print("Network of %s is more than 5 Cards, needs to Discard 2 Cards from hand" % get_current_player_name())
			#Generate all possible 2-Card Discardments
			var discard_arrangements: Array = combinatorics.generate_combinations(network_without_base, 2, false, false)
			
			#Generate all possible Maintain Network Moves
			for d: Array in discard_arrangements:
				for r: Array in network_rearrangements:
					var new_move: MaintainNetworkMove = MaintainNetworkMove.new()
					new_move.cards_to_discard.assign(d)
					new_move.new_network_order.assign(r)
					possible_maintenances.append(new_move)
		
		else:
			print("Network of %s is 5 or less Cards, needs to Discard 1 Card from hand" % get_current_player_name())
			
			#Generate all possible Maintain Network Moves
			for d: Card in network_without_base:
				for r: Array in network_rearrangements:
					var new_move: MaintainNetworkMove = MaintainNetworkMove.new()
					new_move.cards_to_discard.assign([d])
					new_move.new_network_order.assign(r)
					possible_maintenances.append(new_move)
		
		return possible_maintenances
	
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
		transfer_to_phase(PHASE.DRAW_CARDS_JEDBURGH, TEAM.JEDBURGH)
	elif move is DrawCardMove:
		print("Drawing Card!")
		var card: Card = draw_random_card(current_turn_team)
		
		#If the Maintain Network Card is drawn, its effects are executed immediately
		if card.card_name == MAINTAIN_NETWORK_NAME:
			print("%s drew Maintain Network!" % get_current_player_name())
			
			discard_card(card, current_turn_team)
			
			if len(get_current_player_hand()) == 0:
				print("%s has no cards in their hand, so discarding Action Cards!" % get_current_player_name())
				var discarded: int = 0
				
				for a: Card in get_current_player_network():
					if a is ActionCard:
						discard_card(a, current_turn_team)
						discarded += 1
				
				print("Discarded %d Action Cards!" % discarded)
				
			else:
				if current_turn_team == TEAM.JEDBURGH:
					transfer_to_phase(PHASE.MAINTAIN_NETWORK_JEDBURGH, TEAM.JEDBURGH)
				else:
					transfer_to_phase(PHASE.MAINTAIN_NETWORK_COUNTRY, TEAM.COUNTRY)
		
		#If it is Jedburgh that drew a card, time for the Country Team to do so as well
		if current_phase == PHASE.DRAW_CARDS_JEDBURGH:
			transfer_to_phase(PHASE.DRAW_CARDS_COUNTRY, TEAM.COUNTRY)
		#Otherwise, if it was the Country Team that drew a card, move onto Operations phase
		elif current_phase == PHASE.DRAW_CARDS_COUNTRY:
			print("Draw Cards Phase over!")
			
			#Determine who plays first in the Operations Phase
			if host_nation_influence < 0:
				print("Country Team plays first in Operations Phase!")
				transfer_to_phase(PHASE.OPERATIONS_COUNTRY, TEAM.COUNTRY)
			else:
				print("Jedburgh Team plays first in Operations Phase!")
				transfer_to_phase(PHASE.OPERATIONS_JEDBURGH, TEAM.JEDBURGH)
	elif move is MaintainNetworkMove:
		#Discard all Cards to be Discarded
		
		print("%s Discarded the following Cards:" % get_current_player_name())
		for discard: Card in move.cards_to_discard:
			print(discard.card_name)
			discard_card(discard, current_turn_team)
		
		print("Previous Arrangement of Network: ")
		for c: Card in get_current_player_network():
			print(c.card_name)
		
		if current_turn_team == TEAM.COUNTRY:
			country_network = country_network.slice(1) + move.new_network_order
			
			print("Country Player Maintained Network, moving onto Operations Phase!")
			
			#Determine who plays first in the Operations Phase
			if host_nation_influence < 0:
				print("Country Team plays first in Operations Phase!")
				transfer_to_phase(PHASE.OPERATIONS_COUNTRY, TEAM.COUNTRY)
			else:
				print("Jedburgh Team plays first in Operations Phase!")
				transfer_to_phase(PHASE.OPERATIONS_JEDBURGH, TEAM.JEDBURGH)
		else:
			jedburgh_network = country_network.slice(1) + move.new_network_order
			print("Jedburgh Player Maintained Network, moving onto Country Draw Cards Phase!")
			transfer_to_phase(PHASE.DRAW_CARDS_COUNTRY, TEAM.COUNTRY)
		
		print("New Arrangement of Network: ")
		for c: Card in get_current_player_network():
			print(c.card_name)
	
	move_taken.emit(move)

##Transfer to a Phase, with a Specific Player's turn
func transfer_to_phase(phase: PHASE, player: TEAM) -> void:
	current_phase = phase
	current_turn_team = player
