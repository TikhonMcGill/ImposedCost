class_name HumanPlayer
extends Player

##A Player that takes their moves using GUI

func take_turn() -> void:
	if is_my_turn() == false:
		return
	
	var moves: Array[Move] = game_state.get_possible_moves()
	
	if len(moves) == 0:
		print("No moves for Human Player for %s, returning..." % game_state.get_player_name(my_team))
		return
