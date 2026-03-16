extends TextureButton
class_name GameButton
@export var game_data : GameInfo

func _ready() -> void:
	if game_data.thumbnail:
		$VBox/Thumbnail.texture = game_data.thumbnail
	$VBox/Title.text = game_data.title
	# Red selection border matching design mockup
	var border_style = StyleBoxFlat.new()
	border_style.bg_color = Color(0, 0, 0, 0)
	border_style.border_color = Color(0.9, 0.15, 0.15, 1)  # red
	border_style.border_width_top = 4
	border_style.border_width_bottom = 4
	border_style.border_width_left = 4
	border_style.border_width_right = 4
	$SelectBorder.add_theme_stylebox_override("panel", border_style)
	$SelectBorder.visible = false

const CONTEXT = preload("res://Menus/context.tscn")
func _on_button_down() -> void:
	var new_context = CONTEXT.instantiate()
	new_context.game_data = game_data
	add_child(new_context)

func _on_focus_entered() -> void:
	$SelectBorder.visible = true
	$Move.play()

func _on_focus_exited():
	$SelectBorder.visible = false
