class_name GameState
extends Resource

##A Resource representing the Game State

signal card_drawn(card: Card) ##Emitted when a Card is drawn
signal move_taken(move: Move) ##Emitted when a Move has been Taken
signal host_nation_influence_changed(new_hn_influence: int) ##Emitted when HN Influence Changes

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

const FUNCTION_BUILD_MANAGE_DEGRADE_NETWORK_NAME: String = "Build/Manage Network"
const FUNCTION_INFLUENCE_HN_NAME: String = "Influence Host Nation/Use Host Nation Influence"
const FUNCTION_MAINTAIN_NETWORK_NAME: String = "Maintain Network"
const FUNCTION_REVEAL_CONCEAL_NAME: String = "Reveal/Conceal"

#endregion

@export var projects_to_complete: int = 4 ##No. Projects to Complete before Game Ends (determined by players - 4 or 5 will give a short game, more than 8 will give a long and somewhat repetitive game))

var combinatorics: CombinatoricsUtilities = CombinatoricsUtilities.new() ## Utilities for Calculating Combinatorics Calculations

var previous_move: Move = null ##The Previous Move taken

var victory_level: int = 0 ##The No. Victory Points Blue has

var draw_pile: Array[Card] ##The Draw Pile
var discard_pile: Array[Card] ##The Discard Pile

var revealed_cards: Array[Card] ##All Cards that have the "Revealed" Status

var host_nation_influence: int = 0: ##The Influence of each team in the Host Nation - negative = Red Influence, Positive = Blue Influence
	set = _set_hn_influence

var current_turn_team: TEAM = TEAM.COUNTRY ##The Team whose Current Turn it is

var country_hand: Array[Card] = [] ##The Hand of the Country Team Player
var jedburgh_hand: Array[Card] = [] ##The Hand of the Jedburgh Team Player

var country_network: Array = [[], [], [], []] ##The Network of the Country Team Player - 4 Arrays represent 4 Stacks of Cards, 1 to 4 represents A to D, last item in one of stacks is TOPMOST
var jedburgh_network: Array = [[], [], [], []] ##The Network of the Jedburgh Team Player - 4 Arrays represent 4 Stacks of Cards, 1 to 4 represents A to D, last item in one of stacks is TOPMOST

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
	
	#Go through the Starting Pile, adding all of it to the Revealed Cards Array
	for card: Card in starting_pile:
		revealed_cards.append(card)
	
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

##Determine if a Particular Card is Revealed
func is_card_revealed(card: Card) -> bool:
	return card in revealed_cards

##Determine if a Particular Card is Concealed
func is_card_concealed(card: Card) -> bool:
	return is_card_revealed(card) == false

##Reveal a Card
func reveal_card(card: Card) -> void:
	assert(card not in revealed_cards, "Card to be revealed already revealed")
	revealed_cards.append(card)

##Conceal a Card
func conceal_card(card: Card) -> void:
	assert(card in revealed_cards, "Card to be concealed not revealed")
	revealed_cards.erase(card)

##Get the Value on the HN Influence Track
func get_hn_influence_value() -> int:
	var magnitude: int = absi(host_nation_influence)
	
	if magnitude == 4:
		return 3
	elif magnitude == 3:
		return 2
	elif magnitude > 0:
		return 1
	
	return 0

##Get the Team on whose side the HN Influence is (Jedburgh by Default)
func get_hn_influence_team() -> TEAM:
	if host_nation_influence < 0:
		return TEAM.COUNTRY
	
	return TEAM.JEDBURGH

##Get a Player's Name, as "Player Name(Color)", e.g. "Jedburgh (Blue)"
func get_player_name(team: TEAM) -> String:
	if team == TEAM.COUNTRY:
		return GameManager.settings.country_team_name + " (Red)"
	else:
		return GameManager.settings.jedburgh_team_name + " (Blue)"

##Get the Current Player's Name, as "Player Name (Color)"
func get_current_player_name() -> String:
	return get_player_name(current_turn_team)

##Get a Player's Network
func get_player_network(team: TEAM) -> Array:
	if current_turn_team == TEAM.COUNTRY:
		return country_network
	else:
		return jedburgh_network

##Get the Current Player's Network
func get_current_player_network() -> Array:
	return get_player_network(current_turn_team)

