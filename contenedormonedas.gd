extends Node

class_name ContenedorMonedas

const WinScreen = preload("res://win_screen.gd")  

var _total_monedas: int
var _monedas_recogidas: int

func _ready() -> void:
	var monedas := get_children()
	_total_monedas = monedas.size()
	
	for moneda in monedas: 
		moneda.contenedormonedas = self
	
func monedarecogida():
	_monedas_recogidas += 1
	
	if _monedas_recogidas == _total_monedas:
		_show_win_screen()

func _show_win_screen() -> void:
	if get_tree().paused:
		return   
	get_tree().current_scene.add_child(WinScreen.new())
	get_tree().paused = true
