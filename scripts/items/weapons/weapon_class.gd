class_name WeaponClass
extends RefCounted

var id: String
var name: String
var weight_heft_ratio: float
var weight_counterbalance_ratio: float
var hardness_severity_ratio: float
var hardness_durity_ratio: float
var attack_types: Array[AttackType]
var movesets: Array


func _init(class_id: String, data: Dictionary):
	assert(data != null, "WeaponClass data not found: %s" % class_id)
	id = class_id
	name = data["name"]
	weight_heft_ratio = float(data["weight_heft_ratio"])
	weight_counterbalance_ratio = float(data["weight_counterbalance_ratio"])
	hardness_severity_ratio = float(data["hardness_severity_ratio"])
	hardness_durity_ratio = float(data["hardness_durity_ratio"])
	movesets = data["movesets"]

	attack_types = []
	for atk in data["attack_types"]:
		attack_types.append(AttackType.new(atk))


class AttackType:
	var id: int
	var name: String
	var damage_type: ItemEnums.DamageType
	var severity_mult: float
	var heft_mult: float
	var counterbalance_mult: float
	var durity_mult: float

	func _init(data: Dictionary):
		id = int(data["id"])
		name = data["name"]
		damage_type = ItemEnums.damage_type_from_string(data["damage_type"])
		severity_mult = float(data.get("severity_mult", 0.0))
		heft_mult = float(data.get("heft_mult", 0.0))
		counterbalance_mult = float(data.get("counterbalance_mult", 0.0))
		durity_mult = float(data.get("durity_mult", 0.0))
