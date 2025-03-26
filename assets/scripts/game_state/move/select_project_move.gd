class_name SelectProjectMove
extends Move

##Move representing a Country Player selecting a Project to add to one of the 4 Boxes

var project_card_to_select: ProjectCard ##The Project Card to select for the Project
var project_slot: int ##The Project Slot (0 to 3, representing A to D)
