class_name SaveHelper
extends Node


static func save_game(node: Node):
	var save_file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	var node_data: Dictionary = save_properties(node)
	var json_string = JSON.stringify(node_data)
	save_file.store_line(json_string)
		
static func save_properties(node: Object) -> Dictionary:
	var node_data: Dictionary
	
	if !node.has_method("get_savable_properties"):
		print("persistent node '%s' is missing a get_savable_properties() function, skipped" % node.get_script())
		return node_data

	var node_properties = node.get_property_list()
	var savable_properties = node.get_savable_properties()
	for property_name:String in savable_properties:
		if property_name.ends_with("*"):
			var prefix = property_name.trim_suffix("*") 
			for star_property in node_properties:
				if star_property.name.begins_with(prefix):
					save_property(node, star_property.name, node_data)
		else:
			save_property(node, property_name, node_data)
	return node_data	
		
static func save_property(node: Object, property_name: String, node_data: Dictionary):
	if node[property_name] is Object:
		node_data[property_name] = save_properties(node[property_name])
		node_data[property_name]["save_type"] = "child"
	else:
		node_data[property_name] = node[property_name]
	

static func load_game(node: Node):
	if not FileAccess.file_exists("user://savegame.json"):
		return 
		
	var save_file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var json_string = save_file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return

	var node_data = json.data
	load_properties(node, node_data)
	
static func load_properties(node: Object, node_data: Dictionary):
	for property_name in node_data.keys():
		
		if property_name == "purchased_items":
			pass
		
		var value = node_data[property_name]
		if value is Dictionary and value.has("save_type") and value["save_type"] == "child":
			value.erase("save_type")
			load_properties(node[property_name], value)
		if value is Array:
			node[property_name].clear()
			node[property_name].assign(value)
		else:
			node.set(property_name, value)
	if node.has_method("_on_loaded"):
		node._on_loaded()
