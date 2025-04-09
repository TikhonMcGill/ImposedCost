class_name GameState
extends Resource

##A Resource representing the Game State

signal card_drawn(card: Card) ##Emitted when a Card is drawn
signal move_taken(move: Move) ##Emitted when a Move has been Taken
signal host_nation_influence_changed(new_hn_influence: int) ##Emitted when HN Influence Changes
signal project_set(project: Project, slot: int) ##Emitted when a Specific Project is set in a specific slot
signal project_completed(slot: int) ##Emitted when a Project in a Specific Slot is Completed

enum TEAM{
	COUNTRY, ##The Country Team (Red)
	JEDBURGH, ##The Jedburgh Team (Blue)
	NOBODY ##Nobody - it's Nobody's Turn at the end of the Game
}

enum PHASE {
	SETUP, ##In the Setup Phase, the Country Team Player places 4 Project Cards in the ABCD Boxes
	DRAW_CARDS_JEDBURGH, ##Part 1 of the Draw Cards Phase - Jedburgh Drawing a Card
	DRAW_CARDS_COUNTRY, ##Part 2 of the Draw Cards Phase - Country Drawing a Card
	MAINTAIN_NETWORK_JEDBURGH, ##Jedburgh Drew the "Maintain Network" Card, and its effects are executed,
	MAINTAIN_NETWORK_COUNTRY, ##The Country Team drew the "Maintain Network" Card, and its effects are executed
	OPERATIONS_COUNTRY, ##Country Team's Turn in the Operations Phase
	OPERATIONS_JEDBURGH, ##Jedburgh's Turn in the Operations Phase
	PROJECTS, ##Projects Phase - here, completed Projects are Scored and their Effects carried out, and any and all new Projects are added into play
	HN_INFLUENCE, ##HN Influence Phase - Add or lower Jedburgh's Victory Points based on whose side HN Influence Track is on
	TURN_END, ##Turn End Phase - increase Projects' Times (if budget > 0), if no Projects left, move to Game End Phase
	GAME_END ##Game End Phase - Calculate Outcome - Country Victory, Jedburgh Tactical Victory, Jedburgh Strategic Victory
}

#region Cards

#region Base Cards
var BASE_COUNTRY: BaseCard = ResourceLoader.load("uid://b32wrnrj5kinr")
var BASE_JEDBURGH: BaseCard = ResourceLoader.load("uid://5idsh7858e7v")
#endregion

#region Function Cards
var FUNCTION_BUILD_MANAGE_NETWORK: FunctionCard = ResourceLoader.load("uid://tboydcudocwk")
var FUNCTION_INFLUENCE_HOST_NATION: FunctionCard = ResourceLoader.load("uid://cnp8ku437jq08")
var FUNCTION_MAINTAIN_NETWORK: FunctionCard = ResourceLoader.load("uid://b82w25ds73ca2")
var FUNCTION_REVEAL_CONCEAL: FunctionCard = ResourceLoader.load("uid://xigyuo4vs6th")
#endregion

#region Action Cards
var ACTION_1: ActionCard = ResourceLoader.load("uid://1lk18ql5qrjc")
var ACTION_2: ActionCard = ResourceLoader.load("uid://gaa57k8bfdr7")
var ACTION_3: ActionCard = ResourceLoader.load("uid://cx7md82o7thfb")
#endregion

#region Project Cards
var PROJECT_ADMINISTRATIVE_SYSTEM: ProjectCard = ResourceLoader.load("uid://c75de2n0j3sxj")
var PROJECT_FINANCE_SYSTEM: ProjectCard = ResourceLoader.load("uid://5kjlbcyjr00l")
var PROJECT_HIGHWAY_SYSTEM: ProjectCard = ResourceLoader.load("uid://g7e8p2lw8os7")

var PROJECT_SMALL_AIRPORT: ProjectCard = ResourceLoader.load("uid://i6lrvyomlfpb")
var PROJECT_LARGE_AIRPORT: ProjectCard = ResourceLoader.load("uid://cmwfcu56vvodf")

