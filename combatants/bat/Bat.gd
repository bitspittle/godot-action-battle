extends Combatant

class_name Bat

const ATTACK_PERIOD = 2.0
const ATTACK_VARIATION = 0.5
const MOVE_PERIOD = 1.5
const MOVE_VARIATION = 1.0

var TEXTURE_BITE = load("res://assets/images/bite16x16.png")

var _level = Enums.Level.MIDDLE
onready var _sprite: Sprite = $Sprite
onready var _attack_timer: Timer = $AttackTimer
onready var _move_timer: Timer = $MoveTimer

var _target_pos = Vector2.ZERO

func _ready():
	_choose_random_level()
	_reset_attack_timer()
	_reset_move_timer()

func _reset_attack_timer():
	_attack_timer.start(rand_range(ATTACK_PERIOD - ATTACK_VARIATION, ATTACK_PERIOD + ATTACK_VARIATION))

func _reset_move_timer():
	_move_timer.start(rand_range(MOVE_PERIOD - MOVE_VARIATION, MOVE_PERIOD + MOVE_VARIATION))

func _choose_random_level():
	var old_level = _level
	while (old_level == _level):
		_level = Enums.random_level()

	var delta = (_sprite.texture.get_size().y * _sprite.scale.y)
	var y = 0

	match _level:
		Enums.Level.UPPER:
			y = -delta
		Enums.Level.LOWER:
			y = delta

	_target_pos.y = y
	
func _physics_process(delta):
	var distance = _target_pos - _sprite.position
	var distance_len2 = distance.length_squared()
	if (distance_len2 > 0):
		_sprite.position = _sprite.position.move_toward(_target_pos, (distance_len2) * delta)

func _on_AttackTimer_timeout():
	var attack = Factory.new_attack(self)
	attack.texture = TEXTURE_BITE
	emit_signal("action_emitted", attack, _level)
	_reset_attack_timer()

func _on_MoveTimer_timeout():
	_choose_random_level()
	_reset_move_timer()
	
func _handle_attacked(damage: int, level: int) -> void:
	if (_level == level):
		._handle_attacked(damage, level)
		_on_MoveTimer_timeout() # Force the bat to move now


