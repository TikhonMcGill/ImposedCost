class_name CardContainer
extends PanelContainer

##A UI Object representing a single Card

var my_card: Card: set = _set_card

@onready var card_name_label: Label = $VBoxContainer/CardNameLabel
@onready var card_texture_rect: TextureRect = $VBoxContainer/CardTextureRect
@onready var card_description_label: Label = $VBoxContainer/CardDescriptionLabel

##Set the Container's Card
func _set_card(card: Card) -> void:
	card_name_label.text = card.card_name
	card_texture_rect.texture = card.card_image
	card_description_label.text = card.card_description
	
	my_card = card
