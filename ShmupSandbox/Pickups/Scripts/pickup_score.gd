class_name PickupScore extends Area2D

@onready var items_container : Node2D = $sprites_container
@onready var item_small : AnimatedSprite2D = %sprite_small
@onready var item_large : AnimatedSprite2D = %sprite_large

@export var speed : float = 200.0

var items_list : Array[AnimatedSprite2D] = []
var current_item : AnimatedSprite2D

const score_small : int = 500
const score_medium : int = 1500
const score_large : int = 3000

## Pickups for score:
	# There are 2 varieties: small and large
	# When spawned, will pick at random from small or large
	# Based on the type, the relevant sprite will be visible, all others will not be visible
	# Based on the type, score added to player will be different
	# Each collected item will increase count (in GameManager) TODO

################################################
#NOTE: Ready and its helper funcs
################################################
func _ready() -> void:
	_create_items_list()
	_set_current_item()

func _create_items_list() -> void:
	for node : Node in items_container.get_children():
		if node is AnimatedSprite2D:
			items_list.append(node)

func _set_current_item() -> void:
	current_item = items_list.pick_random()

	for item : AnimatedSprite2D in items_list:
		if item == current_item:
			item.visible = true
			item.play("idle")
		else:
			item.visible = false
			item.stop()


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

		# Play collect animations and tweens, for sprite
		var tween : Tween = _play_collect_animation()

		# Send global signal that item was picked up
		SignalsBus.score_increased_event.emit(_item_score())

		# Despawn pickup
		await current_item.animation_finished
		await tween.finished
		call_deferred("queue_free")


func _play_collect_animation() -> Tween:
	# Play collect animation for sprite
	current_item.play("collect")

	# Tween the sprite when powerup collected
	var tween = get_tree().create_tween()
	var final_position : Vector2 = Vector2(current_item.position.x, current_item.position.y - 50.0)

	tween.tween_property(current_item, "position", final_position, 0.2)

	tween.tween_property(current_item, "self_modulate", UiUtility.color_transparent, 0.8) # Fade out effect

	return tween


func _item_score() -> int:
	var score : int
	match current_item:
		item_small:
			score = score_small
		item_large:
			score = score_large
	
	return score
