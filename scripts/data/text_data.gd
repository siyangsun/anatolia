class_name TextData
extends RefCounted

var _cache: Dictionary = {}


func load_text(file_name: String) -> Dictionary:
	if _cache.has(file_name):
		return _cache[file_name]

	var path = "res://assets/data/text/%s.json" % file_name
	var file = FileAccess.open(path, FileAccess.READ)
	assert(file != null, "Text file not found: %s" % path)

	var content = file.get_as_text()
	file.close()

	var data = JSON.parse_string(content)
	_cache[file_name] = data
	return data


func get_value(file_name: String, key: String, default: Variant = null) -> Variant:
	var data = load_text(file_name)
	if data.has(key):
		return data[key]
	return default


func get_nested(file_name: String, keys: Array, default: Variant = null) -> Variant:
	var data = load_text(file_name)
	var current = data

	for key in keys:
		if current is Dictionary and current.has(key):
			current = current[key]
		elif current is Array and key is int and key < current.size():
			current = current[key]
		else:
			return default

	return current


static func format(template: String, values: Dictionary) -> String:
	var result = template
	for key in values:
		result = result.replace("{%s}" % key, str(values[key]))
	return result
