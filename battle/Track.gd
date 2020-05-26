tool
extends Node2D

class_name Track

# warning-ignore:unused_class_variable
export var length: int = 128 setget _set_length

func _ready():
	_set_length(length)
	
func _set_length(value: int):
	length = value
	var line = $Line2D
	if (line != null):
		var half_length = value / 2
		line.points[0].x = -half_length
		line.points[1].x = half_length
