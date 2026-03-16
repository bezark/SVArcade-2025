extends Node



func load_pck(path, main, globals, color):
	# This could fail if, for example, mod.pck cannot be found.
	var success = ProjectSettings.load_resource_pack(path)
	# var success = ProjectSettings.load_resource_pack("res://Prison.pck")

	if success:
		# Load globals first so autoload names resolve when scene scripts are parsed
		if globals:
			Metagame.load_globals(globals)
		var imported_scene = load(main)
		Metagame.load_game(imported_scene, color)
