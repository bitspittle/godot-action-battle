extends Node

var _attack_scene = preload("res://battle/actions/Attack.tscn")

func new_attack(source: Combatant) -> Attack:
	var attack = _attack_scene.instance()
	attack.source = source
	return attack