var PROJECT_SMALL_PORT: ProjectCard = ResourceLoader.load("uid://boyma0p02kcbl")
var PROJECT_LARGE_PORT: ProjectCard = ResourceLoader.load("uid://cy6lcskh1cuer")

var PROJECT_MINE: ProjectCard = ResourceLoader.load("uid://nmkhwfglvn7r")
#endregion

#endregion

#region Card Names

const FUNCTION_BUILD_MANAGE_DEGRADE_NETWORK_NAME: String = "Build/Manage Network"
const FUNCTION_INFLUENCE_HN_NAME: String = "Influence Host Nation/Use Host Nation Influence"
const FUNCTION_MAINTAIN_NETWORK_NAME: String = "Maintain Network"
const FUNCTION_REVEAL_CONCEAL_NAME: String = "Reveal/Conceal"

const PROJECT_ADMINISTRATIVE_SYSTEM_NAME: String = "Administrative System"
const PROJECT_FINANCE_SYSTEM_NAME: String = "Finance System"
const PROJECT_HIGHWAY_SYSTEM_NAME: String = "Highway System"
const PROJECT_SMALL_AIRPORT_NAME: String = "Small Airport"
const PROJECT_SMALL_PORT_NAME: String = "Small Port"
const PROJECT_LARGE_AIRPORT_NAME: String = "Large Airport"
const PROJECT_LARGE_PORT_NAME: String = "Large Port"
const PROJECT_MINE_NAME: String = "Mine"

#endregion

#region Effect Names

const EFFECT_ADD_VALUE_NAME: String = "Add 1 Value"

#endregion

@export var projects_to_complete: int = 4 ##No. Projects to Complete before Game Ends (determined by players - 4 or 5 will give a short game, more than 8 will give a long and somewhat repetitive game))

#region Game State-related Variables
var previous_move: Move = null ##The Previous Move taken

var victory_points: int = 0: ##The No. Victory Points Blue has
	set = _set_victory_points 

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

var projects: Array[Project] = [null, null, null, null] ##All Projects left to be played

var project_effects: PackedStringArray = [] ##Unhandled Effects, as Strings, that come about after the Completion of certain Projects

var total_planned_cost: int = 0 ##The Total Planned Cost of all completed Projects
#endregion

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
	card.card_history.append("Drawn by %s" % get_player_name(team))
	
	if team == TEAM.COUNTRY:
		print("Country Team Drew Card: %s" % card.card_name)
		country_hand.append(card)
		card_drawn.emit(card)
		return card
	else:
		print("Jedburgh Team Drew Card: %s" % card.card_name)
		jedburgh_hand.append(card)
		card_drawn.emit(card)
		return card

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
	print("Revealed Card %s!" % card.card_name)
	revealed_cards.append(card)
	card.card_history.append("Revealed")

##Conceal a Card
func conceal_card(card: Card) -> void:
	assert(card in revealed_cards, "Card to be concealed not revealed")
	print("Concealed Card %s!" % card.card_name)
	revealed_cards.erase(card)
	card.card_history.append("Concealed")

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
	elif team == TEAM.JEDBURGH:
		assert(card in jedburgh_hand, "Card to be discarded by Jedburgh Player not in Jedburgh Player's hand")
		jedburgh_hand.erase(card)
	
	discard_pile.append(card)
	card.card_history.append("Discarded from hand of %s" % get_player_name(team))
	#Reveal Card after it is discarded
	if is_card_revealed(card) == false:
		reveal_card(card)

