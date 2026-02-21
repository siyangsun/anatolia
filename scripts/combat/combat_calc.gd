class_name CombatCalc
extends RefCounted


static func calculate_weapon_stats(weapon: Weapon) -> Dictionary:
	var density = weapon.alloy.density
	var hardness = weapon.alloy.hardness
	var wclass = weapon.weapon_class

	var heft = density * wclass.weight_heft_ratio
	var counterbalance = 10 + (density * wclass.weight_counterbalance_ratio)
	var severity = hardness * wclass.hardness_severity_ratio
	var durity = hardness * wclass.hardness_durity_ratio

	return {
		"name": weapon.name,
		"class": wclass.name,
		"alloy": weapon.alloy.name,
		"reach": weapon.reach,
		"heft": snapped(heft, 0.01),
		"counterbalance": snapped(counterbalance, 0.01),
		"severity": snapped(severity, 0.01),
		"durity": snapped(durity, 0.01),
	}


static func calculate_attack_damage(weapon_stats: Dictionary, attack_type: WeaponClass.AttackType, combatant: Combatant = null) -> float:
	var damage = 0.0

	var heft_bonus = weapon_stats["heft"] * attack_type.heft_mult
	var cb_bonus = weapon_stats["counterbalance"] * attack_type.counterbalance_mult

	if combatant:
		var mults = combatant.get_damage_multiplier()
		heft_bonus *= mults["heft_mult"]
		cb_bonus *= mults["counterbalance_mult"]

	damage += weapon_stats["severity"] * attack_type.severity_mult
	damage += heft_bonus
	damage += cb_bonus
	damage += weapon_stats["durity"] * attack_type.durity_mult

	return snapped(damage, 0.01)


static func calculate_combo(weapon: Weapon, moveset_index: int = 0, combatant: Combatant = null) -> Dictionary:
	var stats = weapon.get_stats()
	var moveset = weapon.get_movesets()[moveset_index]
	var attack_types = weapon.get_attack_types()

	var total_damage = 0.0
	var hits: Array = []

	for tick in range(moveset.size()):
		var attack_idx = int(moveset[tick])
		if attack_idx == 0:
			hits.append({"tick": tick, "damage": 0.0, "attack": null})
		else:
			var attack = attack_types[attack_idx - 1]
			var dmg = calculate_attack_damage(stats, attack, combatant)
			total_damage += dmg
			hits.append({
				"tick": tick,
				"damage": dmg,
				"attack": attack,
			})

	return {
		"weapon_stats": stats,
		"moveset": moveset,
		"windup_delay": weapon.get_windup_delay(),
		"hits": hits,
		"total_damage": total_damage,
	}


# Returns combat setup for tick-by-tick simulation
static func create_combat(attacker: Combatant, defender: Combatant) -> Dictionary:
	return {
		"attacker": attacker,
		"defender": defender,
		"attacker_combo_tick": -attacker.weapon.get_windup_delay(),
		"defender_combo_tick": -defender.weapon.get_windup_delay(),
		"attacker_moveset": attacker.weapon.get_movesets()[0],
		"defender_moveset": defender.weapon.get_movesets()[0],
		"attacker_stats": attacker.weapon.get_stats(),
		"defender_stats": defender.weapon.get_stats(),
		"attacker_attacks": attacker.weapon.get_attack_types(),
		"defender_attacks": defender.weapon.get_attack_types(),
		"tick": 0,
		"last_damage_type": ItemEnums.DamageType.KINETIC,
		"finished": false,
		"winner": "",
	}


# Process one tick of combat, returns events that happened
static func process_tick(combat: Dictionary) -> Array:
	var events: Array = []

	var attacker = combat["attacker"]
	var defender = combat["defender"]

	if not attacker.is_alive() or not defender.is_alive():
		combat["finished"] = true
		if not attacker.is_alive():
			combat["winner"] = defender.name
		else:
			combat["winner"] = attacker.name
		return events

	# Process attacker
	if combat["attacker_combo_tick"] >= 0:
		var combo_pos = combat["attacker_combo_tick"] % combat["attacker_moveset"].size()
		var attack_idx = int(combat["attacker_moveset"][combo_pos])
		if attack_idx > 0:
			var attack = combat["attacker_attacks"][attack_idx - 1]
			var raw_dmg = calculate_attack_damage(combat["attacker_stats"], attack, attacker)
			var actual_dmg = defender.take_damage(raw_dmg)
			combat["last_damage_type"] = attack.damage_type

			events.append({
				"type": "attack",
				"attacker": attacker.name,
				"defender": defender.name,
				"attack": attack,
				"damage": actual_dmg,
				"target_max_sanguis": defender.max_sanguis,
				"target_sanguis": defender.sanguis + actual_dmg,
			})

	# Check if defender died
	if not defender.is_alive():
		combat["finished"] = true
		combat["winner"] = attacker.name
		events.append({
			"type": "death",
			"name": defender.name,
			"damage_type": combat["last_damage_type"],
		})
		return events

	# Process defender
	if combat["defender_combo_tick"] >= 0:
		var combo_pos = combat["defender_combo_tick"] % combat["defender_moveset"].size()
		var attack_idx = int(combat["defender_moveset"][combo_pos])
		if attack_idx > 0:
			var attack = combat["defender_attacks"][attack_idx - 1]
			var raw_dmg = calculate_attack_damage(combat["defender_stats"], attack, defender)
			var actual_dmg = attacker.take_damage(raw_dmg)
			combat["last_damage_type"] = attack.damage_type

			events.append({
				"type": "attack",
				"attacker": defender.name,
				"defender": attacker.name,
				"attack": attack,
				"damage": actual_dmg,
				"target_max_sanguis": attacker.max_sanguis,
				"target_sanguis": attacker.sanguis + actual_dmg,
			})

	# Check if attacker died
	if not attacker.is_alive():
		combat["finished"] = true
		combat["winner"] = defender.name
		events.append({
			"type": "death",
			"name": attacker.name,
			"damage_type": combat["last_damage_type"],
		})
		return events

	combat["tick"] += 1
	combat["attacker_combo_tick"] += 1
	combat["defender_combo_tick"] += 1

	return events
