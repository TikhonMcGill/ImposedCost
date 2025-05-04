class_name VictoryPointsLabel
extends Label

##Label showing Jedburgh Player's Victory Points in a Game of Imposed Cost

func show_victory_points(vps: int) -> void:
	text = "%s's Victory Points: %d" % [GameManager.settings.jedburgh_team_name, vps]
