class_name DamageText
extends RefCounted

enum Severity {
	GLANCING,      # < 10% of max HP
	SOLID,         # >= 10% of max HP
	NEAR_MORTAL,   # Sets target below 10% HP
}


static func get_severity(damage: float, target_max_sanguis: float, target_current_sanguis: float) -> Severity:
	var percent_of_max = damage / target_max_sanguis
	var sanguis_after = target_current_sanguis - damage

	if sanguis_after <= target_max_sanguis * 0.1 and target_current_sanguis > target_max_sanguis * 0.1:
		return Severity.NEAR_MORTAL
	elif percent_of_max >= 0.1:
		return Severity.SOLID
	else:
		return Severity.GLANCING


static func describe_hit(
	attacker_name: String,
	attack_name: String,
	damage_type: ItemEnums.DamageType,
	damage: float,
	target_name: String,
	target_max_sanguis: float,
	target_current_sanguis: float
) -> Dictionary:
	var severity = get_severity(damage, target_max_sanguis, target_current_sanguis)
	var desc = _get_description(attack_name, damage_type, severity)

	var ui_text = "%s's %s %s %s." % [attacker_name, attack_name, desc, target_name]
	var debug_text = "[%s -> %s: %s %.1f dmg, %s]" % [
		attacker_name,
		target_name,
		attack_name,
		damage,
		Severity.keys()[severity]
	]

	return {
		"ui": ui_text,
		"debug": debug_text,
		"severity": severity,
	}


static func _get_description(attack_name: String, damage_type: ItemEnums.DamageType, severity: Severity) -> String:
	var descriptions = _get_descriptions_for_type(damage_type)
	return descriptions[severity]


static func _get_descriptions_for_type(damage_type: ItemEnums.DamageType) -> Dictionary:
	match damage_type:
		ItemEnums.DamageType.PENETRATING:
			return {
				Severity.GLANCING: "grazes",
				Severity.SOLID: "pierces deep into",
				Severity.NEAR_MORTAL: "impales",
			}
		ItemEnums.DamageType.SLICING:
			return {
				Severity.GLANCING: "scrapes across",
				Severity.SOLID: "carves into",
				Severity.NEAR_MORTAL: "cleaves through",
			}
		ItemEnums.DamageType.KINETIC:
			return {
				Severity.GLANCING: "glances off",
				Severity.SOLID: "connects solidly with",
				Severity.NEAR_MORTAL: "shatters into",
			}
		ItemEnums.DamageType.CONCUSSIVE:
			return {
				Severity.GLANCING: "clips",
				Severity.SOLID: "staggers",
				Severity.NEAR_MORTAL: "devastates",
			}
		ItemEnums.DamageType.FIRE:
			return {
				Severity.GLANCING: "singes",
				Severity.SOLID: "scorches",
				Severity.NEAR_MORTAL: "engulfs",
			}
		ItemEnums.DamageType.MAJIA:
			return {
				Severity.GLANCING: "whispers against",
				Severity.SOLID: "courses through",
				Severity.NEAR_MORTAL: "unravels the essence of",
			}
		_:
			return {
				Severity.GLANCING: "strikes",
				Severity.SOLID: "hits",
				Severity.NEAR_MORTAL: "crushes",
			}


static func describe_death(name: String, final_damage_type: ItemEnums.DamageType) -> String:
	match final_damage_type:
		ItemEnums.DamageType.PENETRATING:
			return "%s crumples, run through." % name
		ItemEnums.DamageType.SLICING:
			return "%s falls, blood pooling beneath." % name
		ItemEnums.DamageType.KINETIC:
			return "%s collapses, broken." % name
		ItemEnums.DamageType.CONCUSSIVE:
			return "%s is thrown back, still." % name
		ItemEnums.DamageType.FIRE:
			return "%s is consumed by flame." % name
		ItemEnums.DamageType.MAJIA:
			return "%s fades, unmade by forces unseen." % name
		_:
			return "%s falls." % name
