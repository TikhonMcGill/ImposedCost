class_name HumanPlayer
extends Player

##A Player that takes their moves using GUI

@onready var card_selector: CardSelector = $CardSelector ##The UI Element with which the Player will select Cards

@onready var drawn_card_label: Label = $VBoxContainer/DrawnCardLabel
@onready var draw_card_button: Button = $VBoxContainer/DrawCardButton

func take_turn() -> void:
	if is_my_turn() == false:
		return
	
	var moves: Array[Move] = game_state.get_possible_moves()
	
	if len(moves) == 0:
		print("No moves for Human Player for %s, returning..." % game_state.get_player_name(my_team))
		return
	
	card_selector.hide()
	drawn_card_label.hide()
	draw_card_button.hide()
	
	if game_state.must_projects_be_added() == true:
		var possibilities: Array[Card] = []
		
		for p: SelectProjectMove in game_state.get_project_select_possibilities():
			if p.project_card_to_select not in possibilities:
				possibilities.append(p.project_card_to_select)
		
		card_selector.show()
		card_selector.populate_with_cards(possibilities)
		
		var chosen_project: ProjectCard = await card_selector.card_selected
		
		var move_to_take: SelectProjectMove = SelectProjectMove.new()
		
		for i in range(game_state.projects.size()):
			if game_state.projects[i] == null:
				move_to_take.project_slot = i
				break
		
		move_to_take.project_card_to_select = chosen_project
		
		take_move(move_to_take)
	elif game_state.current_phase == GameState.PHASE.DRAW_CARDS_COUNTRY or game_state.current_phase == GameState.PHASE.DRAW_CARDS_JEDBURGH:
		print("SHOWING DRAW CARD BUTTON!")
		draw_card_button.show()

func _on_draw_card_button_pressed() -> void:
	take_move(DrawCardMove.new())
	var card: Card = await game_state.card_drawn
	
	drawn_card_label.text = "Drew Card: %s" % game_state.get_player_hand(my_team)[-1].card_name
	drawn_card_label.show()
