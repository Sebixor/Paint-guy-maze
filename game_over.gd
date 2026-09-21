extends CanvasLayer

# Change this to the path of your main menu scene
const MENU_SCENE: String = "res://scenes/mainscenes/main_menu.tscn"

const BG_RED := Color(0.75, 0.05, 0.05, 0.92)   # set alpha to 1.0 for a fully solid red


func _ready() -> void:
	# keep working while the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100

	# red overlay
	var dim := ColorRect.new()
	dim.color = BG_RED
	add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# centered container for the title and buttons
	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	center.add_child(box)

	var title := Label.new()
	title.text = "Game Over"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color.BLACK)
	box.add_child(title)

	var retry := Button.new()
	retry.text = "Retry"
	retry.pressed.connect(_on_retry)
	box.add_child(retry)

	var menu := Button.new()
	menu.text = "Return to menu"
	menu.pressed.connect(_on_menu)
	box.add_child(menu)

	retry.grab_focus()   # lets you confirm with keyboard/gamepad


func _on_retry() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)
