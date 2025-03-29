class_name Project
extends Resource

##A Resource representing an Imposed Cost Project that is in play

var time: int = 0 ##The Time Value of the Project, 0 at start
var budget: int = 0 ##The Budget Value of the Project, 0 at start
var project_card: ProjectCard ##The Project Card used as the Blueprint for the Project

func _init(_card: ProjectCard) -> void:
	project_card = _card

##Determine whether the Project is Complete
##Any Projects that meet or exceed Time AND Budget minimal values of their Card are Complete 
func is_project_complete() -> bool:
	return time >= project_card.min_time and budget >= project_card.min_budget

##Get the Project's Planned Cost, multiplying Min Budget and Time
func get_planned_cost() -> int:
	return project_card.min_budget * project_card.min_time
