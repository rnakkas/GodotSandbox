class_name PickupScore extends Area2D

@onready var collider_level_1 : CollisionShape2D = $collider_level_1
@onready var collider_level_2 : CollisionShape2D = $collider_level_2
@onready var collider_level_3 : CollisionShape2D = $collider_level_3
@onready var collider_level_4 : CollisionShape2D = $collider_level_4

@onready var items_container : Node2D = $sprites_container

@onready var item_level_1 : AnimatedSprite2D = %sprite_level_1
@onready var item_level_2 : AnimatedSprite2D = %sprite_level_2
@onready var item_level_3 : AnimatedSprite2D = %sprite_level_3
@onready var item_level_4 : AnimatedSprite2D = %sprite_level_4

@onready var score_label : Label = %score_label

const min_level : int = 1
const max_level : int = 4
const score_level_1 : int = 500
const score_level_2 : int = 1000
const score_level_3 : int = 2000
const score_level_4 : int = 4000

@export var speed : float = 50.0
@export_range(min_level,max_level) var level : int = 1

var items_list : Array[AnimatedSprite2D] = []
var current_item : AnimatedSprite2D
var current_score : int

var item_collider_map : Dictionary[AnimatedSprite2D, CollisionShape2D] = {}


## TODO Score item pickup:
	# Need spritesheets for score item levels 1-4

################################################
#NOTE: Ready and its helper funcs
################################################
func _ready() -> void:
	_create_item_collider_map()
	_set_current_item()
	score_label.visible = false

	_connect_to_signals()

	# Play spawn animation then play idle
	current_item.play("spawn")
	await current_item.animation_finished
	current_item.play("idle")


################################################
#NOTE: Helper func to create item and collider map
################################################
func _create_item_collider_map() -> void:
	item_collider_map = {
	item_level_1 : collider_level_1,
	item_level_2 : collider_level_2,
	item_level_3 : collider_level_3,
	item_level_4 : collider_level_4,
}


################################################
#NOTE: Helper func to set current item sprite, score and collider
################################################
func _set_current_item() -> void:
	# Set current item sprite and score as per level
	match level:
		1:
			current_item = item_level_1
			current_score = score_level_1
		2:
			current_item = item_level_2
			current_score = score_level_2
		3:
			current_item = item_level_3
			current_score = score_level_3
		4:
			current_item = item_level_4
			current_score = score_level_4
		_:
			push_error("invalid item level, level should be between 1 to 4")

	# Enable sprite and collider for current item level, disable all others
	for item : AnimatedSprite2D in item_collider_map.keys():
		if item == current_item:
			item.visible = true
			item_collider_map[item].set_deferred("disabled", false)
		else:
			item.visible = false
			item.stop()
			item_collider_map[item].set_deferred("disabled", true)


################################################
#NOTE: Signal connections and funcs
################################################
func _connect_to_signals() -> void:
	SignalsBus.player_death_event.connect(_on_player_death_event)

func _on_player_death_event() -> void:
	# Despawn on player death
	# TODO: Despawn animations
	call_deferred("queue_free")


################################################
#NOTE: Physics process
################################################
func _physics_process(delta: float) -> void:
	global_position += speed * delta * Vector2.LEFT


################################################
#NOTE: Signal connection, when item leaves screen, it's despawned
################################################
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	call_deferred("queue_free")


################################################
#NOTE: Signal connection, logic for player picking up item
################################################
func _on_body_entered(body: Node2D) -> void:
	if body is PlayerCat:
		# Disable area to prevent further pickups
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)

		# Stop moving
		speed = 0

		# Play collect animations for sprite and label (tween)
		current_item.play("collect")
		var tween : Tween = _play_collect_animation_for_label()

		# Send global signal that item was picked up
		SignalsBus.score_increased_event.emit(current_score)

		# Despawn pickup
		await current_item.animation_finished
		await tween.finished
		call_deferred("queue_free")


func _play_collect_animation_for_label() -> Tween:
	# Set label value
	score_label.text = str(current_score)

	# Make label visible
	score_label.visible = true

	# Tween the label when powerup collected
	var tween = get_tree().create_tween()
	var final_position : Vector2 = Vector2(score_label.position.x, score_label.position.y - 35.0)

	tween.set_parallel(true)

	tween.tween_property(score_label, "self_modulate", UiUtility.color_yellow, 0.3)
	tween.tween_property(score_label, "position", final_position, 0.2)

	tween.set_parallel(false)

	# Blinking effect of yellow and white
	tween.tween_property(score_label, "self_modulate", UiUtility.color_white, 0.1)
	tween.tween_property(score_label, "self_modulate", UiUtility.color_yellow, 0.1)
	tween.tween_property(score_label, "self_modulate", UiUtility.color_white, 0.1)
	tween.tween_property(score_label, "self_modulate", UiUtility.color_yellow, 0.1)
	tween.tween_property(score_label, "self_modulate", UiUtility.color_white, 0.1)
	tween.tween_property(score_label, "self_modulate", UiUtility.color_yellow, 0.1)

 	# Fade out effect
	tween.tween_property(score_label, "self_modulate", UiUtility.color_transparent, 0.5)

	return tween


################################################
#NOTE: Signal connection, logic for when soul fragment hits the score item
################################################
func _on_area_entered(area:Area2D) -> void:
	if area is ScoreFragment:
		# Only accept soul fragment that is meant for this instance of score item
		if area.nearest_non_maxed_score_item == self && level < max_level:
			# Clamp level between 1 and 4
			level = clamp(level+1, min_level, max_level)
			_set_current_item()
