class_name RandomPlayer
extends Player

##A Player that takes their moves completely randomly

func take_turn() -> void:
	if is_my_turn() == false:
		return
	
	var moves: Array[Move] = my_game.get_possible_moves()
	player_move_taken.emit(moves.pick_random())
