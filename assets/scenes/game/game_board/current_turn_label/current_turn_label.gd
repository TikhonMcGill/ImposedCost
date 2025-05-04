class_name CurrentTurnLabel
extends Label

##A Label showing the Current Turn in a Game of Imposed Cost

func show_current_turn(turn: int) -> void:
	text = "Current Turn: %d" % turn
