class_name InfluenceHostNationMove
extends PlayCardMove

##A Move representing playing the "Influence Host Nation" part of the relevant Function Card

var action_card_to_play_with: ActionCard ##The ActionCard, if any, to play with the Function Card

##Calculate the amount by which HN Influence will Change, depending on
##whether or not an Action Card is played with this card
func get_influence_change() -> int:
	if action_card_to_play_with == null:
		return 1
	
	return 1 + action_card_to_play_with.value
