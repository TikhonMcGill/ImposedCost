class_name ProjectContainerContainer
extends HBoxContainer

##A Container representing an Imposed Cost Game's Projects, via ProjectContainers

@export var project_containers: Array[ProjectContainer]

##Set a Project Container's Project In a Specific Slot
func set_container_project(project: Project, slot: int) -> void:
	project_containers[slot].set_project(project)

##Complete a Project Container, implying it is completed
func _complete_project_container(slot: int) -> void:
	project_containers[slot].my_project = null
