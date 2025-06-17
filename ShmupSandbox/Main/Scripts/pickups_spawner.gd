class_name PickupsSpanwer extends Node2D

@export var powerup_packed_scene : PackedScene = preload("res://ShmupSandbox/Pickups/Scenes/pickup_powerup.tscn")
@export var score_item_packed_scene : PackedScene = preload("res://ShmupSandbox/Pickups/Scenes/pickup_score.tscn")
@export var score_fragment_packed_scene : PackedScene = preload("res://ShmupSandbox/Pickups/Scenes/score_fragment.tscn")

signal add_powerup_to_game(powerup : PickupPowerup)
signal add_score_item_to_game(score_item : PickupScore)
signal add_score_fragment_to_game(score_fragment : ScoreFragment)

func _ready() -> void:
	SignalsBus.spawn_powerup_event.connect(self._on_spawn_powerup_event)
	SignalsBus.spawn_score_item_event.connect(self._on_spawn_score_item_event)
	SignalsBus.spawn_score_fragment_event.connect(self._on_spawn_score_frament_event)


################################################
# NOTE:Spawning powerups
################################################
func _on_spawn_powerup_event(sp : Vector2) -> void:
	_instantiate_powerup(sp)

func _instantiate_powerup(sp : Vector2) -> void:
	var powerup : PickupPowerup = powerup_packed_scene.instantiate()
	powerup.global_position = sp
	add_powerup_to_game.emit(powerup)


################################################
# NOTE:Spawning score items
################################################
func _on_spawn_score_item_event(sp: Vector2) -> void:
	_instantiate_score_item(sp)

func _instantiate_score_item(sp : Vector2) -> void:
	var score_item : PickupScore = score_item_packed_scene.instantiate()
	score_item.global_position = sp
	add_score_item_to_game.emit(score_item)


################################################
# NOTE:Spawning score fragments
################################################
func _on_spawn_score_frament_event(sp : Vector2) -> void:
	_instantiate_score_fragment(sp)

func _instantiate_score_fragment(sp: Vector2) -> void:
	var score_items_container : Node2D = get_tree().get_first_node_in_group(GameManager.score_items_container_group_name)
	var score_items_list : Array[Node] = score_items_container.get_children()
	var non_maxed_score_items_list : Array[PickupScore]
	
	if score_items_list == []:
		return

	# Create a list of all the non max items
	for item : Node in score_items_list:
		if item is PickupScore:
			if item.level < item.max_level:
				non_maxed_score_items_list.append(item)


	if non_maxed_score_items_list == []:
		return
	
	# Instantiate score fragment if there are non maxed score items on screen
	var score_fragment : ScoreFragment = score_fragment_packed_scene.instantiate()
	score_fragment.global_position = sp
	# Only pass the non max item list to score fragment
	score_fragment.non_maxed_score_items_list = non_maxed_score_items_list

	add_score_fragment_to_game.emit(score_fragment)
