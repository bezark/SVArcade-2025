extends VBoxContainer

@export var class_projects : ClassProjects
@export var extra_projects : Array[ClassProjects]
@export var game_ui : PackedScene

var all_semesters : Array[ClassProjects] = []
var game_entries : Array[Dictionary] = []  # {node: GameButton, semester: String}
var filter_buttons : Array[Button] = []
var current_filter := "ALL"

@onready var filter_bar := %FilterBar
@onready var game_grid := %GameGrid
@onready var scroll := %ScrollContainer

const RED = Color(0.9, 0.15, 0.15, 1)
const WHITE = Color(1, 1, 1, 1)
const DIM_WHITE = Color(1, 1, 1, 0.5)
const BG_DARK = Color(0.28, 0.28, 0.28, 1)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Metagame.start_music()

	if class_projects:
		all_semesters.append(class_projects)
	all_semesters.append_array(extra_projects)

	_build_filter_bar()
	_build_game_grid()
	_apply_filter("ALL")

func _build_filter_bar():
	var all_btn = _make_filter_button("ALL")
	filter_bar.add_child(all_btn)
	filter_buttons.append(all_btn)

	for cp in all_semesters:
		var btn = _make_filter_button(cp.date.to_upper())
		filter_bar.add_child(btn)
		filter_buttons.append(btn)

	_highlight_filter(filter_buttons[0])

var _arcade_font = preload("res://Assets/ARCADE_N.TTF")

func _make_filter_button(label: String) -> Button:
	var btn = Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(180, 48)
	btn.add_theme_font_override("font", _arcade_font)
	btn.add_theme_font_size_override("font_size", 20)
	btn.focus_mode = Control.FOCUS_ALL
	btn.button_down.connect(_on_filter_pressed.bind(label))
	btn.focus_entered.connect(_on_filter_focus.bind(btn))
	return btn

func _build_game_grid():
	for cp in all_semesters:
		for game in cp.projects:
			var new_ui : GameButton = game_ui.instantiate()
			new_ui.game_data = game
			game_grid.add_child(new_ui)
			game_entries.append({"node": new_ui, "semester": cp.date.to_upper()})

func _apply_filter(filter: String):
	current_filter = filter
	var first_visible : GameButton = null
	var prev_visible : GameButton = null

	for entry in game_entries:
		var node : GameButton = entry["node"]
		var show = (filter == "ALL" or entry["semester"] == filter)
		node.visible = show
		if show:
			if not first_visible:
				first_visible = node
			if prev_visible:
				node.focus_previous = prev_visible.get_path()
				node.focus_neighbor_top = prev_visible.get_path()
				prev_visible.focus_next = node.get_path()
				prev_visible.focus_neighbor_bottom = node.get_path()
			prev_visible = node

	if first_visible:
		first_visible.call_deferred("grab_focus")

	for btn in filter_buttons:
		if btn.text == filter:
			_highlight_filter(btn)
		else:
			_unhighlight_filter(btn)

func _on_filter_pressed(filter: String):
	_apply_filter(filter)

func _on_filter_focus(_btn: Button):
	pass

func _highlight_filter(btn: Button):
	btn.add_theme_color_override("font_color", WHITE)
	btn.add_theme_color_override("font_focus_color", WHITE)
	btn.add_theme_color_override("font_hover_color", WHITE)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = RED
	style.border_width_bottom = 3
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("focus", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)

func _unhighlight_filter(btn: Button):
	btn.add_theme_color_override("font_color", DIM_WHITE)
	btn.add_theme_color_override("font_focus_color", WHITE)
	btn.add_theme_color_override("font_hover_color", WHITE)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = Color(1, 1, 1, 0.15)
	style.border_width_bottom = 1
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	btn.add_theme_stylebox_override("normal", style)
	var focus_style = StyleBoxFlat.new()
	focus_style.bg_color = Color(1, 1, 1, 0.08)
	focus_style.border_color = WHITE
	focus_style.border_width_bottom = 2
	focus_style.content_margin_left = 12
	focus_style.content_margin_right = 12
	focus_style.content_margin_top = 8
	focus_style.content_margin_bottom = 8
	btn.add_theme_stylebox_override("focus", focus_style)
	btn.add_theme_stylebox_override("hover", focus_style)
	btn.add_theme_stylebox_override("pressed", focus_style)

func _process(_delta):
	pass