##Get the Opposing Player
func get_opposing_player() -> TEAM:
	if current_turn_team == TEAM.COUNTRY:
		return TEAM.JEDBURGH
	
	return TEAM.COUNTRY

##Get the Opposing Player's Network
func get_opposing_player_network() -> Array:
	if current_turn_team == TEAM.COUNTRY:
		return get_player_network(TEAM.JEDBURGH)
	else:
		return get_player_network(TEAM.COUNTRY)

##Get the Network of a Player, as a flattened array
func get_flattened_network(team: TEAM) -> Array[ActionCard]:
	var flattened_network: Array[ActionCard] = []
	
	if team == TEAM.COUNTRY:
		for stack: Array in country_network:
			for card: ActionCard in stack:
				flattened_network.append(card)
	else:
		for stack: Array in jedburgh_network:
			for card: ActionCard in stack:
				flattened_network.append(card)
	
	return flattened_network

##Get a Player's Hand
func get_player_hand(team: TEAM) -> Array[Card]:
	if team == TEAM.COUNTRY:
		return country_hand
	else:
		return jedburgh_hand

##Get the Current Player's Hand
func get_current_player_hand() -> Array[Card]:
	return get_player_hand(current_turn_team)

##Discard a Particular Card from a Particular Team Player's Hand
func discard_card(card: Card, team: TEAM) -> void:
	if team == TEAM.COUNTRY:
		assert(card in country_hand, "Card to be discarded by Country Player not in Country Player's hand")
		country_hand.erase(card)
		discard_pile.append(card)
	elif team == TEAM.JEDBURGH:
		assert(card in jedburgh_hand, "Card to be discarded by Jedburgh Player not in Jedburgh Player's hand")
		jedburgh_hand.erase(card)
		discard_pile.append(card)

##Discard a Particular Action Card from a Particular Team Player's Network
##optionally enforcing whether to reveal or discard it
func discard_card_from_network(card: ActionCard, team: TEAM, enforce_conceal_reveal: bool) -> void:
	assert(card in get_flattened_network(team), "Action Card to be discarded not in Player's Network")
	
	#If we're enforcing the conceal_reveal rule, and the card is concealed, we
	#reveal it, but don't discard it, hence the return
	if enforce_conceal_reveal == true and is_card_concealed(card) == true:
		reveal_card(card)
		return
	
	if team == TEAM.COUNTRY:
		for stack: Array in country_network:
			for action_card: ActionCard in stack:
				if card == action_card:
					stack.erase(action_card)
					discard_pile.append(action_card)
					return
	else:
		for stack: Array in jedburgh_network:
			for action_card: ActionCard in stack:
				if card == action_card:
					stack.erase(action_card)
					discard_pile.append(action_card)
					return

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
		return [MaintainNetworkMove.new()]
	elif current_phase == PHASE.OPERATIONS_COUNTRY or current_phase == PHASE.OPERATIONS_JEDBURGH:
		#Prepare Moves, Passing is an available move by default
		var operations_moves: Array[Move] = [PassMove.new()]
		
		#Handle playing Function Cards in the Player's Hand
		for card: Card in get_current_player_hand():
			if card.card_name == FUNCTION_BUILD_MANAGE_DEGRADE_NETWORK_NAME:
				#TODO Handle Build/Manage or Degrade Network Function Card
				
				#Handle Degrade Network Function Aspect
				operations_moves += _get_degrade_network_possibilities(card)
			elif card.card_name == FUNCTION_INFLUENCE_HN_NAME:
				var new_move: InfluenceHostNationMove = InfluenceHostNationMove.new()
				new_move.card_to_use = card
				operations_moves.append(new_move)
				
				var all_action_cards: Array[ActionCard] = get_flattened_network(current_turn_team)
				for hand_card: Card in get_current_player_hand():
					if hand_card is ActionCard:
						all_action_cards.append(card)
				
				for action_card: ActionCard in all_action_cards:
					var new_move_with_action_card: InfluenceHostNationMove = InfluenceHostNationMove.new()
					
					new_move_with_action_card.card_to_use = card
					new_move_with_action_card.action_card_to_play_with = action_card
					
					operations_moves.append(new_move_with_action_card)
				
				#Handle aspect of using HN Influence if on own track and influence value > 0
				if get_hn_influence_team() == current_turn_team and get_hn_influence_value() > 0:
					#Add Possibilities of using the Card as a Degrade Network
					operations_moves += _get_degrade_network_possibilities(card)
					
					#Add Possibility of using the Card as an Action Card
					var new_action_move: ActionCardMove = ActionCardMove.new()
					new_action_move.card_to_use = card
					new_action_move.value = get_hn_influence_value()
					operations_moves.append(new_action_move)
			elif card.card_name == FUNCTION_REVEAL_CONCEAL_NAME:
				#TODO Handle the Reveal/Conceal Function Card Functions
				
				#Check if Own Network has any Revealed Cards
				var own_network_revealed: bool = get_flattened_network(current_turn_team).any(is_card_revealed)
				
				#Add ConcealMove if own Network has Revealed Cards
				if own_network_revealed == true:
					var new_conceal_move: ConcealMove = ConcealMove.new()
					new_conceal_move.card_to_use = card
					operations_moves.append(new_conceal_move)
				
				#Check if Enemy Network has any Concealed Cards
				var enemy_network_concealed: bool = get_flattened_network(get_opposing_player()).any(is_card_concealed)
				
				#Add RevealMove if the Enemy Network has Concealed Cards
				if enemy_network_concealed == true:
					var new_reveal_move: RevealMove = RevealMove.new()
					new_reveal_move.card_to_use = card
					operations_moves.append(new_reveal_move)
		
		#Handle playing Topmost Action Cards (if any) in the Player's Network
		var topmost_action_cards: Array[ActionCard]
		for stack: Array in get_current_player_network():
			#If any cards in the stack, append the topmost (last) one to topmost
			if len(stack) > 0:
				topmost_action_cards.append(stack[-1])
		
		for t: ActionCard in topmost_action_cards:
			var new_action_card_move: ActionCardMove = ActionCardMove.new()
			new_action_card_move.card_to_use = t
			new_action_card_move.value = t.value
			operations_moves.append(new_action_card_move)
		
		return operations_moves
	
	return []

