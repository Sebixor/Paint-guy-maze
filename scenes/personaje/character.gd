extends CharacterBody2D

@export var animacion: AnimatedSprite2D
@export var area_2d: Area2D



var _muerto: bool = false

const GameOverScreen = preload("res://game_over.gd") 
const _vrun: float = 100.0
const _vjump: float = -300.0
const _vslide: float = 60.0

# dash
const _vdash: float = 400.0
const _dash_time: float = 0.2        
const _dash_cooldown: float = 0.5    

# dash trail
const _ghost_interval: float = 0.03  
const _ghost_alpha: float = 0.6      
const _ghost_fade: float = 0.3      
const _ghost_z: int = 10             

var facing: int = 1
var turn: bool = false

var dashing: bool = false
var dash_timer: float = 0.0
var dash_cd: float = 0.0
var dash_dir: int = 1
var can_air_dash: bool = true
var ghost_timer: float = 0.0


func _ready() -> void:
	animacion.sprite_frames.set_animation_loop("RunTurn", false)
	animacion.sprite_frames.set_animation_loop("JumpTurn", false)
	animacion.animation_finished.connect(_on_animation_finished)
	area_2d.body_entered.connect(_on_area_2d_body_entered)


func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta

	var direction := int(Input.get_axis("ui_left", "ui_right"))

	# timers / resets
	dash_cd = max(dash_cd - delta, 0.0)
	if is_on_floor():
		can_air_dash = true

	# start dash
	if Input.is_action_just_pressed("dash") and not dashing and dash_cd <= 0.0 \
			and (is_on_floor() or can_air_dash):
		dashing = true
		dash_timer = _dash_time
		dash_dir = direction if direction != 0 else facing
		facing = dash_dir
		turn = false
		if not is_on_floor():
			can_air_dash = false
		animacion.flip_h = facing < 0
		animacion.play("Dash")
		ghost_timer = 0.0

	# while dashing
	if dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			dashing = false
			dash_cd = _dash_cooldown
		else:
			velocity.x = dash_dir * _vdash
			velocity.y = 0.0

			ghost_timer -= delta
			if ghost_timer <= 0.0:
				_spawn_ghost()
				ghost_timer = _ghost_interval

			move_and_slide()
			return

	# jump
	if is_on_floor() and Input.is_action_just_pressed("ui_accept") or is_on_wall() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = _vjump

	# horizontal
	velocity.x = direction * _vrun

	if direction != 0 and direction != facing and not turn:
		turn = true
		animacion.play("RunTurn" if is_on_floor() else "JumpTurn")

	# wall slide
	var sliding := is_on_wall_only() and velocity.y > 0 and direction != 0
	if sliding:
		velocity.y = min(velocity.y, _vslide)
		turn = false
		facing = int(sign(get_wall_normal().x))

	move_and_slide()
	_update_animation(direction, sliding)


func _update_animation(dir: int, sliding: bool) -> void:
	if turn:
		var turning_now: bool = animacion.is_playing() and (animacion.animation == &"RunTurn" or animacion.animation == &"JumpTurn")
		if turning_now:
			return
		turn = false

	animacion.flip_h = facing < 0

	if sliding:
		if animacion.animation != &"wallSlide":
			animacion.play("wallSlide")
	elif not is_on_floor():
		if animacion.animation != &"jump":
			animacion.play("jump")
	elif dir != 0:
		if animacion.animation != &"Run" or not animacion.is_playing():
			animacion.play("Run")
	else:
		animacion.play("Run")
		animacion.pause()
		animacion.frame = 0


func _spawn_ghost() -> void:
	var tex := animacion.sprite_frames.get_frame_texture(animacion.animation, animacion.frame)
	if tex == null:
		print("ghost: no texture for ", animacion.animation, " frame ", animacion.frame)
		return

	var ghost := Sprite2D.new()
	ghost.texture = tex
	ghost.centered = animacion.centered
	ghost.offset = animacion.offset
	ghost.flip_h = animacion.flip_h
	ghost.texture_filter = animacion.texture_filter
	ghost.z_index = _ghost_z
	ghost.modulate = Color(1, 1, 1, _ghost_alpha)

	get_tree().current_scene.add_child(ghost)      
	ghost.global_position = animacion.global_position
	ghost.global_scale = animacion.global_scale

	

	var tween := ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, _ghost_fade)
	tween.tween_callback(ghost.queue_free)


func _on_animation_finished() -> void:
	if turn:
		turn = false
		facing = -facing
		animacion.flip_h = facing < 0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if _muerto:
		return
	_muerto = true
	get_tree().current_scene.add_child(GameOverScreen.new())
	get_tree().paused = true
