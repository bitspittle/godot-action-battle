extends Node2D

var player_scene = preload("res://combatants/player/Player.tscn")
var bat_scene = preload("res://combatants/bat/Bat.tscn")

onready var tracks: Tracks = $Tracks

var _combatants: Array

func _refresh_combatants():
	_combatants = [$CombatantLeft, $CombatantRight]

func _ready():
	_refresh_combatants()
	_replace_combatant(Enums.Side.LEFT, player_scene.instance())
	_replace_combatant(Enums.Side.RIGHT, bat_scene.instance())
	_refresh_combatants()

func _replace_combatant(side, new_combatant: Node2D):
	var old_combatant: Combatant = _combatants[side]
	var index = old_combatant.get_index()
	var parent = old_combatant.get_parent()
	parent.remove_child(old_combatant)
	old_combatant.call_deferred("free")

	parent.add_child(new_combatant)
	parent.move_child(new_combatant, index)

	new_combatant.set_name(old_combatant.get_name())
	new_combatant.set_position(old_combatant.get_position())
	new_combatant.connect("action_emitted", self, "_handle_action")
	new_combatant.connect("cancel_actions", self, "_handle_cancel_actions")
	new_combatant.connect("combatant_died", self, "_handle_combatant_died")

func _handle_action(action: Action, level: int):
	var side = Enums.Side.LEFT
	if action.source == _combatants[Enums.Side.RIGHT]:
		side = Enums.Side.RIGHT

	tracks.enqueue_action(action, side, level)

func _handle_cancel_actions(combatnat: Combatant):
	tracks.cancel_actions_for(combatnat)

func _handle_combatant_died(combatant: Combatant):
	print(combatant.get_name(), " is dead")
	get_tree().quit()
	

func _on_Tracks_action_hit(action: Action, side: int, level: int) -> void:
	var combatant = _combatants[side]
	action.act_on(combatant, level)
	
