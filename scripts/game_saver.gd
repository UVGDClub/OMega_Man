extends Node

# Path to the save file
const SAVE_PATH = "user://savegame.save"

# Save the game data
func save():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("Failed to open save file!")
		return

	var nodes = get_tree().get_nodes_in_group("Persist")
	for node in nodes:
		if node.scene_file_path.is_empty():
			print("Skipping non-instanced node '%s'" % node.name)
			continue

		if !node.has_method("save"):
			print("Node '%s' missing save() method, skipped" % node.name)
			continue

		var data = node.call("save")
		var json_string = JSON.stringify(data)
		file.store_line(json_string)

	file.close()
	print("Game saved successfully.")

# Load the game data
func load():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found.")
		return

	var nodes = get_tree().get_nodes_in_group("Persist")
	for node in nodes:
		node.queue_free()

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	while file.get_position() < file.get_length():
		var json_string = file.get_line()
		var json = JSON.new()

		var result = json.parse(json_string)
		if result != OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string)
			continue

		var node_data = json.data
		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		for key in node_data.keys():
			if key in ["filename", "parent", "pos_x", "pos_y"]:
				continue
			new_object.set(key, node_data[key])

	file.close()
	print("Game loaded successfully.")
