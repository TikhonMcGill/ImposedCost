class_name ActionCardMove
extends PlayCardMove

##A Move Representing playing an Action Card, altering a Project's Time or Budget Value

enum CHANGE {
	DECREASE_TIME, ##Decrease Time Value of Project by 1 (if >0)
	INCREASE_TIME, ##Increase Time Value of Proejct by 1 (if not at maximum)
	INCREASE_BUDGET, ##Increase Budget Value of Project by 1 (if not at maximum) - Budget can only go up
} ##An Enum representing possible operations for each unit of the Played Action Card's Value

var value: int ##The Value of the Action Card being played (for easier calculations)

var changes: Array[CHANGE] ##The list of Changes intended to be done using this Action Card

var project: Project ##The Project to apply this Action Card to