##Discard a Particular Action Card from a Particular Team Player's Network
##optionally enforcing whether to reveal or discard it
func discard_card_from_network(card: ActionCard, team: TEAM, enforce_conceal_reveal: bool) -> void:
	assert(card in get_flattened_network(team), "Action Card to be discarded not in Player's Network")
	
	#If we're enforcing the conceal_reveal rule, and the card is concealed, we
	#reveal it, but don't discard it, hence the return
	if enforce_conceal_reveal == true and is_card_concealed(card) == true:
		print("The Action Card is concealed, revealing instead of discarding!")
		card.card_history.append("Revealed instead of Discarded from Network of %s" % get_player_name(team))
		reveal_card(card)
		return
	
	if team == TEAM.COUNTRY:
		for stack: Array in country_network:
			for action_card: ActionCard in stack:
				if card == action_card:
					stack.erase(action_card)
					discard_pile.append(action_card)
					card.card_history.append("Discarded from Network of %s" % get_player_name(team))
	else:
		for stack: Array in jedburgh_network:
			for action_card: ActionCard in stack:
				if card == action_card:
					stack.erase(action_card)
					discard_pile.append(action_card)
					card.card_history.append("Discarded from Network of %s" % get_player_name(team))
	
	#Reveal Card after it is discarded, if it is concealed
	if is_card_concealed(card) == true:
		reveal_card(card)

##TODO Get all Possible Game Moves
func get_possible_moves() -> Array[Move]:
	#In the Setup Phase, the only Possible Moves are the Country Team placing down a Project Card
	#into the relevant slot
	if current_phase == PHASE.SETUP:
		return _get_project_select_possibilities()
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
				#Determine if can Build Network - need Action Card(s) in hand
				var has_action_cards: bool = false
				for c: Card in get_current_player_hand():
					if c is ActionCard:
						has_action_cards = true
						break
				
				if has_action_cards == true:
					var new_move: BuildNetworkMove = BuildNetworkMove.new()
					new_move.card_to_use = card
					operations_moves.append(new_move)
				
				#Determine if can Manage Network - only possible if Network has Action Cards
				if len(get_flattened_network(current_turn_team)) > 0:
					var new_move: ManageNetworkMove = ManageNetworkMove.new()
					new_move.card_to_use = card
					operations_moves.append(new_move)
				
				#Handle Degrade Network Function Aspect
				print("Getting possibilities of degrading network using Build/Manage/Degrade Network Card!")
				operations_moves.append_array(_get_degrade_network_possibilities(card))
			elif card.card_name == FUNCTION_INFLUENCE_HN_NAME:
				var new_move: InfluenceHostNationMove = InfluenceHostNationMove.new()
				new_move.card_to_use = card
				operations_moves.append(new_move)
				
				var all_action_cards: Array[ActionCard] = get_flattened_network(current_turn_team)
				for hand_card: Card in get_current_player_hand():
					if hand_card is ActionCard:
						all_action_cards.append(card as ActionCard)
				
				for action_card: ActionCard in all_action_cards:
					var new_move_with_action_card: InfluenceHostNationMove = InfluenceHostNationMove.new()
					
					new_move_with_action_card.card_to_use = card
					new_move_with_action_card.action_card_to_play_with = action_card
					
					operations_moves.append(new_move_with_action_card)
				
				#Handle aspect of using HN Influence if on own track and influence value > 0
				if get_hn_influence_team() == current_turn_team and get_hn_influence_value() > 0:
					#Add Possibilities of using the Card as a Degrade Network
					print("Getting possibilities of degrading network using Use HN Influence!")
					operations_moves.append_array(_get_degrade_network_possibilities(card))
					
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
	elif current_phase == PHASE.PROJECTS:
		var projects_moves: Array[Move] = []
		
		if EFFECT_ADD_VALUE_NAME in project_effects:
			for p: Project in projects:
				if p != null and (p.budget < 9 or p.time < 9) and p.is_project_complete() == false:
					projects_moves.append(AddProjectValueMove.new())
		
		if _must_projects_be_added() == true:
			projects_moves += _get_project_select_possibilities()
		
		return projects_moves
	
	return []

