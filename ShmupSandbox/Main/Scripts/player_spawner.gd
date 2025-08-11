class_name PlayerSpawner extends Node2D

@onready var spawn_point: Marker2D = $spawn_point

signal add_player_spawn_sprite_to_game(spawn_sprite: AnimatedSprite2D)
signal add_player_to_game(player: PlayerCat)

## Need these since the spawn sprite and the player character sprites are offset bit a bit
var x_offset: float = 12.0
var y_offset: float = 5.0

func _ready() -> void:
	_connect_to_signals()


func _connect_to_signals() -> void:
	SignalsBus.player_death_event.connect(self._on_player_death)
	SignalsBus.player_spawn_event.connect(self._on_player_spawn)
	SignalsBus.continue_game_player_respawn_event.connect(self._on_continue_game_player_respawn)


####

## Connected signal methods
func _on_player_death() -> void:
	if GameManager.player_lives >= 0: # Only respawn if player still has lives
		spawn_player_sprite("respawn") # Play respawn animation for player

func _on_player_spawn(pos: Vector2, can_be_invincible: bool) -> void:
	var player: PlayerCat = SceneManager.player_scene.instantiate()
	player.global_position = Vector2(pos.x + x_offset, pos.y + y_offset)
	player.can_be_invincible = can_be_invincible
	add_player_to_game.emit(player)
	GameManager.player = player

func _on_continue_game_player_respawn() -> void:
	spawn_player_sprite("respawn")

####

## Helper funcs
func spawn_player_sprite(animation_name: String) -> void:
	var spawn_sprite: AnimatedSprite2D = SceneManager.player_sprite_scene.instantiate()
	spawn_sprite.global_position = spawn_point.global_position
	spawn_sprite.play(animation_name)
	add_player_spawn_sprite_to_game.emit(spawn_sprite)
