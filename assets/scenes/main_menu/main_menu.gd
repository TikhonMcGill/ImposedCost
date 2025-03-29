extends Control

const GAME_PATH: String = "res://assets/scenes/game/game.tscn"

@onready var country_player_select: OptionButton = $PanelContainer/MarginContainer/VBoxContainer/CountryPlayerSelect
@onready var country_name_edit: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/CountryNameEdit

@onready var jedburgh_player_select: OptionButton = $PanelContainer/MarginContainer/VBoxContainer/JedburghPlayerSelect
@onready var jedburgh_name_edit: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/JedburghNameEdit

@onready var projects_count_spin_box: SpinBox = $PanelContainer/MarginContainer/VBoxContainer/ProjectsCountSpinBox

func _ready() -> void:
	_populate_settings()

func _on_play_button_pressed() -> void:
	if country_name_edit.text == "":
		country_name_edit.text = "Country Team"
		return
	
	if jedburgh_name_edit.text == "":
		jedburgh_name_edit.text = "Jedburgh Team"
		return
	
	_set_settings()
	GameManager.save_settings()
	
	get_tree().change_scene_to_file(GAME_PATH)

#Populate the UI Based on Game Settings
func _populate_settings() -> void:
	country_player_select.selected = GameManager.settings.country_team_player
	country_name_edit.text = GameManager.settings.country_team_name
	
	jedburgh_player_select.selected = GameManager.settings.jedburgh_team_player
	jedburgh_name_edit.text = GameManager.settings.jedburgh_team_name
	
	projects_count_spin_box.value = GameManager.settings.projects_to_complete

#Set Game Settings based on UI
func _set_settings() -> void:
	GameManager.settings.country_team_player = country_player_select.selected
	GameManager.settings.country_team_name = country_name_edit.text
	
	GameManager.settings.jedburgh_team_player = jedburgh_player_select.selected
	GameManager.settings.jedburgh_team_name = jedburgh_name_edit.text
	
	GameManager.settings.projects_to_complete = projects_count_spin_box.value

func _select_country_player(index: int) -> void:
	pass

func _select_jedburgh_player(index : int) -> void:
	pass

func _on_country_player_select_item_selected(index: int) -> void:
	_select_country_player(index)

func _on_jedburgh_player_select_item_selected(index: int) -> void:
	_select_jedburgh_player(index)