##TODO Carry out the Selected Move
func make_move(move: Move) -> void:
	if move is SelectProjectMove:
		assert(move.project_slot >= 0 and move.project_slot <= 3, "Incorrect Slot Index")
		assert(projects[move.project_slot] == null, "Setting a non-null Project")
		
		for p: Project in projects:
			if p != null:
				assert(p.project_card != move.project_card_to_select, "Project Card already used")
		
		var slot_names: PackedStringArray = ["A", "B", "C", "D"]
		
		print("SelectProjectMove Played")
		
		var new_project: Project = Project.new(move.project_card_to_select)
		projects[move.project_slot] = new_project
		
		print("Project Selected: %s, Put into Slot %s" % [move.project_card_to_select.card_name, slot_names[move.project_slot]])
		project_set.emit(new_project, move.project_slot)
		move.project_card_to_select.card_history.append("Selected as Project")
		
		if current_phase == PHASE.SETUP:
			if _must_projects_be_added() == true:
				print("Still some Unset Projects, staying in Setup Phase!")
			else:
				#If all cards set, Move onto Draw Cards Phase
				print("Moving onto Draw Cards Phase!")
				_transfer_to_phase(PHASE.DRAW_CARDS_JEDBURGH, TEAM.JEDBURGH)
		elif current_phase == PHASE.PROJECTS:
			if _must_projects_be_added() == true:
				print("Still some Unset Projects, staying in Projects Phase")
			elif EFFECT_ADD_VALUE_NAME in project_effects:
				print("Still unplayed Project Effects, staying in Projects Phase")
			else:
				print("Moving onto HN Influence Phase!")
				_transfer_to_phase(PHASE.HN_INFLUENCE, TEAM.NOBODY)
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
				
				for a: ActionCard in get_flattened_network(current_turn_team):
					discard_card_from_network(a, current_turn_team, false)
					discarded += 1
				
				print("Discarded %d Action Cards!" % discarded)
				
			else:
				if current_turn_team == TEAM.JEDBURGH:
					_transfer_to_phase(PHASE.MAINTAIN_NETWORK_JEDBURGH, TEAM.JEDBURGH)
				else:
					_transfer_to_phase(PHASE.MAINTAIN_NETWORK_COUNTRY, TEAM.COUNTRY)
		
		#If it is Jedburgh that drew a card, time for the Country Team to do so as well
		if current_phase == PHASE.DRAW_CARDS_JEDBURGH:
			_transfer_to_phase(PHASE.DRAW_CARDS_COUNTRY, TEAM.COUNTRY)
		#Otherwise, if it was the Country Team that drew a card, move onto Operations phase
		elif current_phase == PHASE.DRAW_CARDS_COUNTRY:
			print("Draw Cards Phase over!")
			
			#Determine who plays first in the Operations Phase
			if host_nation_influence < 0:
				print("Country Team plays first in Operations Phase!")
				_transfer_to_phase(PHASE.OPERATIONS_COUNTRY, TEAM.COUNTRY)
			else:
				print("Jedburgh Team plays first in Operations Phase!")
				_transfer_to_phase(PHASE.OPERATIONS_JEDBURGH, TEAM.JEDBURGH)
	elif move is MaintainNetworkMove:
		#If there are no cards in the Player's Hand, discard their Action Cards
		if len(get_current_player_hand()) == 0:
			print("%s had no cards in their hand, so discarded Action Cards from Network" % get_current_player_name())
			for c: ActionCard in get_flattened_network(current_turn_team):
				discard_pile.append(c)
			
			if current_turn_team == TEAM.COUNTRY:
				country_network = [[], [], [], []]
			else:
				jedburgh_network = [[], [], [], []]
		else:
			#Discard all Cards to be Discarded
			print("%s Discarded the following Cards:" % get_current_player_name())
			for discard: Card in move.cards_to_discard:
				print(discard.card_name)
				discard_card(discard, current_turn_team)
		
		if len(get_flattened_network(current_turn_team)) > 0:
			print("Previous Arrangement of Network: ")
			for c: Card in get_flattened_network(current_turn_team):
				print(c.card_name)
		
		if current_turn_team == TEAM.COUNTRY:
			country_network = move.new_network_order
			
			print("Country Player Maintained Network, moving onto Operations Phase!")
			
			#Determine who plays first in the Operations Phase
			if host_nation_influence < 0:
				print("Country Team plays first in Operations Phase!")
				_transfer_to_phase(PHASE.OPERATIONS_COUNTRY, TEAM.COUNTRY)
			else:
				print("Jedburgh Team plays first in Operations Phase!")
				_transfer_to_phase(PHASE.OPERATIONS_JEDBURGH, TEAM.JEDBURGH)
		else:
			jedburgh_network = move.new_network_order
			print("Jedburgh Player Maintained Network, moving onto Country Draw Cards Phase!")
			_transfer_to_phase(PHASE.DRAW_CARDS_COUNTRY, TEAM.COUNTRY)
		
		if len(get_flattened_network(current_turn_team)) > 0:
			print("New Arrangement of Network: ")
			for c: Card in get_flattened_network(current_turn_team):
				print(c.card_name)
	elif move is PassMove:
		print("%s Passes!" % get_current_player_name())
		
		if previous_move is PassMove:
			print("Previous Player also passed, moving onto Projects Phase!")
			_transfer_to_phase(PHASE.PROJECTS, TEAM.COUNTRY)
		else:
			if current_turn_team == TEAM.COUNTRY:
				_transfer_to_phase(PHASE.OPERATIONS_JEDBURGH, TEAM.JEDBURGH)
			else:
				_transfer_to_phase(PHASE.OPERATIONS_COUNTRY, TEAM.COUNTRY)
	elif move is InfluenceHostNationMove:
		var influence_change: int = move.get_influence_change()
		
		#Move HN Influence by corresponding change of influence
		if current_turn_team == TEAM.COUNTRY:
			host_nation_influence -= influence_change
		else:
			host_nation_influence += influence_change
		
		if move.action_card_to_play_with != null:
			print("%s plays Influence Host Nation with Action Card, for total of %d Influence Change!" % [get_current_player_name(), influence_change])
			move.card_to_use.card_history.append("Played by %s with an Action Card, for total value of %d" % [get_current_player_name(), influence_change])
			move.action_card_to_play_with.card_history.append("%s used Action Card with Influence Host Nation, for total influence change of %d" % [get_current_player_name(), influence_change])
			
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
		move.card_to_use.card_history.append("Played as an Action Card with Value %d" % move.value)
	elif move is BuildNetworkMove:
		print("%s playing Build Network!" % get_current_player_name())
		
		for card: ActionCard in move.action_cards_to_add:
			assert(card in get_current_player_hand(), "Action Card to add to Network not in player's hand")
		
		for i: int in range(len(move.action_cards_to_add)):
			get_current_player_hand().erase(move.action_cards_to_add[i])
			get_current_player_network()[move.stacks_to_add_to[i]].insert(move.indices_to_add_to[i], move.action_cards_to_add[i])
			move.action_cards_to_add[i].card_history.append("Added to Stack %s of Network of %s in Build Network Move" % [["A", "B", "C", "D"][move.indices_to_add_to[i]], get_current_player_name()])
			conceal_card(move.action_cards_to_add[i])
	elif move is ManageNetworkMove:
		print("%s playing Manage Network!" % get_current_player_name())
		
		assert(len(get_current_player_network()[move.stack_from]) > 0, "Stack to move Action Card from is empty")
		
		var moved_action_card: ActionCard = get_current_player_network()[move.stack_from][move.position_from]
		get_current_player_network()[move.stack_from].remove_at(move.position_from)
		get_current_player_network()[move.stack_to].append(moved_action_card)
		
		var slot_names: PackedStringArray = ["A", "B", "C", "D"]
		moved_action_card.card_history.append("In Manage Network Move, moved by %s from Slot %s to Slot %s" % [get_current_player_name(), slot_names[move.stack_from], slot_names[move.stack_to]])
	elif move is DegradeNetworkMove:
		print("%s playing Degrade Network!" % get_current_player_name())
		assert(is_card_revealed(move.enemy_card_to_discard) == true, "Enemy Card to Discard for Degrade Network is not Revealed")
		
		move.enemy_card_to_discard.card_history.append("%s Discarded Card from Network of %s via Degrade Network Move" % [get_current_player_name(), get_player_name(get_opposing_player())])
		discard_card_from_network(move.enemy_card_to_discard, get_opposing_player(), false)
	elif move is RevealMove:
		print("%s plays Reveal Move!" % get_current_player_name())
		
		for revealed: ActionCard in move.cards_to_reveal:
			reveal_card(revealed)
	elif move is ConcealMove:
		print("%s plays Conceal Move!" % get_current_player_name())
		
		for concealed: ActionCard in move.cards_to_conceal:
			conceal_card(concealed)
	elif move is AddProjectValueMove:
		print("%s plays Move to Add Project Value!" % get_current_player_name())
		assert(EFFECT_ADD_VALUE_NAME in project_effects, "Adding Value to Project without relevant effect being present")
		assert(move.project.is_project_complete() == false, "Addinv Value to Project that's already completed")
		
		if move.value == Project.VALUE.TIME:
			assert(move.project.time < 9, "Cannot add Value to Maximum Time of 9")
			print("Increasing Time Value!")
			move.project.time += 1
		else:
			assert(move.project.budget < 9, "Cannot add Value to Maximum Budget of 9")
			print("Increasing Budget Value!")
			move.project.budget += 1
		
		#Remove the String Name of the Add Value effect once a Value is added
		project_effects.remove_at(project_effects.find(EFFECT_ADD_VALUE_NAME))
		
		#Check whether we're staying Projects Phase or moving on
		_check_transfer_from_projects()

	#If the Move is Playing a Card in the Operations Phase, Discard the Card played and
	#give the next player their turn
	if move is PlayCardMove:
		if move.card_to_use is ActionCard:
			discard_card_from_network(move.card_to_use, current_turn_team, true)
		else:
			discard_card(move.card_to_use, current_turn_team)
		
		if current_phase == PHASE.OPERATIONS_COUNTRY:
			_transfer_to_phase(PHASE.OPERATIONS_JEDBURGH, TEAM.JEDBURGH)
		elif current_phase == PHASE.OPERATIONS_JEDBURGH:
			_transfer_to_phase(PHASE.OPERATIONS_COUNTRY, TEAM.COUNTRY)
	
	previous_move = move
	move_taken.emit(move)

