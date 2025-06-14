class_name PickupScore extends Area2D

@onready var items_container : Node2D = $sprites_container
@onready var item_level_1 : AnimatedSprite2D = %sprite_level_1
@onready var item_level_2 : AnimatedSprite2D = %sprite_level_2
@onready var item_level_3 : AnimatedSprite2D = %sprite_level_3
@onready var item_level_4 : AnimatedSprite2D = %sprite_level_4
@onready var score_label : Label = %score_label

@export var speed : float = 200.0

var items_list : Array[AnimatedSprite2D] = []
var current_item : AnimatedSprite2D

const score_level_1 : int = 500
const score_level_2 : int = 1000
const score_level_3 : int = 2000
const score_level_4 : int = 4000


## TODO Score item pickup:
	# 4 levels
	# Always spawns as level 1
	# When player kills enemy, soul fragments travel to nearest non maxed item and item level +1
	# If player dies without picking up item, item despawns
	# Need new spritesheets for level 1-4 spawn, idle, despawn and collect animations
	# Need scene and sprites for soul fragments
	# Create a new container in Game scene specifically for score items:
		# - this should make it easier to find the nearest non max item
		# - do i need to have an int in pickup_score.gd to track current level?

################################################
#NOTE: Ready and its helper funcs
################################################
func _ready() -> void:
	_create_items_list()
	_set_current_item()

	# Play spawn animation then play idle
	current_item.play("spawn")
	await current_item.animation_finished
	current_item.play("idle")

func _create_items_list() -> void:
	for node : Node in items_container.get_children():
		if node is AnimatedSprite2D:
			items_list.append(node)

func _set_current_item() -> void:
	current_item = item_level_1

	for item_sprite : AnimatedSprite2D in items_list:
		if item_sprite == current_item:
			item_sprite.visible = true
		else:
			item_sprite.visible = false
			item_sprite.stop()


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
		print_debug("player picked up item, add score!")

		# Disable collider area
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)

		# Stop moving
		speed = 0

		# Play collect animations for sprite and label (tween)
		current_item.play("collect")
		var tween : Tween = _play_collect_animation_for_label()

		# Send global signal that item was picked up
		SignalsBus.score_increased_event.emit(_item_score())

		# Despawn pickup
		await current_item.animation_finished
		await tween.finished
		call_deferred("queue_free")


func _play_collect_animation_for_label() -> Tween:
	# Set label value
	score_label.text = str(_item_score())

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


func _item_score() -> int:
	var score : int
	match current_item:
		item_level_1:
			score = score_level_1
		item_level_2:
			score = score_level_2
		item_level_3:
			score = score_level_3
		item_level_4:
			score = score_level_4
	
	return score
