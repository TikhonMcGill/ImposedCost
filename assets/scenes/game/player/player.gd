class_name Player
extends Node

##Class Representing a Player of Imposed Cost

signal player_move_taken(move: Move) ##Emitted when the Player takes a Particular Move

var my_team: GameState.TEAM ##The Team this Player belongs to
var game_state: GameState ##The Game State this Player operates within

##TODO Take the Player's Turn (how they do so depends on implementation)
func take_turn() -> void:
	pass

##Take a Move
func take_move(move: Move) -> void:
	player_move_taken.emit(move)

##Determine if it's the Current Player's Turn
func is_my_turn() -> bool:
	return game_state.current_turn_team == my_team
