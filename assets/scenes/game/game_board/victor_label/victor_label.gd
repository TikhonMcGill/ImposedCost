extends Label
class_name VictorLabel

##Label which shows the text of the Winner of an Imposed Cost Game

func show_winner_text(_ratio: float, _text: String) -> void:
	text = _text
	show()
