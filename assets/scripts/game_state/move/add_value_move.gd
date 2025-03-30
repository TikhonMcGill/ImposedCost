class_name AddValueMove
extends Move

##A Move Representing adding 1 to any Value of a Project
##
##This Move is possible when a Project is played whose completion effect is adding
##1 or 2 to any value of any Project

var project: Project ##The Project to whose value to add 1 to
var value: Project.VALUE ##The Value to add 1 to
