extends Combatant

class_name Player

enum State {
	IDLE,
	CHANGING_STANCE,
	PREPARE_STRIKE,
	CHARGING_STRIKE,
	STRIKE,
	DEFENDING,
	RECOVERING,
}

export var max_energy = 100.0
var curr_energy = 100.0

var READY_STANCE = Stances.create_ready_stance()
var AGGRESSIVE_STANCE = Stances.create_aggressive_stance()
var DEFENSIVE_STANCE = Stances.create_defensive_stance()
var MAX_CHARGE_LEVEL = 4.0

var _stance = READY_STANCE
var _next_stance: Stance = null
var _state = State.IDLE
var _next_state = _state
var _defense_level = Enums.Level.MIDDLE

var _curr_charge_level = 0.0

var TEXTURE_SWORD = load("res://assets/images/sword32x32.png")

onready var _energy_bar: PercentBar = $EnergyBar
onready var _charge_bar: PercentBar = $ChargeBar
onready var _start_charging_timer = $StartChargingTimer
onready var _stance_label = $StanceLabel
onready var _stance_tooltip = $StanceTooltip
onready var _shield = $Shield
onready var _anim = $Sprite/AnimationPlayer

func _ready():
	_shield.visible = false

func _process(delta):
	if _state != _next_state:
		match _next_state:
			State.CHANGING_STANCE:
				_enter_changing_stance()
			State.PREPARE_STRIKE:
				_enter_prepare_strike()
			State.CHARGING_STRIKE:
				_enter_charging_strike()
			State.STRIKE:
				_enter_strike()
			State.DEFENDING:
				_enter_defending()
			State.RECOVERING:
				_enter_recovering()
				
		match _state:
			State.CHANGING_STANCE:
				_exit_changing_stance()
			State.STRIKE:
				_exit_strike()
			State.DEFENDING:
				_exit_defending()
			State.RECOVERING:
				_exit_recovering()

		_state = _next_state

	match _state:
		State.IDLE:
			_do_idle(delta)
		State.CHANGING_STANCE:
			_do_changing_stance(delta)
		State.PREPARE_STRIKE:
			_do_prepare_strike(delta)
		State.CHARGING_STRIKE:
			_do_charging_strike(delta)
		State.STRIKE:
			_do_strike()
		State.DEFENDING:
			_do_defending(delta)
		State.RECOVERING:
			_do_recovering(delta)
			
	_energy_bar.percent = curr_energy / max_energy	
	_charge_bar.percent = _curr_charge_level - int(_curr_charge_level)
	_stance_label.text = _stance.name
	

func _do_idle(delta):
	if Input.is_action_pressed("battle_attack"):
		assert(curr_energy > 0)
		_next_state = State.PREPARE_STRIKE
	elif Input.is_action_pressed("battle_defend"):
		if (curr_energy > 0):
			_next_state = State.DEFENDING
		else:
			curr_energy = 0
			_next_state = State.RECOVERING
	elif Input.is_action_pressed("battle_stance"):
		Time.scale(0.2)
		_next_state = State.CHANGING_STANCE
	else:
		curr_energy = min(max_energy, curr_energy + _stance.recover_energy_per_second * delta)

func _enter_changing_stance():
	_stance_tooltip.visible = true

func _exit_changing_stance():
	_stance_tooltip.visible = false

func _do_changing_stance(delta):
	if Input.is_action_pressed("ui_left"):
		_next_stance = DEFENSIVE_STANCE
	elif Input.is_action_pressed("ui_right"):
		_next_stance = AGGRESSIVE_STANCE
	elif Input.is_action_pressed("ui_down"):
		_next_stance = READY_STANCE

	if Input.is_action_just_released("battle_stance"):
		if _next_stance != null && _next_stance != _stance:
			# Cancel all actions
			_stance = _next_stance
			_next_stance = null
			_cancel_my_actions()
		
		Time.restore()
		_next_state = State.IDLE

func _enter_prepare_strike():
	_anim.play("prepare")

func _do_prepare_strike(delta):
	if _start_charging_timer.is_stopped():
		assert(curr_energy > 0)
		curr_energy = max(0, curr_energy - _stance.energy_per_strike)
		if curr_energy > 0:
			_start_charging_timer.start()
		else:
			_next_state = State.STRIKE
	else:
		if Input.is_action_just_released("battle_attack"):
			_start_charging_timer.stop()
			_next_state = State.STRIKE

func _enter_charging_strike():
	_curr_charge_level = 0.0

func _do_charging_strike(delta):
	if Input.is_action_just_released("battle_attack"):
		_next_state = State.STRIKE
	else:
		var curr_charge_level_int = int(_curr_charge_level)
		var charge_multiplier = 1.0
		while curr_charge_level_int > 0:
			charge_multiplier /= 2
			curr_charge_level_int -= 1
			
		_curr_charge_level = min(MAX_CHARGE_LEVEL, _curr_charge_level + _stance.charge_per_second * delta * charge_multiplier)

func _enter_strike():
	_anim.play("strike")

func _on_strike_anim_finished():
	_anim.play("idle")

func _do_strike():
	var attack = Factory.new_attack(self)
	attack.texture = TEXTURE_SWORD
	attack.damage = int(round(pow(2, _curr_charge_level))) # From 1 to 16
	emit_signal("action_emitted", attack, _get_level())
	if curr_energy > 0:
		_next_state = State.IDLE
	else:
		_next_state = State.RECOVERING

func _exit_strike():
	_curr_charge_level = 0.0

func _enter_defending():
	_shield.visible = true
	
func _exit_defending():
	_shield.visible = false

func _do_defending(delta):
	if Input.is_action_just_released("battle_defend"):
		_next_state = State.IDLE
		return

	var position = 25
	if Input.is_action_pressed("ui_up"):
		_defense_level = Enums.Level.UPPER
		position = -position
	elif Input.is_action_pressed("ui_down"):
		_defense_level = Enums.Level.LOWER
	else:
		_defense_level = Enums.Level.MIDDLE
		position = 0
		
	_shield.position.y = position

	curr_energy = max(0, curr_energy - _stance.defense_energy_per_second * delta)
	if curr_energy == 0:
		_next_state = State.RECOVERING
	
func _enter_recovering():
	var disabled_color = Color(_energy_bar.fill_color.to_rgba32())
	disabled_color.a = 0.3
	_energy_bar.fill_color = disabled_color

func _do_recovering(delta):
	curr_energy = min(max_energy, curr_energy + _stance.recover_energy_per_second * delta)
	if curr_energy == max_energy:
		_next_state = State.IDLE

func _exit_recovering():
	var enabled_color = Color(_energy_bar.fill_color.to_rgba32())
	enabled_color.a = 1
	_energy_bar.fill_color = enabled_color

func _get_level():
	if Input.is_action_pressed("ui_up"):
		return Enums.Level.UPPER
	elif Input.is_action_pressed("ui_down"):
		return Enums.Level.LOWER
	return Enums.Level.MIDDLE

func _on_StartChargingTimer_timeout():
	_next_state = State.CHARGING_STRIKE

func _handle_attacked(damage: int, level: int) -> void:
	if (_state != State.DEFENDING):
		._handle_attacked(damage, level)
	else:
		var energy_down = _stance.energy_per_block
		if _defense_level == level:
			energy_down /= 5
			
		curr_energy = max(0, curr_energy - energy_down)
		if curr_energy == 0:
			_next_state = State.RECOVERING
