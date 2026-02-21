class_name CharacterStats
extends RefCounted

const STAT_NAMES: Array[String] = ["sinew", "alacrity", "virtus", "fortitudo"]

var sinew: float
var alacrity: float
var virtus: float
var fortitudo: float


func _init(p_sinew: float = 10.0, p_alacrity: float = 10.0, p_virtus: float = 10.0, p_fortitudo: float = 10.0):
	sinew = p_sinew
	alacrity = p_alacrity
	virtus = p_virtus
	fortitudo = p_fortitudo


static func from_dict(data: Dictionary) -> CharacterStats:
	return CharacterStats.new(
		data.get("sinew", 10.0),
		data.get("alacrity", 10.0),
		data.get("virtus", 10.0),
		data.get("fortitudo", 10.0)
	)


func to_dict() -> Dictionary:
	var result = {}
	for stat in STAT_NAMES:
		result[stat] = get_stat(stat)
	return result


func get_stat(stat_name: String) -> float:
	match stat_name:
		"sinew": return sinew
		"alacrity": return alacrity
		"virtus": return virtus
		"fortitudo": return fortitudo
		_: return 0.0


func set_stat(stat_name: String, value: float):
	match stat_name:
		"sinew": sinew = value
		"alacrity": alacrity = value
		"virtus": virtus = value
		"fortitudo": fortitudo = value


func add_stat(stat_name: String, value: float):
	set_stat(stat_name, get_stat(stat_name) + value)


func format_stats(separator: String = ", ") -> String:
	var parts: Array[String] = []
	for stat in STAT_NAMES:
		parts.append("%s=%d" % [stat, get_stat(stat)])
	return separator.join(parts)


func format_stats_vertical(padding: int = 10) -> String:
	var lines: Array[String] = []
	for stat in STAT_NAMES:
		lines.append("%s %d" % [stat.to_upper().rpad(padding), int(get_stat(stat))])
	return "\n".join(lines)


func format_changes(changes: Dictionary) -> String:
	var parts: Array[String] = []
	for stat in STAT_NAMES:
		if changes.has(stat):
			var value = changes[stat]
			var sign = "+" if value > 0 else ""
			parts.append("%s %s%d" % [stat.to_upper(), sign, value])
	return ", ".join(parts)


static func get_stat_names() -> Array[String]:
	return STAT_NAMES
