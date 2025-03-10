extends Control

@export var game_data : GameInfo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if game_data.thumbnail:
		$Thumbnail.texture = game_data.thumbnail
	$Button.text = game_data.title


func _on_button_button_down():
	$PCKImporter.load_pck(game_data.pck_file, game_data.main_scene)
