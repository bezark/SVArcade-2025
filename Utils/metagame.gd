extends Node
var button_timer : Timer
var idle_watch = false
var loaded_globals : Array[String] = []

func _ready() -> void:
	get_tree().node_added.connect(focus_button)
	$Music.play()
	idle_watch = false

func load_game(packed_game_tscn:PackedScene, clear_color : Color):
	remove_children()
	prints("loading", packed_game_tscn)
	var new_scene = packed_game_tscn.instantiate()
	RenderingServer.set_default_clear_color(clear_color)
	get_tree().change_scene_to_packed(packed_game_tscn)
	idle_watch = true
	$Music.stop()

func focus_button(node):
	if node is Button or node is TextureButton:
		node.grab_click_focus()
		node.grab_focus()

func remove_children():
	var children = get_children()
	for dead_child in children:
		if not dead_child.is_in_group("meta"):
			dead_child.queue_free()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		unload_globals()
		get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
		$Music.play()
		hide_continue()
		idle_watch = false
		remove_children()

func unload_globals():
	for autoload_name in loaded_globals:
		var node = get_tree().root.get_node_or_null(autoload_name)
		if node:
			get_tree().root.remove_child(node)
			node.queue_free()
	loaded_globals.clear()

func load_globals(globals):
	for global in globals:
		var res = load(global)
		var node : Node
		if res is PackedScene:
			node = res.instantiate()
		elif res is GDScript:
			node = Node.new()
			node.set_script(res)
		else:
			continue
		var autoload_name = global.get_file().get_basename().to_pascal_case()
		node.name = autoload_name
		get_tree().root.add_child(node)
		loaded_globals.append(autoload_name)

func _input(event: InputEvent) -> void:
	if idle_watch:
		$IdleTimer.start()
	hide_continue()

func hide_continue():
	$StillPlaying.hide()
	seconds_left = 10
	$StillPlaying/Timer.stop()

var seconds_left = 10

##Start countdown
func _on_timer_timeout() -> void:
	print("timeou")
	$StillPlaying/PanelContainer/CenterContainer/VBoxContainer/Countdown.text = str(seconds_left)
	$AnimationPlayer.play("stillplaying?")
	$StillPlaying.show()

func _on_seconds_timer_timeout() -> void:
	seconds_left -= 1
	$StillPlaying/PanelContainer/CenterContainer/VBoxContainer/Countdown.text = str(seconds_left)
	if seconds_left <= 0:
		hide_continue()
		unload_globals()
		get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
		$Music.play()
		remove_children()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "stillplaying?":
		$StillPlaying/Timer.start()

func start_music():
	if not $Music.playing:
		$Music.play()

func stop_music():
	$Music.stop()