##Count No. Active Projects
func _count_active_projects() -> int:
	var count: int = 0
	
	for p: Project in projects:
		if p != null and p.is_project_complete() == false:
			count += 1
	
	return count

##Transfer to a Phase, with a Specific Player's turn
func _transfer_to_phase(phase: PHASE, player: TEAM) -> void:
	current_phase = phase
	current_turn_team = player
	
	#If we're transferring to the Draw Cards Phase, and the Draw Pile is empty,
	#shuffle the Discard Pile and make it the new Draw Pile
	if phase == PHASE.DRAW_CARDS_JEDBURGH or phase == PHASE.DRAW_CARDS_COUNTRY:
		if len(draw_pile) == 0:
			print("Draw pile empty, returning discard pile!")
			
			for d: Card in discard_pile:
				draw_pile.append(d)
			draw_pile.shuffle()
			discard_pile = []
	#If we're transferring to the Projects Phase, do a one-time calculation of all
	#Projects
	elif phase == PHASE.PROJECTS:
		print("Updating Projects!")
		_update_projects()
	#If we're Transferring to the HN Influence Phase, do a onetime calculation of
	#HN Influence effects on Jedburgh Victory Points, then transfer to Turn End Phase
	elif phase == PHASE.HN_INFLUENCE:
		if get_hn_influence_team() == TEAM.JEDBURGH:
			victory_points += get_hn_influence_value()
		else:
			victory_points -= get_hn_influence_value()
		print("Transferring to Turn End Phase!")
		_transfer_to_phase(PHASE.TURN_END, TEAM.NOBODY)
	#If we're Transferring to Turn End Phase, do onetime set of checks
	elif phase == PHASE.TURN_END:
		#If there are no more projects to complete, transfer to the Game End Phase
		if projects_to_complete == 0:
			print("No Projects left to Complete, Transferring to Game End Phase!")
			_transfer_to_phase(PHASE.GAME_END, TEAM.NOBODY)
		else:
			for p: Project in projects:
				if p != null and p.budget > 0 and p.time < 9:
					p.time += 1
			print("Projects still left to play, transferring back to Draw Cards Phase!")
			print("\n")
			_transfer_to_phase(PHASE.DRAW_CARDS_JEDBURGH, TEAM.JEDBURGH)
	#If we're Transferring to Game End Phase, calculate Victory Type
	elif phase == PHASE.GAME_END:
		var ratio: float = float(victory_points) / float(total_planned_cost)
		print("Ratio of Victory Points to Total Planned Costs: %.2f" % ratio)
		
		if ratio < 2:
			print("This means that %s, The Country Team, is victorious!" % get_player_name(TEAM.COUNTRY))
		elif ratio >= 3.0:
			print("This means that %s, The Jedburgh Team, has won a Strategic Victory!" % get_player_name(TEAM.JEDBURGH))
		else:
			print("This means that %s, The Jedburgh Team, has won a Tactical Victory!" % get_player_name(TEAM.JEDBURGH))

