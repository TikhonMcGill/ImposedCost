class_name ProjectContainer
extends PanelContainer

##A GUI Container representing an Imposed Cost Project

signal slot_selected(slot: int)

@onready var project_label: Label = $VBoxContainer/ProjectLabel

@onready var project_card_texture_rect: TextureRect = $VBoxContainer/ProjectCardTextureRect

@onready var time_label: Label = $VBoxContainer/TimeLabel
@onready var budget_label: Label = $VBoxContainer/BudgetLabel

@onready var select_button: Button = $VBoxContainer/SelectButton

var my_project: Project ##The Project this Container represents, updated per-frame

func _process(delta: float) -> void:
	if my_project != null:
		time_label.text = "Time: %d" % my_project.time
		budget_label.text = "Budget: %d" % my_project.budget
		project_label.text = my_project.project_card.card_name
		modulate = Color.WHITE
	else:
		time_label.text = "Time: COMPLETED"
		budget_label.text = "Budget: COMPLETED"
		project_label.text = "COMPLETED"
		modulate = Color.BLACK

##Set the Project Container's Project
func set_project(project: Project) -> void:
	my_project = project
	project_card_texture_rect.texture = project.project_card.card_image
	project_label.text = my_project.project_card.card_name
	select_button.hide()

func _on_select_button_pressed() -> void:
	slot_selected.emit(get_index())
