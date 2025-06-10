class_name PickupScore extends Area2D

@onready var items_container : Node2D = $sprites_container
@onready var item_small : AnimatedSprite2D = %sprite_small
@onready var item_medium : AnimatedSprite2D = %sprite_medium
@onready var item_large : AnimatedSprite2D = %sprite_large
@onready var score_label : Label = %score_label

@export var speed : float = 200.0

var items_list : Array[AnimatedSprite2D] = []
var current_item : AnimatedSprite2D

const score_small : int = 500
const score_medium : int = 1500
const score_large : int = 3000

## TODO:
	# There are 3 varieties: small, medium and large
	# When spawned, will pick at random from small, medium or large
	# Based on the type, the relevant sprite will be visible, all others will not be visible
	# Based on the type, score added to player will be different
	# Each collected item will increase count (in GameManager)

################################################
#NOTE: Ready and its helper funcs
################################################
func _ready() -> void:
	_create_items_list()
	_set_current_item()
	score_label.visible = false

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

		# Play collect animations, for both sprites and label
		# TODO

		# Send global signal that item was picked up
		SignalsBus.score_increased_event.emit(_item_score())

		# Despawn pickup
		# TODO: await animations to be finished
		call_deferred("queue_free")

func _item_score() -> int:
	var score : int
	match current_item:
		item_small:
			score = score_small
		item_medium:
			score = score_medium
		item_large:
			score = score_large
	
	return score
