extends CharacterBody2D

## Velocity
@export var _max_speed : float
@export var _acceleration : float
@export var _damping : float

## Sprites
@onready var body: AnimatedSprite2D = %Body
@onready var thrusterL : AnimatedSprite2D = %ThrusterL
@onready var thrusterR : AnimatedSprite2D = %ThrusterR
@onready var muzzle_flash_l: AnimatedSprite2D = %MuzzleFlashL
@onready var muzzle_flash_r: AnimatedSprite2D = %MuzzleFlashR

## Muzzle
@onready var muzzle_l : Marker2D = %MuzzleL
@onready var muzzle_r : Marker2D = %MuzzleR

## Timers
@onready var shot_cooldown_timer : Timer = %shot_cooldown_timer

## Packed scenes
var bullet : PackedScene = preload("res://ShmupSandbox/Player/Scenes/player_bullet.tscn")

var min_bounds : Vector2 = Vector2(0, 0)
var max_bounds : Vector2 = Vector2(720, 1280)
var on_shooting_cooldown : bool

func _ready() -> void:
	body.play("idle")
	thrusterL.play("idle")
	thrusterR.play("idle")
	muzzle_flash_l.play("idle")
	muzzle_flash_r.play("idle")

func handle_input(delta) -> void:
	var input_dir := Vector2.ZERO
	
	# Get input direction
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	input_dir = input_dir.normalized()  # Normalize for diagonal movement
	
	# Acceleration
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * _max_speed, _acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, _damping * delta)

func clamp_movement_to_screen_bounds() -> void:
	# Clamp position within bounds
	var offset : float = 20.0
	
	position.x = clamp(position.x, offset - min_bounds.x, max_bounds.x - offset)
	position.y = clamp(position.y, offset - min_bounds.y, max_bounds.y - offset)

func handle_shooting() -> void:
	if Input.is_action_pressed("attack") && !on_shooting_cooldown:
		on_shooting_cooldown = true
		shot_cooldown_timer.start()
		
		var bullet_instance_l := bullet.instantiate()
		var bullet_instance_r := bullet.instantiate()
		bullet_instance_l.position = muzzle_l.global_position
		bullet_instance_r.position = muzzle_r.global_position
		get_tree().current_scene.add_child(bullet_instance_l)
		get_tree().current_scene.add_child(bullet_instance_r)

func _physics_process(delta):
	handle_input(delta)
	move_and_slide()

func _process(_delta: float) -> void:
	clamp_movement_to_screen_bounds()
	handle_shooting()

## Signal connections
func _on_shot_cooldown_timer_timeout() -> void:
	on_shooting_cooldown = false
