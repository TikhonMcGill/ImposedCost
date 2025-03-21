class_name RandomPlayer
extends Player

##A Player that takes their moves completely randomly

func take_turn() -> void:
	if is_my_turn() == false:
		return
	
	var moves: Array[Move] = game_state.get_possible_moves()
	
	if len(moves) == 0:
		print("No moves for Random Player, returning...")
		return
	
	var move_to_take: Move = moves.pick_random()
	
	if move_to_take is MaintainNetworkMove:
		move_to_take = _construct_maintain_network_move()
	elif move_to_take is ActionCardMove:
		move_to_take = _construct_action_card_move(move_to_take.card_to_use)
	elif move_to_take is RevealMove:
		move_to_take = _construct_reveal_move(move_to_take.card_to_use)
	
	player_move_taken.emit(move_to_take)

##Pick a Random Project that isn't completed
func _pick_random_incomplete_project() -> Project:
	var chosen_project: Project = game_state.projects.pick_random()
	
	while chosen_project.is_project_complete() == true:
		chosen_project = game_state.projects.pick_random()
	
	return chosen_project

##Construct a MaintainNetworkMove, if that is what the Random Player chose to do
func _construct_maintain_network_move() -> MaintainNetworkMove:
	var cards_to_discard: Array[Card] = []
	var my_hand: Array[Card] = game_state.get_player_hand(my_team)
	
	#If more than 5 Cards in Network, pick 2 random cards to discard from hand
	if len(game_state.get_flattened_network(my_team)) > 5:
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
func _construct_action_card_move(action_card: ActionCard) -> ActionCardMove:
	var chosen_project: Project = _pick_random_incomplete_project()
	
	var final_move: ActionCardMove = ActionCardMove.new()
	final_move.card_to_use = action_card
	final_move.value = action_card.value
	final_move.project = chosen_project
	
	#Construct possible changes
	var simulated_time: int = chosen_project.time
	var simulated_budget: int = chosen_project.budget
	
	var possible_changes: Array[ActionCardMove.CHANGE] = []
	
	for time_decrease: int in range(min(simulated_time, final_move.value)):
		possible_changes.append(ActionCardMove.CHANGE.DECREASE_TIME)
	
	for time_increase: int in range(min(simulated_time - 9, final_move.value)):
		possible_changes.append(ActionCardMove.CHANGE.INCREASE_TIME)
	
	for budget_increase: int in range(min(simulated_budget - 9, final_move.value)):
		possible_changes.append(ActionCardMove.CHANGE.INCREASE_BUDGET)
	
	possible_changes.shuffle()
	
	#Whether we're increasing the time or not, -1 = unset, 0 = no, 1 = yes
	var increasing_time: int = -1
	
	#Construct the Possible Change Combinations
	for x in range(action_card.value):
		var chosen_change: ActionCardMove.CHANGE = possible_changes.pop_front()
		
		if increasing_time == -1:
			if chosen_change == ActionCardMove.CHANGE.INCREASE_TIME:
				increasing_time = 1
				final_move.changes.append(chosen_change)
			elif chosen_change == ActionCardMove.CHANGE.DECREASE_TIME:
				increasing_time = 0
				final_move.changes.append(chosen_change)
		else:
			if chosen_change == ActionCardMove.CHANGE.DECREASE_TIME and increasing_time == 0:
				final_move.changes.append(chosen_change)
			elif chosen_change == ActionCardMove.CHANGE.INCREASE_TIME and increasing_time == 1:
				final_move.changes.append(chosen_change)
		
		if chosen_change == ActionCardMove.CHANGE.INCREASE_BUDGET:
			final_move.changes.append(chosen_change)
	
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
