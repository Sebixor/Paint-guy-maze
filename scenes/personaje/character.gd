extends CharacterBody2D
@export var animacion: Node

const _vwalk: float = 100.0
const _vrun: float = 200.0
const _vjump: float = -300.0

func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta
	

	
	if is_on_floor() && Input.is_action_just_pressed("ui_accept"):
		velocity.y = _vjump
		animacion.play("jump")
	
	if Input.is_action_pressed("ui_right"):
		velocity.x = _vwalk
		animacion.play("walk")
		
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -_vwalk
		animacion.play("walk")
	else:
		velocity.x = 0
		animacion.play("idle")
		
	move_and_slide()
