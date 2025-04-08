class_name player_cat extends CharacterBody2D

## Velocity
@export var _max_speed : float = 450.0
@export var _acceleration : float = 1600.0
@export var _damping : float = 1200.0

## Shooting
@export var fire_rate : float = 4.0
@export var bullet_scene : PackedScene = preload("res://ShmupSandbox/Player/Scenes/player_bullet.tscn")

## Sprites
@onready var body: AnimatedSprite2D = %body
@onready var muzzle_flash: AnimatedSprite2D = %muzzle_flash

## Muzzle
@onready var muzzle : Marker2D = %muzzle

## Hurtbox
@onready var hurtbox : Area2D = $hurtbox

## Custom signals
signal shooting(bullet_scene:PackedScene, locations:Array[Vector2])


var viewport_size : Vector2
var shooting_cooldown_time : float
var on_shooting_cooldown : bool
var is_dead : bool

func _ready() -> void:
	body.play("idle")
	muzzle_flash.play("idle")
	
	viewport_size = get_viewport_rect().size
	shooting_cooldown_time = 1/fire_rate


func handle_movement(delta) -> void:
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
	var min_bounds : Vector2 = Vector2(0, 0)
	var max_bounds : Vector2 = viewport_size
	var offset : float = 20.0
	
	position.x = clamp(position.x, offset - min_bounds.x, max_bounds.x - offset)
	position.y = clamp(position.y, offset - min_bounds.y, max_bounds.y - offset)

func handle_shooting() -> void:
	if is_dead:
		return
	if Input.is_action_pressed("shoot"):
		if !on_shooting_cooldown:
			on_shooting_cooldown = true
			
			var locations : Array[Vector2] = [muzzle.global_position]
			shooting.emit(bullet_scene, locations)
			
			body.play("shoot")
			muzzle_flash.play("shoot")
			
			await get_tree().create_timer(shooting_cooldown_time).timeout
			on_shooting_cooldown = false
	else:
		body.play("idle")

func _physics_process(delta):
	if is_dead:
		return
	handle_movement(delta)
	move_and_slide()

func _process(_delta: float) -> void:
	clamp_movement_to_screen_bounds()
	handle_shooting()

## Hit by enemy or enemy projectiles
func _on_hurtbox_area_entered(_area: Area2D) -> void:
	is_dead = true
	
	velocity = Vector2.ZERO
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	
	muzzle_flash.play("idle")
	body.play("death")
	await body.animation_finished
	
	queue_free()
	