##Update all Projects, per the Projects Phase's Rules
func _update_projects() -> void:
	var any_projects_completed: bool = false
	
	for project: Project in projects:
		if project != null and project.is_project_complete() == true:
			print("Project %s is complete, completing!" % project.project_card.card_name)
			_complete_project(project)
			any_projects_completed = true
	
	#If no Projects have Been Completed, move into HN Influence Phase immediately
	if any_projects_completed == false:
		print("No Projects Completed, moving onto HN Influence!")
		_transfer_to_phase(PHASE.HN_INFLUENCE, TEAM.NOBODY)

##Check whether to Transfer from the Projects Phase to the HN Influence Phase
func _check_transfer_from_projects() -> void:
	if EFFECT_ADD_VALUE_NAME in project_effects:
		print("Still unplayed Project Effects, staying in Projects Phase")
		return
	
	if _must_projects_be_added() == true:
		print("Projects must still be added, staying in Projects Phase!")
		return
	
	_update_projects()

##Check if Projects must be added - if there are less than 4 Active Projects
##AND there are more Projects to be Played than Active Projects, return True
func _must_projects_be_added() -> bool:
	#E.g. we have 3 Active Projects out of 4, with 5 projects left to play
	# 5 > 3, so yes, projects must be added
	
	#However, if we had e.g. 2 Active Projects out of 4, with only 2 Projects
	# left to play, 2 == 2, so projects must NOT be added
	
	var active_projects: int = _count_active_projects()
	if active_projects < 4 and (projects_to_complete > active_projects):
		return true
	
	return false

