class_name CardSelector
extends PanelContainer

##UI Element responsible for a Human Player selecting a Card

signal card_selected(card: Card) ##Emitted when the Player selects one of the CardSelectElements in the UI

const CARD_SELECT_ELEMENT_SCENE: PackedScene = preload("uid://bav0yjk4fh1je")

@onready var card_select_element_container: HBoxContainer = $ScrollContainer/CardSelectElementContainer

##Populate the Card Selector's Elements with Card Select Elements, given
##an Array of Cards to work with
func populate_with_cards(cards: Array[Card]) -> void:
	#Clear the Container of any existing CardSelectElements
	for c: Node in card_select_element_container.get_children():
		c.queue_free()
	
	#Go through the Cards array, creating a Select Element for each card,
	#and connecting its "card_selected" signal to the _select_card signal of the Selector
	for card: Card in cards:
		var new_select_element: CardSelectElement = CARD_SELECT_ELEMENT_SCENE.instantiate()
		card_select_element_container.add_child(new_select_element)
		new_select_element.my_card = card
		new_select_element.card_selected.connect(_select_card.bind(card))

##Select a Particular Card
func _select_card(card: Card) -> void:
	card_selected.emit(card)
