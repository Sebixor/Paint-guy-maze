extends Control

const LEVEL_SCENE: String = "res://scenes/niveles/level_1.tscn"  
const GAME_TITLE: String = "Paint Guy Maze"


# Optional: path to a paint/brush style font (.ttf) for the title, e.g. "res://fonts/PermanentMarker-Regular.ttf"
const TITLE_FONT: String = ""

# Sizes are designed for a 720 px tall screen and scale down automatically
# if your project's viewport is smaller (so nothing gets cut off).
const DESIGN_HEIGHT: float = 720.0
const TITLE_SIZE: int = 64
const BUTTON_SIZE := Vector2(140, 32)
const BUTTON_FONT_SIZE: int = 16

# label -> key, shown in the Controls screen
const CONTROLS: Array = [
	["Move", "Arrow keys"],
	["Jump", "Space"],
	["Dash", "Shift"],
]

# colors
const BG_GREEN := Color("23a455")
const PURPLE := Color("7b2cbf")
const PURPLE_LIGHT := Color("9d4edd")
const PURPLE_DARK := Color("5a189a")
const OUTLINE := Color("2b0a3d")

# paint colors used for the title letters and the splats
const PAINT_COLORS: Array[Color] = [
	Color("ff3b6b"),  # pink-red
	Color("ffd23f"),  # yellow
	Color("3bceff"),  # cyan
	Color("ff8a3b"),  # orange
	Color("ff4bd8"),  # magenta
	Color("ffffff"),  # white
]

var ui_k: float = 1.0   # UI scale factor, calculated in _ready()

var main_box: VBoxContainer
var controls_box: VBoxContainer
var play_button: Button
var back_button: Button


# scales a pixel value by the UI factor (never below 1)
func _px(v: float) -> int:
	return maxi(roundi(v * ui_k), 1)


func _ready() -> void:
	get_tree().paused = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# shrink everything if the viewport is shorter than 720 px
	ui_k = clampf(get_viewport_rect().size.y / DESIGN_HEIGHT, 0.25, 1.0)

	# green background
	var bg := ColorRect.new()
	bg.color = BG_GREEN
	add_child(bg)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# paint splats behind everything
	_build_splats()

	# centered container that holds both the main menu and the controls screen
	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_build_main_box(center)
	_build_controls_box(center)

	_show_main()


# ---------- background paint splats ----------

func _build_splats() -> void:
	var canvas := Control.new()
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(canvas)
	canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var rng := RandomNumberGenerator.new()
	rng.seed = 7   # fixed seed: the splats are always in the same places

	var data: Array = []
	for i in 14:
		var color: Color = PAINT_COLORS[rng.randi() % PAINT_COLORS.size()]
		color.a = 0.35
		var radius := rng.randf_range(18.0, 60.0) * ui_k
		var drops: Array = []
		for j in 4:
			var angle := rng.randf_range(0.0, TAU)
			var dist := radius * rng.randf_range(1.2, 1.9)
			drops.append([Vector2.from_angle(angle) * dist, radius * rng.randf_range(0.15, 0.35)])
		data.append([Vector2(rng.randf(), rng.randf()), radius, color, drops])

	canvas.draw.connect(_draw_splats.bind(canvas, data))


func _draw_splats(canvas: Control, data: Array) -> void:
	for s in data:
		var pos: Vector2 = s[0] * canvas.size
		var radius: float = s[1]
		var color: Color = s[2]
		canvas.draw_circle(pos, radius, color)
		for d in s[3]:
			canvas.draw_circle(pos + d[0], d[1], color)


# ---------- main menu ----------

func _build_main_box(parent: Node) -> void:
	main_box = VBoxContainer.new()
	main_box.add_theme_constant_override("separation", _px(16))
	parent.add_child(main_box)

	main_box.add_child(_make_title())

	play_button = _make_button("Play")
	play_button.pressed.connect(_on_play)
	main_box.add_child(play_button)

	var controls_button := _make_button("Controls")
	controls_button.pressed.connect(_show_controls)
	main_box.add_child(controls_button)

	var quit := _make_button("Quit")
	quit.pressed.connect(_on_quit)
	main_box.add_child(quit)


func _make_title() -> RichTextLabel:
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.add_theme_font_size_override("normal_font_size", _px(TITLE_SIZE))
	label.add_theme_constant_override("outline_size", _px(10))
	label.add_theme_color_override("font_outline_color", OUTLINE)
	if TITLE_FONT != "":
		label.add_theme_font_override("normal_font", load(TITLE_FONT))

	# each letter gets the next paint color
	var bb := ""
	var i := 0
	for ch in GAME_TITLE:
		if ch == " ":
			bb += " "
		else:
			bb += "[color=#%s]%s[/color]" % [PAINT_COLORS[i % PAINT_COLORS.size()].to_html(false), ch]
			i += 1

	# remove the [wave ...] tags if you want a static title
	label.text = "[center][wave amp=%.1f freq=3.0]%s[/wave][/center]" % [12.0 * ui_k, bb]
	return label


# ---------- controls screen ----------

func _build_controls_box(parent: Node) -> void:
	controls_box = VBoxContainer.new()
	controls_box.add_theme_constant_override("separation", _px(24))
	parent.add_child(controls_box)

	var title := Label.new()
	title.text = "Controls"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", _px(40))
	title.add_theme_color_override("font_outline_color", OUTLINE)
	title.add_theme_constant_override("outline_size", _px(8))
	controls_box.add_child(title)

	# two columns: action | key
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", _px(48))
	grid.add_theme_constant_override("v_separation", _px(12))
	controls_box.add_child(grid)

	for entry in CONTROLS:
		for text in entry:
			var label := Label.new()
			label.text = text
			label.add_theme_font_size_override("font_size", _px(22))
			label.add_theme_color_override("font_outline_color", OUTLINE)
			label.add_theme_constant_override("outline_size", _px(6))
			grid.add_child(label)

	back_button = _make_button("Back")
	controls_box.add_child(back_button)
	back_button.pressed.connect(_show_main)


# ---------- helpers ----------

func _make_button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = BUTTON_SIZE * ui_k
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER   # keep own width, don't stretch to the title
	b.add_theme_font_size_override("font_size", _px(BUTTON_FONT_SIZE))
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(c, Color.WHITE)
	b.add_theme_stylebox_override("normal", _box(PURPLE))
	b.add_theme_stylebox_override("hover", _box(PURPLE_LIGHT))
	b.add_theme_stylebox_override("pressed", _box(PURPLE_DARK))

	# focus: white outline only, drawn over the normal/hover style
	var focus := StyleBoxFlat.new()
	focus.draw_center = false
	focus.set_border_width_all(_px(3))
	focus.border_color = Color.WHITE
	focus.set_corner_radius_all(_px(12))
	b.add_theme_stylebox_override("focus", focus)
	return b


func _box(color: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(_px(12))
	s.set_content_margin_all(_px(4))
	return s


func _show_main() -> void:
	controls_box.visible = false
	main_box.visible = true
	play_button.grab_focus()


func _show_controls() -> void:
	main_box.visible = false
	controls_box.visible = true
	back_button.grab_focus()


func _on_play() -> void:
	get_tree().change_scene_to_file(LEVEL_SCENE)


func _on_quit() -> void:
	get_tree().quit()
