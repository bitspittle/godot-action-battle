class_name Stances

static func create_ready_stance():
	var stance = Stance.new()
	stance.name = "Ready"
	stance.energy_per_strike = 40
	stance.energy_per_block = 20
	stance.defense_energy_per_second = 50
	stance.recover_energy_per_second = 100
	return stance
	
static func create_aggressive_stance():
	var stance = create_ready_stance()
	stance.name = "Aggressive"
	stance.energy_per_strike /= 2
	stance.defense_energy_per_second = 200
	stance.recover_energy_per_second = 50
	stance.action_speed_multiplier = 1.5
	return stance

static func create_defensive_stance():
	var stance = create_ready_stance()
	stance.name = "Defensive"
	stance.energy_per_strike *= 2
	stance.defense_energy_per_second = 10
	stance.action_speed_multiplier = .7
	return stance