##Set Victory Points
func _set_victory_points(new_val: int) -> void:
	victory_points = maxi(0, new_val)

##Set Host Nation Influence
func _set_hn_influence(new_val: int) -> void:
	host_nation_influence = clampi(new_val, -4, 4)
	host_nation_influence_changed.emit(new_val)

##Get possible Degrade Network Possibilities
func _get_degrade_network_possibilities(card_to_play: Card) -> Array[DegradeNetworkMove]:
	print(get_current_player_name() + " is getting degrade network possibilities!")
	
	var possibilities: Array[DegradeNetworkMove] = []
	
	print("Opposing Player is %s" % get_player_name(get_opposing_player()))
	for stack: Array in get_opposing_player_network():
		if len(stack) > 0:
			var topmost_card: ActionCard = stack[-1]
			
			if is_card_revealed(topmost_card) == true:
				var new_degrade_move: DegradeNetworkMove = DegradeNetworkMove.new()
				new_degrade_move.card_to_use = card_to_play
				new_degrade_move.enemy_card_to_discard = topmost_card
				possibilities.append(new_degrade_move)
				topmost_card.card_history.append("Became a Candidate for the Discard Network Move")
	
	return possibilities

##Get possible Project Selection Possibilities
func _get_project_select_possibilities() -> Array[Move]:
	var possibilities: Array[Move] = []
	
	var all_projects: Array[ProjectCard] = [
		PROJECT_ADMINISTRATIVE_SYSTEM,
		PROJECT_FINANCE_SYSTEM,
		PROJECT_HIGHWAY_SYSTEM,
		PROJECT_LARGE_AIRPORT,
		PROJECT_LARGE_PORT,
		PROJECT_MINE,
		PROJECT_SMALL_AIRPORT,
		PROJECT_SMALL_PORT
	]
	
	#Get all Projects that haven't been played
	var possible_projects: Array[ProjectCard] = []
	for a: ProjectCard in all_projects:
		var valid_card: bool = true
		
		for b: Project in projects:
			if b != null and b.project_card == a:
				valid_card = false
				break
		
		if valid_card == true:
			possible_projects.append(a)
	
	#Go through all Possible Projects and, for each free slot index, append
	#a new SelectProjectMove corresponding to that project in that slot
	for p: ProjectCard in possible_projects:
		for s: int in range(len(projects)):
			if projects[s] == null:
				var new_move: SelectProjectMove = SelectProjectMove.new()
				new_move.project_card_to_select = p
				new_move.project_slot = s
				possibilities.append(new_move)
	
	return possibilities

