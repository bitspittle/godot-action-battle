extends Action

class_name Attack

var damage = 1

func act_on(target: Combatant, level: int) -> void:
	target.handle_attacked(damage, level)
