extends CanvasLayer

# Change this to the path of your main menu scene
const MENU_SCENE: String = "res://scenes/mainscenes/main_menu.tscn"


func _ready() -> void:
	# keep working while the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100

	# dark overlay
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
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
	title.text = "Level Complete!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	box.add_child(title)

	var again := Button.new()
	again.text = "Play again"
	again.pressed.connect(_on_again)
	box.add_child(again)

	var menu := Button.new()
	menu.text = "Return to menu"
	menu.pressed.connect(_on_menu)
	box.add_child(menu)

	again.grab_focus()   


func _on_again() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)
