class_name Project
extends Resource

##A Resource representing an Imposed Cost Project that is in play

var time: int ##The Time Value of the Project
var budget: int ##The Budget Value of the Project
var project_card: ProjectCard ##The Project Card used as the Blueprint for the Project

func _init(min_time: int, min_budget: int, _card: ProjectCard) -> void:
	time = min_time
	budget = min_budget
	project_card = _card
