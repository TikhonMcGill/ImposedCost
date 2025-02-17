extends Control

const GAME_PATH: String = "res://assets/scenes/game/game.tscn"

@onready var country_player_select: OptionButton = $PanelContainer/MarginContainer/VBoxContainer/CountryPlayerSelect
@onready var country_name_edit: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/CountryNameEdit

@onready var jedburgh_player_select: OptionButton = $PanelContainer/MarginContainer/VBoxContainer/JedburghPlayerSelect
@onready var jedburgh_name_edit: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/JedburghNameEdit

func _on_play_button_pressed():
	if country_name_edit.text == "":
		country_name_edit.text = "Country Team"
		return
	
	if jedburgh_name_edit.text == "":
		jedburgh_name_edit.text = "Jedburgh Team"
		return
	
	GameManager.country_team_player = country_player_select.selected
	GameManager.country_team_name = country_name_edit.text
	
	GameManager.jedburgh_team_player = jedburgh_player_select.selected
	GameManager.jedburgh_team_name = jedburgh_name_edit.text
	
	get_tree().change_scene_to_file(GAME_PATH)

func _select_country_player(index: int):
	pass

func _select_jedburgh_player(index : int):
	pass

func _on_country_player_select_item_selected(index: int) -> void:
	_select_country_player(index)

func _on_jedburgh_player_select_item_selected(index: int) -> void:
	_select_jedburgh_player(index)
