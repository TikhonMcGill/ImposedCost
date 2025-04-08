class_name Card
extends Resource

##A Resource representing a Generic Card in Imposed Cost

@export var card_name: String ##Name of the Card
@export_multiline var card_description: String ##Description of the Card

@export var card_image: Texture2D ##The Image Texture of the Card

var card_history: PackedStringArray ##The History of what happened to the Card (mainly for debugging, but also kinda cool)
