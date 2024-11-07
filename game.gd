class_name Game
extends Resource

##A Resource representing the Game State

enum PLAYER {
	BLUE,
	RED
}

enum PHASE {
	DRAW_CARDS,
	OPERATIONS,
	PROJECTS,
	HN_INFLUENCE,
	TURN_END
}

@export var projects_to_complete: int = 4 ##No. Projects to Complete before Game Ends (determined by players - 4 or 5 will give a short game, more than 8 will give a long and somewhat repetitive game))

var blue_victory_points: int = 0 ##The No. Victory Points Blue has
var red_victory_points: int = 0 ##The No. Victory Points Red has

var draw_pile: Array ##The Draw Pile
var discard_pile: Array ##The Discard Pile

var host_nation_influence: int = 0 ##The Influence of each team in the Host Nation - negative = Red Influence, Positive = Blue Influence
