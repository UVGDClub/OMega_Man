extends Node

# Path to the save file
const SAVE_PATH = "user://savegame.save"
# Save the game data
func save():
	var real_path = ProjectSettings.globalize_path(SAVE_PATH)
	print("Saving to:", real_path)
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("Failed to open save file!")
		return
	
	var data = Global.save()
	var json_string = JSON.stringify(data)
	file.store_line(json_string)

	file.close()
	print("Game saved successfully.")

# Load the game data
func load():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found.")
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	while file.get_position() < file.get_length():
		var json_string = file.get_line()
		var json = JSON.new()		
		
		var result = json.parse(json_string)
		if result != OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string)
			continue

		var node_data = json.data

		for key in node_data.keys():
			if key in ["filename", "parent", "pos_x", "pos_y"]:
				continue
			print (typeof(node_data[key]))
			Global.set(key, node_data[key])

	file.close()
	print("Game loaded successfully.")
