class_name HumanPlayer
extends Player

##A Player that takes their moves using GUI

@onready var card_selector: CardSelector = $CardSelector ##The UI Element with which the Player will select Cards

func take_turn() -> void:
	if is_my_turn() == false:
		return
	
	var moves: Array[Move] = game_state.get_possible_moves()
	
	if len(moves) == 0:
		print("No moves for Random Player for %s, returning..." % game_state.get_player_name(my_team))
		return
	
	if game_state.must_projects_be_added() == true:
		var possibilities: Array[Card] = []
		
		for p: SelectProjectMove in game_state.get_project_select_possibilities():
			if p.project_card_to_select not in possibilities:
				possibilities.append(p.project_card_to_select)
		
		card_selector.populate_with_cards(possibilities)
		
		var chosen_project: ProjectCard = await card_selector.card_selected
		
		var move_to_take: SelectProjectMove = SelectProjectMove.new()
		
		for i in range(game_state.projects.size()):
			if game_state.projects[i] == null:
				move_to_take.project_slot = i
				break
		
		move_to_take.project_card_to_select = chosen_project
		
		take_move(move_to_take)
		
	
	#var move_to_take: Move = moves.pick_random()
	#
	#if move_to_take is MaintainNetworkMove:
		#move_to_take = _construct_maintain_network_move()
	#elif move_to_take is ActionCardMove:
		#move_to_take = _construct_action_card_move(move_to_take.card_to_use)
	#elif move_to_take is RevealMove:
		#move_to_take = _construct_reveal_move(move_to_take.card_to_use)
	#elif move_to_take is ConcealMove:
		#move_to_take = _construct_conceal_move(move_to_take.card_to_use)
	#elif move_to_take is BuildNetworkMove:
		#move_to_take = _construct_build_network_move(move_to_take.card_to_use)
	#elif move_to_take is ManageNetworkMove:
		#move_to_take = _construct_manage_network_move(move_to_take.card_to_use)
	#elif move_to_take is AddProjectValueMove:
		#move_to_take = _construct_add_project_value_move()
	#
	#player_move_taken.emit(move_to_take)

##Pick a Random Project that isn't completed
func _pick_random_incomplete_project(action_card_move: bool = false) -> Project:
	var chosen_project: Project = game_state.projects.pick_random()
	
	while chosen_project == null or (action_card_move == false and chosen_project.is_project_complete() == true):
		chosen_project = game_state.projects.pick_random()
	
	return chosen_project

##Construct a MaintainNetworkMove, if that is what the Random Player chose to do
func _construct_maintain_network_move() -> MaintainNetworkMove:
	var cards_to_discard: Array[Card] = []
	var my_hand: Array[Card] = game_state.get_player_hand(my_team)
	
	#If more than 5 Cards in Network, pick 2 random cards to discard from hand
	#(COUNTING BASE)
	if len(game_state.get_flattened_network(my_team)) > 4:
		var first_card_to_discard: Card = my_hand.pick_random()
		
		var second_card_to_discard: Card = my_hand.pick_random()
		while second_card_to_discard == first_card_to_discard:
			second_card_to_discard = my_hand.pick_random()
		
		cards_to_discard = [first_card_to_discard, second_card_to_discard]
	elif len(game_state.get_flattened_network(my_team)) > 0:
		var card_to_discard: Card = my_hand.pick_random()
		cards_to_discard = [card_to_discard]
	
	#With 50% Chance, reorganize whole network
	var my_new_network_order: Array = game_state.get_player_network(my_team)
	
	if randi() % 2 == 0:
		my_new_network_order = [[], [], [], []]
		
		var flattened_network: Array[ActionCard] = game_state.get_flattened_network(my_team)
		flattened_network.shuffle()
		
		for f: ActionCard in flattened_network:
			my_new_network_order.pick_random().append(f)
	
	var new_move: MaintainNetworkMove = MaintainNetworkMove.new()
	
	new_move.cards_to_discard = cards_to_discard
	new_move.new_network_order = my_new_network_order
	
	return new_move

##Construct an ActionCardMove, if that is what the Random Player chose to do
func _construct_action_card_move(action_card: Card) -> ActionCardMove:
	var chosen_project: Project = _pick_random_incomplete_project(true)
	
	var final_move: ActionCardMove = ActionCardMove.new()
	final_move.card_to_use = action_card
	
	if action_card is ActionCard:
		final_move.value = action_card.value
	elif action_card.card_name == GameState.FUNCTION_INFLUENCE_HN_NAME:
		final_move.value = game_state.get_hn_influence_value()
	
	var simulated_value: int = final_move.value
	
	final_move.project = chosen_project
	
	#Construct possible changes
	var simulated_time: int = chosen_project.time
	var simulated_budget: int = chosen_project.budget
	
	var possible_changes: Array[ActionCardMove.CHANGE] = []
	
	var decreases: int = 0
	var increases: int = 0
	
	for time_decrease: int in range(min(simulated_time, final_move.value)):
		possible_changes.append(ActionCardMove.CHANGE.DECREASE_TIME)
		decreases += 1
	
	for time_increase: int in range(min(9 - simulated_time, final_move.value)):
		possible_changes.append(ActionCardMove.CHANGE.INCREASE_TIME)
		increases += 1
	
	for budget_increase: int in range(min(9 - simulated_budget, final_move.value)):
		possible_changes.append(ActionCardMove.CHANGE.INCREASE_BUDGET)
	
	possible_changes.shuffle()
	
	#Whether we're increasing the time or not, -1 = unset, 0 = no, 1 = yes
	var increasing_time: int = -1
	
	#To ensure that the Random Player doesn't enter a dead end (e.g. it wants
	#to decrease time 3 times, but only is able to do so twice), choose the
	#direction of time increase/decrease which is larger - if tied, pick random
	if increases > decreases:
		increasing_time = 1
	elif decreases > increases:
		increasing_time = 0
	
	print("Decreases: %d, Increases: %d" % [decreases, increases])
	
	#No. Changes made
	var changes_constructed: int = 0
	
	#Construct the Possible Change Combinations
	while changes_constructed < simulated_value:
		var chosen_change: ActionCardMove.CHANGE = possible_changes.pop_front()
		
		if increasing_time == -1:
			if chosen_change == ActionCardMove.CHANGE.INCREASE_TIME:
				increasing_time = 1
				final_move.changes.append(chosen_change)
				changes_constructed += 1
			elif chosen_change == ActionCardMove.CHANGE.DECREASE_TIME:
				increasing_time = 0
				final_move.changes.append(chosen_change)
				changes_constructed += 1
		else:
			if chosen_change == ActionCardMove.CHANGE.DECREASE_TIME and increasing_time == 0:
				final_move.changes.append(chosen_change)
				changes_constructed += 1
			elif chosen_change == ActionCardMove.CHANGE.INCREASE_TIME and increasing_time == 1:
				final_move.changes.append(chosen_change)
				changes_constructed += 1
		
		if chosen_change == ActionCardMove.CHANGE.INCREASE_BUDGET:
			final_move.changes.append(chosen_change)
			changes_constructed += 1
	
	return final_move

