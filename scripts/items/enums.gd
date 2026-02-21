class_name ItemEnums
extends RefCounted

# DamageType kept as enum since it's used in combat calculations
enum DamageType {
	PENETRATING,
	SLICING,
	KINETIC,
	CONCUSSIVE,
	FIRE,
	MAJIA,
}

const DAMAGE_TYPE_MAP = {
	"penetrating": DamageType.PENETRATING,
	"slicing": DamageType.SLICING,
	"kinetic": DamageType.KINETIC,
	"concussive": DamageType.CONCUSSIVE,
	"fire": DamageType.FIRE,
	"majia": DamageType.MAJIA,
}

static func damage_type_from_string(s: String) -> DamageType:
	assert(DAMAGE_TYPE_MAP.has(s), "Unknown damage type: %s" % s)
	return DAMAGE_TYPE_MAP[s]
