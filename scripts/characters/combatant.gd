class_name Combatant
extends RefCounted


var name: String
var stats: CharacterStats
var weapon: Weapon
var max_sanguis: float
var sanguis: float


func _init(p_name: String, p_stats: CharacterStats, p_weapon: Weapon):
	name = p_name
	stats = p_stats
	weapon = p_weapon
	max_sanguis = stats.fortitudo * 10.0
	sanguis = max_sanguis


func is_alive() -> bool:
	return sanguis > 0


func take_damage(amount: float) -> float:
	var reduction = (stats.fortitudo - 10.0) / 100.0
	var actual_damage = amount * (1.0 - reduction)
	actual_damage = max(actual_damage, 0.0)

	sanguis -= actual_damage
	sanguis = max(sanguis, 0.0)
	return actual_damage


func get_damage_multiplier() -> Dictionary:
	var base = 10.0
	return {
		"heft_mult": stats.sinew / base,
		"counterbalance_mult": stats.alacrity / base,
		"crit_chance": (stats.virtus - base) / 100.0,
	}