##TODO Carry out the Selected Move
func make_move(move: Move) -> void:
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
		if card.card_name == FUNCTION_MAINTAIN_NETWORK_NAME:
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
		#If there are no cards in the Player's Hand, discard their Action Cards
		if len(get_current_player_hand()) == 0:
			for c: ActionCard in get_flattened_network(current_turn_team):
				discard_pile.append(c)
			
			if current_turn_team == TEAM.COUNTRY:
				country_network = [[], [], [], []]
			else:
				jedburgh_network = [[], [], [], []]
		
		#Discard all Cards to be Discarded
		print("%s Discarded the following Cards:" % get_current_player_name())
		for discard: Card in move.cards_to_discard:
			print(discard.card_name)
			discard_card(discard, current_turn_team)
		
		print("Previous Arrangement of Network: ")
		for c: Card in get_flattened_network(current_turn_team):
			print(c.card_name)
		
		if current_turn_team == TEAM.COUNTRY:
			country_network = move.new_network_order
			
			print("Country Player Maintained Network, moving onto Operations Phase!")
			
			#Determine who plays first in the Operations Phase
			if host_nation_influence < 0:
				print("Country Team plays first in Operations Phase!")
				transfer_to_phase(PHASE.OPERATIONS_COUNTRY, TEAM.COUNTRY)
			else:
				print("Jedburgh Team plays first in Operations Phase!")
				transfer_to_phase(PHASE.OPERATIONS_JEDBURGH, TEAM.JEDBURGH)
		else:
			jedburgh_network = move.new_network_order
			print("Jedburgh Player Maintained Network, moving onto Country Draw Cards Phase!")
			transfer_to_phase(PHASE.DRAW_CARDS_COUNTRY, TEAM.COUNTRY)
		
		print("New Arrangement of Network: ")
		for c: Card in get_flattened_network(current_turn_team):
			print(c.card_name)
	elif move is PassMove:
		print("%s Passes!" % get_current_player_name())
		
		if previous_move is PassMove:
			print("Previous Player also passed, moving onto Projects Phase!")
			transfer_to_phase(PHASE.PROJECTS, TEAM.COUNTRY)
	elif move is InfluenceHostNationMove:
		var influence_change: int = move.get_influence_change()
		
		#Move HN Influence by corresponding change of influence
		if current_turn_team == TEAM.COUNTRY:
			host_nation_influence -= influence_change
		else:
			host_nation_influence += influence_change
		
		if move.action_card_to_play_with != null:
			print("%s plays Influence Host Nation with Action Card, for total of %d Influence Change!" % [get_current_player_name(), influence_change])
			
			if move.action_card_to_play_with in get_current_player_hand():
				discard_card(move.action_card_to_play_with, current_turn_team)
			else:
				discard_card_from_network(move.action_card_to_play_with, current_turn_team, false)
		else:
			print("%s plays Influence Host Nation without Action Card, for 1 Influence Change!" % get_current_player_name())
	elif move is ActionCardMove:
		assert(len(move.changes) == move.value, "No. Changes (%d) not equal to Action Card Value of %d" % [len(move.changes), move.value])
		
		print("%s doing Action Card Move, with value %d!" % [get_current_player_name(), move.value])
		
		#Go through the Individual Changes one-by-one (whose amount should equal Action Card value)
		print("Changes:")
		for change: ActionCardMove.CHANGE in move.changes:
			if change == ActionCardMove.CHANGE.DECREASE_TIME:
				move.project.time -= 1
				print("\tIncreased Time")
			elif change == ActionCardMove.CHANGE.INCREASE_TIME:
				move.project.time += 1
				print("\tDecreased Time")
			elif change == ActionCardMove.CHANGE.INCREASE_BUDGET:
				move.project.budget += 1
				print("\tIncreased Budget")
		print("")
	elif move is BuildNetworkMove:
		print("%s playing Build Network!" % get_current_player_name())
		
		for card: ActionCard in move.action_cards_to_add:
			assert(card in get_current_player_hand(), "Action Card to add to Network not in player's hand")
		
		for i: int in range(len(move.action_cards_to_add)):
			get_current_player_network()[move.stacks_to_add_to[i]].insert(move.indices_to_add_to[i], move.action_cards_to_add[i])
	elif move is DegradeNetworkMove:
		print("%s playing Degrade Network!" % get_current_player_name())
		assert(is_card_revealed(move.enemy_card_to_discard) == true, "Enemy Card to Discard for Degrade Network is not Revealed")
		
		discard_card_from_network(move.enemy_card_to_discard, get_opposing_player(), false)
	elif move is RevealMove:
		print("%s plays Reveal Move!" % get_current_player_name())
		
		for revealed: ActionCard in move.cards_to_reveal:
			reveal_card(revealed)
	elif move is ConcealMove:
		print("%s plays Conceal Move!" % get_current_player_name())
		
		for concealed: ActionCard in move.cards_to_conceal:
			conceal_card(concealed)
	
	#If the Move is Playing a Card in the Operations Phase, Discard the Card played and
	#give the next player their turn
	if move is PlayCardMove:
		if move.card_to_use is ActionCard:
			discard_card_from_network(move.card_to_use, current_turn_team, true)
		else:
			discard_card(move.card_to_use, current_turn_team)
		
		if current_phase == PHASE.OPERATIONS_COUNTRY:
			transfer_to_phase(PHASE.OPERATIONS_JEDBURGH, TEAM.JEDBURGH)
		elif current_phase == PHASE.OPERATIONS_JEDBURGH:
			transfer_to_phase(PHASE.OPERATIONS_COUNTRY, TEAM.COUNTRY)
	
	previous_move = move
	move_taken.emit(move)

##Transfer to a Phase, with a Specific Player's turn
func transfer_to_phase(phase: PHASE, player: TEAM) -> void:
	current_phase = phase
	current_turn_team = player

##Set Host Nation Influence
func _set_hn_influence(new_val: int) -> void:
	host_nation_influence = clampi(new_val, -4, 4)
	host_nation_influence_changed.emit(new_val)

##Get possible Degrade Network Possibilities
func _get_degrade_network_possibilities(card_to_play: Card) -> Array[DegradeNetworkMove]:
	var possibilities: Array[DegradeNetworkMove] = []
	
	for stack: Array in get_opposing_player_network():
		if len(stack) > 0:
			var topmost_card: ActionCard = stack[-1]
			
			if is_card_revealed(topmost_card) == true:
				var new_degrade_move: DegradeNetworkMove = DegradeNetworkMove.new()
				new_degrade_move.card_to_use = card_to_play
				new_degrade_move.enemy_card_to_discard = topmost_card
				possibilities.append(new_degrade_move)
	
	return possibilities
