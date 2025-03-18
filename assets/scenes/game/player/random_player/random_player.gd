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
		move_to_take = construct_maintain_network_move()
	
	player_move_taken.emit(move_to_take)
	
	player_move_taken.emit(moves.pick_random())

##Construct a MaintainNetworkMove, if that is what the Random Player has to do
func construct_maintain_network_move() -> MaintainNetworkMove:
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
