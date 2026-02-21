class_name Alloy
extends RefCounted

var id: String
var name: String
var density: float
var hardness: float


func _init(alloy_id: String, data: Dictionary):
	assert(data != null, "Alloy data not found: %s" % alloy_id)
	id = alloy_id
	name = data["name"]
	density = float(data["density"])
	hardness = float(data["hardness"])
