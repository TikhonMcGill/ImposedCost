class_name Player
extends Node

##Class Representing a Player of Imposed Cost

signal player_move_taken(move: Move) ##Emitted when the Player takes a Particular Move

var my_team: GameState.TEAM ##The Team this Player belongs to
var my_game: GameState ##The Game State this Player operates within

##TODO Take the Player's Turn (how they do so depends on implementation)
func take_turn() -> void:
	pass

##Determine if it's the Current Player's Turn
func is_my_turn() -> bool:
	return my_game.current_turn_team == my_team
