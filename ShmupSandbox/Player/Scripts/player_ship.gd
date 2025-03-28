extends CharacterBody2D

@export var _speed : float
@export var _acceleration : float
@export var _damping : float

@onready var body: AnimatedSprite2D = %Body
@onready var thrusterL : AnimatedSprite2D = %ThrusterL
@onready var thrusterR : AnimatedSprite2D = %ThrusterR
@onready var muzzle_flash_l: AnimatedSprite2D = %MuzzleFlashL
@onready var muzzle_flash_r: AnimatedSprite2D = %MuzzleFlashR

func _ready() -> void:
	body.play("idle")
	thrusterL.play("idle")
	thrusterR.play("idle")
	muzzle_flash_l.play("idle")
	muzzle_flash_r.play("idle")

func _physics_process(delta: float) -> void:
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * _speed
	else:
		velocity.x = move_toward(velocity.x, 0, _speed)

	move_and_slide()
