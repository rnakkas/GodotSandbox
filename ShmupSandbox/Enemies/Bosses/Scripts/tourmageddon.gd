class_name BossTourmageddon extends Node2D

# Boss behaviour:
	# Has very high health (similar to other bosses) -> max_hp: 2000
	# Slowly fly in from the right
	# Stay on the right side of the screen
	# Behaviour 1: -> PHASE_1
		# Move vertically down
		# Slow to a stop near bottom of screen
		# Shoot from the roof cannons for a set amount of time
		# Rapidly move to the left of the screen to try and crush the player, then fly back to right of screen
		# Move vertically up
		# Slow to a stop near the top of the screen
		# Shoot from the roof cannons for a set amount of time
		# Rapidly move to the right of the screen to try and crush the player, then fly back to right of screen
		# Repeat
	# Behaviour 2: -> PHASE_2
		# Similar movements as behaviour 1 but no stopping at the top and bottom, constant moving up and down
		# Shoot from the roof cannons at a steady pace
		# Also spawn skulljacks, screamers and boomers from the door
		# No rapid move to the left to try and crush the player
	# Spawn, then go to PHASE_1
	# After health drops below a certain percentage, go to PHASE_2
	# PHASE_2 can also start after a certain amount of time has passed
	# Fly off to the left of the screen to go off screen and despawn after screen time (~10 mins) has elapsed
		# This is to keep the game going even if the player fails to kill the boss
	# Once boss is killed or flies off screen, send a global signal that boss sequence has ended.
#
# Signals:
	# When boss spawns, send a global signal that boss sequence has started - DONE
	# When boss dies or has fled, send a global signal that boss sequence has ended, 
	# 	true for boss killed, false for boss not killed, and kill score - DONE
#
# Use kill_score for stage clear boss kill bonus
# Kill bonus will display the boss name, for example "Tourmageddon Kill Bonus: 60,000"
# Boss will be spawned as part of enemy schedule, using the spawn_enemy_event() signal - DONE

@onready var damage_taker_component: DamageTakerComponent = $DamageTakerComponent
@onready var sprite: AnimatedSprite2D = $sprite
@onready var enemy_shooting_component: EnemyShootingComponent = $EnemyShootingComponent

# Timers
@onready var shoot_timer: Timer = %shoot_timer
@onready var groupie_timer: Timer = $groupie_timer
@onready var screen_timer: Timer = $screen_timer

# Screen notifiers
@onready var initial_onscreen_notifier: VisibleOnScreenNotifier2D = %initial_onscreen_notifier
@onready var screen_notifier_bottom: VisibleOnScreenNotifier2D = %screen_notifier_bottom
@onready var screen_notifier_top: VisibleOnScreenNotifier2D = %screen_notifier_top
@onready var screen_notifier_left: VisibleOnScreenNotifier2D = %screen_notifier_left
@onready var screen_notifier_right: VisibleOnScreenNotifier2D = %screen_notifier_right

# Muzzles
@onready var marker_cannon_1: Marker2D = %marker_cannon_1
@onready var marker_cannon_2: Marker2D = %marker_cannon_2
@onready var marker_cannon_3: Marker2D = %marker_cannon_3
@onready var marker_door: Marker2D = %marker_door

# Thruster
@onready var thruster_attack_area: Area2D = $thruster_attack_area
@onready var thruster_sprite: AnimatedSprite2D = %thruster_sprite

# DEBUG
@onready var debug_label_state: Label = $debug_label_state
@onready var debug_label_health: Label = $debug_label_health


######################################################
# Exported vars
######################################################
@export var offscreen_speed: float = 400.0
@export var onscreen_speed_y: float = 100.0
@export var onscreen_speed_x: float = 450.0
@export var acceleration: float = 1000.0
@export var deceleration: float = 2000.0
@export var kill_score: int = 60000
@export var screen_time: float = 600.0 # 10 minute screen time
@export var hang_time: float = 2.75
@export var shot_limit: int = 6
@export var phase_2_bullets_per_shot: int = 5
@export var phase_2_bullet_spread: float = 55.0
@export var phase_2_shot_time: float = 4.5
@export var phase_2_groupie_time: float = 4.0
@export var groupie_list: Array[PackedScene] = []

## Boss phases
enum state {
	SPAWN,
	PHASE_1,
	PHASE_2,
	DEATH,
	FLEE
}

var current_state: state
var speed: float
var direction: Vector2 = Vector2.LEFT
var velocity: Vector2
var viewport_size: Vector2
var shot_count: int
var dir_to_offscreen: Vector2

