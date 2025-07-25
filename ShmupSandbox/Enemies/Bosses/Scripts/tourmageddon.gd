class_name BossTourmageddon extends Node2D

##TODO:
# Boss behaviour:
	# Has very high health (similar to other bosses)
	# Slowly fly in from the right
	# Stay on the right side of the screen
	# Behaviour 1:
		# Move vertically down
		# Slow to a stop near bottom of screen
		# Shoot from the roof cannons for a set amount of time
		# Rapidly move to the left of the screen to try and crush the player, then fly back to right of screen
		# Move vertically up
		# Slow to a stop near the top of the screen
		# Shoot from the roof cannons for a set amount of time
		# Rapidly move to the right of the screen to try and crush the player, then fly back to right of screen
		# Repeat
	# Behaviour 2:
		# Similar movements as behaviour 1 but no stopping at the top and bottom, constant moving up and down
		# Shoot from the roof cannons at a steady pace
		# Also spawn skulljacks, screamers and boomers from the door
		# No rapid move to the left to try and crush the player
	# Spawn, play behaviour 1
	# After health drops below a certain percentage, start behaviour 2
	# Behaviour 2 can also start after a certain amount of time has passed
	# Fly off to the left of the screen to go off screen and despawn after screen time (~10 mins) has elapsed
		# This is to keep the game going even if the player fails to kill the boss
	# Once boss is killed or flies off screen, send a global signal that boss sequence has ended.
#
# Signals:
	# When boss spawns, send a global signal that boss sequence has started
	# When boss dies or has fled, send a global signal that boss sequesnce has ended
	# Boss will be spawned as part of enemy schedule, using the spawn_enemy_event() signal

@onready var damage_taker_component: DamageTakerComponent = $DamageTakerComponent
@onready var sprite: AnimatedSprite2D = $sprite
@onready var enemy_shooting_component: EnemyShootingComponent = $EnemyShootingComponent
@onready var shoot_timer: Timer = $shoot_timer
@onready var screen_notifier: VisibleOnScreenNotifier2D = $screen_notifier
@onready var debug_label_state: Label = $debug_label_state
@onready var debug_label_health: Label = $debug_label_health

@export var offscreen_speed: float = 500.0
@export var onscreen_speed: float = 100.0
@export var acceleration: float = 600.0
@export var deceleration: float = 900.0
@export var kill_score: int = 60000
@export var screen_time: float = 600.0 # 10 minute screen time
@export var move_time: float = 2.7
@export var pre_attack_time: float = 0.8
@export var post_attack_time: float = 1.2

var direction: Vector2 = Vector2.LEFT
var velocity: Vector2
var viewport_size: Vector2

enum state {
	SPAWN,
	PHASE_1,
	PHASE_2,
	DEATH,
	FLEE
}

var current_state: state

func _ready() -> void:
	_connect_to_signals()

	current_state = state.SPAWN

	velocity = offscreen_speed * direction

	# DEBUG: Debug related stuff, remove when done
	_debug_init()


func _connect_to_signals() -> void:
	damage_taker_component.damage_taken.connect(self._on_damage_taker_component_damage_taken)
	damage_taker_component.low_health.connect(self._on_damage_taker_component_low_health)
	damage_taker_component.health_depleted.connect(self._on_damage_taker_component_health_depleted)

	screen_notifier.screen_entered.connect(self._on_screen_notifier_screen_entered)


# DEBUG: Debug related stuff, remove when done
func _debug_init() -> void:
	if OS.is_debug_build():
		debug_label_state.visible = true
		debug_label_state.text = "Current State " + str(state.find_key(state.SPAWN))
		debug_label_health.visible = true
		debug_label_health.text = "Current Health: " + str(damage_taker_component.hp)
	else:
		debug_label_state.visible = false
		debug_label_health.visible = false


func _on_screen_notifier_screen_entered() -> void:
	current_state = state.PHASE_1
	

func _physics_process(delta: float) -> void:
	global_position += velocity * delta