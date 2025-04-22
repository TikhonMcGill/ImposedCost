class_name CardSelectElement
extends VBoxContainer

##UI Element responsible for a Single Selectable Card

signal card_selected(card: Card) ##Emitted when the Card is selected

var my_card: Card: set = _set_card

@onready var card_container: CardContainer = $CardContainer

##Set this Select Element's Card (which sets the CardContainer's card as well)
func _set_card(card: Card) -> void:
	card_container.my_card = card
	my_card = card

##Emit card_selected with this card
func _select_card() -> void:
	assert(my_card != null, "Card Select Element's Card null when selected")
	card_selected.emit(my_card)
