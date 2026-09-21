extends Node2D


@export var area_2d: Area2D

var contenedormonedas: ContenedorMonedas

func _ready() -> void:
	area_2d.body_entered.connect(_recoger)
	


func _recoger(_body):
	contenedormonedas.monedarecogida()
	
	queue_free()
	
