class_name ScreamerVar3 extends Node2D

@onready var sprite : AnimatedSprite2D = $sprite
@onready var particles : CPUParticles2D = $CPUParticles2D
@onready var shoot_timer : Timer = $shoot_timer

@export var base_speed : float = 250.0
@export var max_speed : float = 510.0
@export var acceleration : float = 225.0
@export var deceleration : float = 80.0
@export var kill_score : int = 100
@export var shoot_time : float = 0.6

var speed : float
var velocity : Vector2
var direction : Vector2

## TODO: Spritesheets

################################################
# NOTE: Screamer Variant 3
# Popcorn enemy
# Flies in from the right
# Fly in straight line from right to left
# Slow down and shoot when on screen
# Then Accelerate to max speed when on screen
# Shoot once when on screen
################################################

################################################
# NOTE: Ready
################################################
func _ready() -> void:
    speed = base_speed
    velocity = speed * Vector2.LEFT
    Helper.set_timer_properties(shoot_timer, true, shoot_time)


################################################
# NOTE: Movement logic
################################################
func _physics_process(delta: float) -> void:
    if direction == Vector2.ZERO:
        velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
    if speed == max_speed:
        velocity = velocity.move_toward(speed * Vector2.LEFT, acceleration * delta)
    global_position += velocity * delta


################################################
# NOTE: Slow down and start timer for shooting when on screen
################################################
func _on_screen_notifier_screen_entered() -> void:
    direction = Vector2.ZERO
    shoot_timer.start()


################################################
# NOTE: Despawn after going offscreen
################################################
func _on_screen_notifier_screen_exited() -> void:
    call_deferred("queue_free")


################################################
# NOTE: Shooting logic
################################################
func _on_shoot_timer_timeout() -> void:
    # Set speed to max to accelerate to
    direction = Vector2.LEFT
    speed = max_speed

    # Don't shoot if player is dead
    if GameManager.player.is_dead:
        return
    
    # Main shooting logic
    var player_position : Vector2 = self.global_position.direction_to(GameManager.player.global_position)
    var bullets_list : Array[Area2D] = []
    var bullet : ScreamerBullet = SceneManager.screamer_bullet_scene.instantiate()
    
    bullet.global_position = self.global_position
    bullet.direction = player_position
    bullets_list.append(bullet)
    
    SignalsBus.enemy_shooting_event.emit(bullets_list)


################################################
# NOTE: Getting hit by player attacks logic:
	# Signal connections from damage taker component
################################################
func _on_damage_taker_component_health_depleted() -> void:
    shoot_timer.stop()

    speed = speed/2

    sprite.play("death")
    particles.emitting = true

    SignalsBus.score_increased_event.emit(kill_score)
    SignalsBus.spawn_score_fragment_event.emit(self.global_position)

    await sprite.animation_finished

    call_deferred("queue_free")
