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
