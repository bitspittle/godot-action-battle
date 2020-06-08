extends Node

var _brief_text_scene = preload("res://ui/BriefText.tscn")
var _attack_scene = preload("res://battle/actions/Attack.tscn")

func new_attack(source: Combatant) -> Attack:
	var attack = _attack_scene.instance()
	attack.source = source
	return attack

func new_brief_text(text: String) -> BriefText:
	var brief_text = _brief_text_scene.instance()
	brief_text.text = text
	return brief_text
