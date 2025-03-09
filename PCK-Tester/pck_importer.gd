extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_pck()


func load_pck():
	# This could fail if, for example, mod.pck cannot be found.
	var success = ProjectSettings.load_resource_pack("res://PCKs/EchosTale.pck")
	# var success = ProjectSettings.load_resource_pack("res://Prison.pck")

	if success:
		# Now one can use the assets as if they had them in the project from the start.
		# var imported_scene = load("res://Scene/mainLevel.tscn/")
		var imported_scene = load("res://scenes/levels/Opening_Menu.tscn")
		get_tree().change_scene_to_packed(imported_scene)
