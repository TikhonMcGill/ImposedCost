class_name GameSettings
extends Resource

##A Resource Representing Game Settings

enum PLAYER{
	HUMAN, ##A Player controlled by a Human, through a GUI
	RANDOM, ##A Player that, out of Possible Moves, takes a Random One
	UTILITY, ##A Player that, out of Possible Moves, takes one which produces a future Game State with the highest Utility
	MINIMAX ##A Player that uses Minimax Search to determine the best move
} #Player Types

@export var country_team_player: PLAYER = PLAYER.HUMAN ##The Player Type of the Country Team
@export var country_team_name: String = "Country Team" ##The Name of the Country Team Player

@export var jedburgh_team_player: PLAYER = PLAYER.HUMAN ##The Player Type of the Jedburgh Team
@export var jedburgh_team_name: String = "Jedburgh Team" ##The Name of the Jedburgh Team Player
