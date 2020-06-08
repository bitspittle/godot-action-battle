extends Position2D

class_name Combatant

# warning-ignore:unused_signal
signal action_emitted(action, level) # emitted by children
signal cancel_actions(combatant)
signal combatant_died(combatant)

export var max_health = 10.0
var _curr_health = max_health setget _set_curr_health

onready var health_bar = $HealthBar
onready var brief_text_area = $Pivot/BriefTextArea

func _ready():
	_curr_health = max_health

func _process(_delta):
	if health_bar == null: return
	health_bar.percent = _curr_health / max_health
	
func _add_brief_text(text: String):
	var brief_text = Factory.new_brief_text(text)
	brief_text_area.add_child(brief_text)

func _set_curr_health(value):
	_curr_health = max(0, value)
	
func _cancel_my_actions():
	emit_signal("cancel_actions", self)

func handle_attacked(damage: int, level: int) -> void:
	_handle_attacked(damage, level)
	_curr_health = max(0, _curr_health)
	if _curr_health == 0:
		emit_signal("combatant_died", self)
	
func _handle_attacked(damage: int, _level: int) -> void:
	_curr_health -= damage
	_add_brief_text(String(damage))

func _handle_missed() -> void:
	_add_brief_text("MISS")