##Handle Completing a Project and its effects
func _complete_project(project: Project) -> void:
	print("Completing Project: %s" % project.project_card.card_name)
	print("Victory Points of %s Before: %d" % [get_player_name(TEAM.JEDBURGH), victory_points])
	
	var completion_cost: int = project.budget * project.time
	
	var vic_points: int = completion_cost - project.get_planned_cost()
	
	var slot: int = projects.find(project)
	assert(slot != -1, "Project to Complete not in Game State's Projects")
	
	#If the Project Completed is a Mine, add only half (rounded up) Victory Points
	if project.project_card.card_name == PROJECT_MINE_NAME:
		victory_points += ceili(vic_points / 2.0)
		print("Victory Points of %s After: %d" % [get_player_name(TEAM.JEDBURGH), victory_points])
	#If the Project Completed is the Highway System, SUBTRACT Victory Points
	elif project.project_card.card_name == PROJECT_HIGHWAY_SYSTEM_NAME:
		victory_points -= vic_points
		print("Victory Points of %s After: %d" % [get_player_name(TEAM.JEDBURGH), victory_points])
	else:
		victory_points += vic_points
		print("Victory Points of %s After: %d" % [get_player_name(TEAM.JEDBURGH), victory_points])
	
	#If the Project Completed is Finance System, Move HN Influence by 1 to Country
	if project.project_card.card_name == PROJECT_FINANCE_SYSTEM_NAME:
		host_nation_influence -= 1
	
	#If the Project Completed is Administrative System, Move HN Influence by 2 to Country
	if project.project_card.card_name == PROJECT_FINANCE_SYSTEM_NAME:
		host_nation_influence -= 2
	
	#If the Project Completed is Small Airport or Port, add 1 Add Value Effect
	if project.project_card.card_name == PROJECT_SMALL_AIRPORT_NAME or project.project_card.card_name == PROJECT_SMALL_PORT_NAME:
		project_effects.append(EFFECT_ADD_VALUE_NAME)
	
	#If the Project Completed is Large Airport or Port, add 2 Add Value Effects
	if project.project_card.card_name == PROJECT_LARGE_AIRPORT_NAME or project.project_card.card_name == PROJECT_LARGE_PORT_NAME:
		project_effects.append(EFFECT_ADD_VALUE_NAME)
		project_effects.append(EFFECT_ADD_VALUE_NAME)
	
	projects[slot] = null
	project_completed.emit(slot)
	projects_to_complete -= 1
	total_planned_cost += project.get_planned_cost()
	_check_transfer_from_projects()
