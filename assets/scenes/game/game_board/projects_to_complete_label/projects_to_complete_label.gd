class_name ProjectsToCompleteLabel
extends Label

##Label showing no. Projects left to complete in a game of Imposed Cost

func update_projects_left(projects: int) -> void:
	text = "Projects to Complete: %d" % projects