##Construct a RevealMove, if that is what the Random Player chose to do
func _construct_reveal_move(card: Card) -> RevealMove:
	var possible_cards_to_reveal: Array[ActionCard] = game_state.get_flattened_network(game_state.get_opposing_player()).filter(game_state.is_card_concealed)
	possible_cards_to_reveal.shuffle()
	
	var cards_to_reveal: Array[ActionCard] = []
	if len(possible_cards_to_reveal) == 1:
		cards_to_reveal = [possible_cards_to_reveal[0]]
	else:
		cards_to_reveal = [possible_cards_to_reveal[0], possible_cards_to_reveal[1]]
	
	var new_reveal_move: RevealMove = RevealMove.new()
	new_reveal_move.card_to_use = card
	new_reveal_move.cards_to_reveal = cards_to_reveal
	
	return new_reveal_move

##Construct a ConcealMove, if that is what the Random Player chose to do
func _construct_conceal_move(card: Card) -> ConcealMove:
	var possible_cards_to_conceal: Array[ActionCard] = game_state.get_flattened_network(my_team).filter(game_state.is_card_revealed)
	possible_cards_to_conceal.shuffle()
	
	var cards_to_conceal: Array[ActionCard] = []
	if len(possible_cards_to_conceal) == 1:
		cards_to_conceal = [possible_cards_to_conceal[0]]
	else:
		cards_to_conceal = [possible_cards_to_conceal[0], possible_cards_to_conceal[1]]
	
	var new_conceal_move: ConcealMove = ConcealMove.new()
	new_conceal_move.card_to_use = card
	new_conceal_move.cards_to_conceal = cards_to_conceal
	
	return new_conceal_move

##Construct a BuildNetwork Move, if that is what the Random Player chose to do
func _construct_build_network_move(card: Card) -> BuildNetworkMove:
	var final_move: BuildNetworkMove = BuildNetworkMove.new()
	final_move.card_to_use = card
	
	var action_cards_in_hand: Array[ActionCard] = []
	for c: Card in game_state.get_player_hand(my_team):
		if c is ActionCard:
			action_cards_in_hand.append(c)
	action_cards_in_hand.shuffle()
	
	var builds_to_make: int = mini(randi() % 2, len(action_cards_in_hand))
	for b in range(builds_to_make):
		#Choose Random Action Card
		var chosen_action_card: ActionCard = action_cards_in_hand.pop_front()
		
		#Choose a Random Stack to move cards into
		var chosen_stack: int = randi() % 4
		
		#Choose a Random Index to insert card into in stack
		var chosen_index: int = randi() % max(1, len(game_state.get_player_network(my_team)[chosen_stack]))
		
		final_move.action_cards_to_add.append(chosen_action_card)
		final_move.stacks_to_add_to.append(chosen_stack)
		final_move.indices_to_add_to.append(chosen_index)
	
	return final_move

##Construct a ManageNetwork Move, if that is what the Random Player chose to do
func _construct_manage_network_move(card: Card) -> ManageNetworkMove:
	var final_move: ManageNetworkMove = ManageNetworkMove.new()
	final_move.card_to_use = card
	
	var chosen_stack: int = randi() % 4
	while len(game_state.get_player_network(my_team)[chosen_stack]) == 0:
		chosen_stack = randi() % 4
	
	var chosen_position: int = randi() % len(game_state.get_player_network(my_team)[chosen_stack])
	
	final_move.stack_from = chosen_stack
	final_move.position_from = chosen_position
	final_move.stack_to = randi() % 4
	
	
	return final_move

##Construct an AddProjectValueMove, if that is what the Random Player chose to do
func _construct_add_project_value_move() -> AddProjectValueMove:
	var chosen_project: Project = _pick_random_incomplete_project()
	
	var possible_values: Array[Project.VALUE] = []
	
	if chosen_project.time < 9:
		possible_values.append(Project.VALUE.TIME)
	
	if chosen_project.budget < 9:
		possible_values.append(Project.VALUE.BUDGET)
	
	var final_move: AddProjectValueMove = AddProjectValueMove.new()
	final_move.project = chosen_project
	final_move.value = possible_values.pick_random()
	
	return final_move