######################################################
# Ready
######################################################
func _ready() -> void:
	_connect_to_signals()
	current_state = state.SPAWN
	speed = offscreen_speed
	viewport_size = get_viewport_rect().size
	enemy_shooting_component.position = marker_cannon_1.position

	# Don't do thruster attack
	_thruster_attack(false)

	# Set timer properties
	Helper.set_timer_properties(groupie_timer, false, phase_2_groupie_time)
	Helper.set_timer_properties(screen_timer, true, screen_time)

	# List of enemies that fly out to attack the player in phase 2
	# TODO: Currently using existing enemies:
		# Create resprites of skulljack and boomer enemies
	groupie_list = [
		SceneManager.skulljack_PS,
		SceneManager.boomer_PS,
		SceneManager.skulljack_PS,
		SceneManager.boomer_PS
	]
	
	SignalsBus.boss_sequence_started_event.emit(self)

	# DEBUG: Debug related stuff
	_debug_update()


######################################################
# Connect to all the signals
######################################################
func _connect_to_signals() -> void:
	damage_taker_component.damage_taken.connect(self._on_damage_taker_component_damage_taken)
	damage_taker_component.low_health.connect(self._on_damage_taker_component_low_health)
	damage_taker_component.health_depleted.connect(self._on_damage_taker_component_health_depleted)

	# Screen notifiers
	initial_onscreen_notifier.screen_entered.connect(self._initial_onscreen_notifier_screen_entered)
	initial_onscreen_notifier.screen_exited.connect(self._initial_onscreen_notifier_screen_exited)
	screen_notifier_bottom.screen_exited.connect(self._screen_bottom_reached)
	screen_notifier_top.screen_exited.connect(self._screen_top_reached)
	screen_notifier_left.screen_exited.connect(self._screen_left_reached)
	screen_notifier_right.screen_exited.connect(self._screen_right_reached)

	# Timer
	shoot_timer.timeout.connect(self._on_shoot_timer_timeout)
	groupie_timer.timeout.connect(self._on_groupie_timer_timeout)
	screen_timer.timeout.connect(self._on_screen_timer_timeout)

#
#
######################################################
# Main behaviour logic for different phases
######################################################
#
#

## When boss first comes onto the screen
func _initial_onscreen_notifier_screen_entered() -> void:
	current_state = state.PHASE_1
	speed = onscreen_speed_y
	direction = Vector2.ZERO

	await get_tree().create_timer(hang_time).timeout
	shoot_timer.start()
	screen_timer.start()
	direction = Vector2.DOWN
	
	_debug_update()

## When boss exits the screen after fleeing
func _initial_onscreen_notifier_screen_exited() -> void:
	SignalsBus.boss_sequence_ended_event.emit(false, 0)
	call_deferred("queue_free")

## When boss reaches the bottom of the screen.
	## For phase 1, stop for a bit, then rapidly move left to crush player.
	## For phase 2. no stopping, keep moving up and down
func _screen_bottom_reached() -> void:
	match current_state:
		state.PHASE_1:
			direction = Vector2.ZERO
			await get_tree().create_timer(hang_time).timeout
			speed = onscreen_speed_x
			direction = Vector2.LEFT
		state.PHASE_2:
			direction = Vector2.UP
			if groupie_timer.is_stopped():
				groupie_timer.start()

## When boss reaches the left of the screen.
	## For phase 1, stop for a bit, play the thruster attack, then move back to the right.
	## For phase 2, if the phase transition happens during this phase, complete this behaviour then go to phase 2 behaviour.
func _screen_left_reached() -> void:
	match current_state:
		state.PHASE_1, state.PHASE_2:
			direction = Vector2.ZERO

			_thruster_attack(true)

			await get_tree().create_timer(hang_time * 0.5).timeout
			speed = onscreen_speed_x * 0.3
			direction = Vector2.RIGHT

## When boss reaches the right of the screen.
	## For phase 1, stop for a bit, stop the thruster attack, shoot,  then fly either up or down based on screen position
	## If phase transition to phase 2 happens here, complete this behaviour and then go to phase 2. Also start the groupie timer.
func _screen_right_reached() -> void:
	var dist_to_top: float = self.global_position.y
	var dist_to_bot: float = viewport_size.y - self.global_position.y
	
	match current_state:
		state.PHASE_1, state.PHASE_2:
			direction = Vector2.ZERO

			await get_tree().create_timer(hang_time * 0.5).timeout
			_thruster_attack(false)
			await get_tree().create_timer(hang_time * 0.5).timeout
			
			shoot_timer.start()

			
			await get_tree().create_timer(hang_time).timeout
			speed = onscreen_speed_y

			if dist_to_top <= dist_to_bot:
				direction = Vector2.DOWN
			elif dist_to_top > dist_to_bot:
				direction = Vector2.UP
			
			shoot_timer.start()

			if current_state == state.PHASE_2:
				if groupie_timer.is_stopped():
					groupie_timer.start()
	
