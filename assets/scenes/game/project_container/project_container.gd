class_name ProjectContainer
extends VBoxContainer

##A GUI Container representing an Imposed Cost Project

@onready var project_label: Label = $ProjectLabel ##Label for the Project Place (A, B, C or D)

@onready var project_card_texture_rect: TextureRect = $ProjectCardTextureRect ##TextureRect for Project Card's Image

@onready var project_name_label: Label = $ProjectNameLabel ##Label to write the name of the Project in
@onready var time_label: Label = $TimeLabel ##Label for the Project's Time Value
@onready var budget_label: Label = $BudgetLabel ##Label for the Project's Budget Value

var my_project: Project ##The Project this Container represents, updated per-frame

func _process(delta: float) -> void:
	project_name_label.text = my_project.project_card.card_name
	time_label.text = "Time: %d" % my_project.time
	budget_label.text = "Budget: %d" % my_project.budget

##Set the Project Container's Project
func set_project(project: Project) -> void:
	my_project = project
	project_card_texture_rect.texture = project.project_card.card_image
	modulate = Color.WHITE
