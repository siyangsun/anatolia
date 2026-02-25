class_name Weapon
extends RefCounted

var id: String
var name: String
var reach: int
var alloy: Alloy
var weapon_class: WeaponClass


func _init(weapon_id: String, game_data: GameData):
	assert(game_data.weapons.has(weapon_id), "Unknown weapon: %s" % weapon_id)
	var data = game_data.weapons[weapon_id]
	id = weapon_id
	name = data["name"]
	reach = int(data["reach"])
	alloy = game_data.get_alloy(data["alloy"])
	weapon_class = game_data.get_weapon_class(data["class"])


func get_stats() -> Dictionary:
	return CombatCalc.calculate_weapon_stats(self)


func get_movesets() -> Array:
	return weapon_class.movesets


func get_attack_types() -> Array[WeaponClass.AttackType]:
	return weapon_class.attack_types


