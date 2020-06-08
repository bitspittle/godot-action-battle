tool
extends Node2D

class_name Tracks

export var length: int = 128 setget _set_length

signal action_hit(action, side, level)

onready var _upper_track = $Upper
onready var _middle_track = $Middle
onready var _lower_track = $Lower
onready var _left_area = $HitLeft
onready var _right_area = $HitRight
onready var _left_area_shape = $HitLeft/Shape
onready var _right_area_shape = $HitRight/Shape

func enqueue_action(action: Action, side, level):
	var track: Track = null
	match level:
		Enums.Level.UPPER:
			track = _upper_track
		Enums.Level.MIDDLE:
			track = _middle_track
		Enums.Level.LOWER:
			track = _lower_track
			
	action.position.y = track.position.y
	action.position.x = -(length / 2)
	# TODO: Put speed constant somewhere more appropriate
	action.velocity.x = 100

	if (side == Enums.Side.LEFT):
		action.set_collision_layer(Constants.COLLISION_BIT_ACTION_LEFT)
	else:
		action.set_collision_layer(Constants.COLLISION_BIT_ACTION_RIGHT)
		action.position.x *= -1
		action.velocity.x *= -1

	self.add_child(action)

func cancel_actions_for(combatant: Combatant):
	for child in get_children():
		if child is Action:
			var action: Action = child
			if action.source == combatant:
				action.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_tracks()
	
	if not Engine.editor_hint:
		_upper_track.visible = false
		_middle_track.visible = false
		_lower_track.visible = false

func _set_length(value: int):
	length = value
	_update_tracks()
	
func _update_tracks():
	if not is_inside_tree():
		return
		
	_upper_track.position.y = -Constants.LEVEL_GAP
	_lower_track.position.y = -Constants.LEVEL_GAP
	
	_upper_track.length = length
	_middle_track.length = length
	_lower_track.length = length
	
	_left_area.position.x = -length / 2
	_right_area.position.x = length / 2
	
	var rect_left = _left_area_shape.get_shape()
	var rect_right = _right_area_shape.get_shape()
	
	rect_left.extents.y = Constants.LEVEL_GAP * 2
	rect_right.extents.y = Constants.LEVEL_GAP * 2

func _action_to_level(action: Action) -> int:
	if action.position.y == _middle_track.position.y:
		return Enums.Level.MIDDLE
	elif action.position.y == _upper_track.position.y:
		return Enums.Level.UPPER
	elif action.position.y == _lower_track.position.y:
		return Enums.Level.LOWER
	else:
		push_error("Unexpected action y position that doesn't match any track.")
		return Enums.Level.MIDDLE

func _emit_action_signal(action: Action, side: int) -> void:
	emit_signal("action_hit", action, side, _action_to_level(action))
	action.queue_free()

func _on_HitLeft_body_entered(action: Action):
	_emit_action_signal(action, Enums.Side.LEFT)


func _on_HitRight_body_entered(action: Action):
	_emit_action_signal(action, Enums.Side.RIGHT)
