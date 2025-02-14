class_name Player
extends Node

##Class Representing a Player of Imposed Cost

signal player_move_taken(move: Move) ##Emitted when the Player takes a Particular Move

var my_team: GameState.TEAM ##The Team this Player belongs to

##TODO Take the Player's Turn (how they do so depends on implementation)
func take_turn() -> void:
	pass