## When boss reaches top of the screen.
	## If phase 1, stop for a bit, then move left to crush player
	## If phase 2, keep moving up and down
func _screen_top_reached() -> void:
	match current_state:
		state.PHASE_1:
			direction = Vector2.ZERO
			await get_tree().create_timer(hang_time).timeout
			speed = onscreen_speed_x
			direction = Vector2.LEFT
		state.PHASE_2:
			direction = Vector2.DOWN
			if groupie_timer.is_stopped():
				groupie_timer.start()


## Shooting behaviour.
	## Shoot from each of the muzzles in sequence
func _on_shoot_timer_timeout() -> void:
	shot_count += 1
	if shot_count >= shot_limit:
		shoot_timer.stop()
		shot_count = 0
		enemy_shooting_component.position = marker_cannon_1.position
		if current_state == state.PHASE_2:
			await get_tree().create_timer(phase_2_shot_time).timeout
			shoot_timer.start()
		return

	# Logic to move the shooting component to next muzzle
	match shot_count:
		1, 4:
			enemy_shooting_component.position = marker_cannon_2.position
		2, 5:
			enemy_shooting_component.position = marker_cannon_3.position
		3, 6:
			enemy_shooting_component.position = marker_cannon_1.position
	
## For phase 2, groupies will fly out from the door towards player
func _on_groupie_timer_timeout() -> void:
	for groupie: PackedScene in groupie_list:
		await get_tree().create_timer(0.5).timeout
		SignalsBus.spawn_enemy_event.emit(groupie, marker_door.global_position, "")

## When boss timer runs out, boss will flee
func _on_screen_timer_timeout() -> void:
	current_state = state.FLEE
	dir_to_offscreen = self.global_position.direction_to(Vector2(0, viewport_size.y / 2))
	direction = dir_to_offscreen
	shoot_timer.stop()
	groupie_timer.stop()

	_debug_update()


## Helper function for thruster attack
func _thruster_attack(can_attack: bool) -> void:
	if can_attack:
		thruster_sprite.play("attack")
	else:
		thruster_sprite.play("none")
		
	thruster_attack_area.visible = can_attack
	thruster_attack_area.set_deferred("monitorable", can_attack)
	thruster_attack_area.set_deferred("monitoring", can_attack)

## When the boss is fleeing, set the direction to the offscreen towards left of screen
func _process(_delta: float) -> void:
	if current_state == state.FLEE:
		direction = dir_to_offscreen

## Movement and velocity logic
func _physics_process(delta: float) -> void:
	match current_state:
		state.SPAWN:
			velocity = speed * direction
		state.PHASE_1, state.PHASE_2, state.FLEE:
			if direction != Vector2.ZERO:
				velocity = velocity.move_toward(speed * direction, acceleration * delta)
			else:
				velocity = velocity.move_toward(speed * direction, deceleration * delta)
	
	global_position += velocity * delta


################################################
# Getting hit by player attacks logic:
	# Signal connections from damage taker component
################################################
func _on_damage_taker_component_damage_taken() -> void:
	SignalsBus.score_increased_event.emit(GameManager.attack_hit_score)
	_debug_update()

func _on_damage_taker_component_low_health() -> void:
	sprite.play("damaged")
	current_state = state.PHASE_2
	
	enemy_shooting_component.bullets_per_shot = phase_2_bullets_per_shot
	enemy_shooting_component.shot_spread_angle = phase_2_bullet_spread

	_debug_update()

func _on_damage_taker_component_health_depleted() -> void:
	shoot_timer.stop()
	groupie_timer.stop()
	
	sprite.play("death")

	current_state = state.DEATH
	direction = Vector2.DOWN
	speed = onscreen_speed_x * 0.5
	
	# Signal to spawn score fragments on death
	SignalsBus.spawn_score_fragment_event.emit(self.global_position)

	# Signal that boss was killed
	SignalsBus.boss_sequence_ended_event.emit(self, true, kill_score)

	await sprite.animation_finished

	call_deferred("queue_free")


######################################################

######################################################
# DEBUG
######################################################

# DEBUG: Debug related stuff, remove when done
func _debug_update() -> void:
	if OS.is_debug_build():
		debug_label_state.visible = true
		debug_label_state.text = "Current State " + str(state.find_key(current_state))
		debug_label_health.visible = true
		debug_label_health.text = "Current Health: " + str(damage_taker_component.hp)
	else:
		debug_label_state.visible = false
		debug_label_health.visible = false
