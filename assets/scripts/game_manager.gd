extends Node

#Singleton

enum PLAYER{
	HUMAN,
	RANDOM,
	UTILITY,
	MINIMAX
} #Player Types

var country_team_player: PLAYER #The Player Type of the Country Team
var country_team_name: String #The Name of the Country Team Player

var jedburgh_team_player: PLAYER #The Player Type of the Jedburgh Team
var jedburgh_team_name: String #The Name of the Jedburgh Team Player
