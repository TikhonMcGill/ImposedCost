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
	
	#If more than 5 Cards in Network, pick 2 random cards to discard from hand
	if len(game_state.get_flattened_network(my_team)) > 5:
		var first_card_to_discard: Card = game_state.get_team
	
	return null
