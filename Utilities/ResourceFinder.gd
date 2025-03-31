class_name ResourceFinder
extends Node

static func get_resources_in_folder(folder_path: String, filter: String = ".tres", recursive: bool = false) -> Array[Resource]:
	var resources:Array[Resource] = []

	var dir = DirAccess.open(folder_path)
	if dir == null:
		print("Failed to open directory: ", folder_path)
		return []
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
				
		# Get the full path of the resource
		var full_path = folder_path + file_name
		
		if dir.current_is_dir():
			if recursive:
				resources.append_array(get_resources_in_folder(full_path + "/", filter, recursive))
			file_name = dir.get_next()
			continue
		
		if (filter != "" and
			file_name.find(filter) == -1):
			file_name = dir.get_next()
			continue
		
		# Load the resource
		var resource = load(full_path)
		if resource:
			resources.append(resource)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

	return resources
