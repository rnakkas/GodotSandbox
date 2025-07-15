extends Node

################################################
# SCENE MANAGER:
#   Holds and preloads all required packed scenes
#   May be extended in future to handle scene transitions etc
################################################

################################################
# Packed Scenes
################################################
## Game
const game_scene: PackedScene = preload("res://ShmupSandbox/Main/Scenes/game.tscn")

## Player
const player_sprite_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/player_spawn_sprite.tscn")
const player_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/player_cat.tscn")

## Powerups
const powerup_packed_scene: PackedScene = preload("res://ShmupSandbox/Pickups/Scenes/pickup_powerup.tscn")
const score_item_packed_scene: PackedScene = preload("res://ShmupSandbox/Pickups/Scenes/pickup_score.tscn")
const score_fragment_packed_scene: PackedScene = preload("res://ShmupSandbox/Pickups/Scenes/score_fragment.tscn")

## Player bullets
const base_bullet_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/base_bullet.tscn")
const od_bullet_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/od_bullet.tscn")
const ch_lvl_1_bullet_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/ch_bullet_lvl_1.tscn")
const ch_lvl_2_bullet_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/ch_bullet_lvl_2.tscn")
const ch_lvl_3_bullet_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/ch_bullet_lvl_3.tscn")

## Bombs
const bomb_fuzz_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/bomb_fuzz.tscn")

## Enemies
const doomboard_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/doomboard.tscn")
const boomer_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/boomer.tscn")
const screamer_1_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/screamer_var_1.tscn")
const screamer_2_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/screamer_var_2.tscn")
const screamer_3_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/screamer_var_3.tscn")
const soul_carrier_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/soul_carrier.tscn")
const rumbler_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/rumbler.tscn")
const vile_v_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/vile_v.tscn")
const axecutioner_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/axecutioner.tscn")
const bass_behemoth_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/bass_behemoth.tscn")
const rimshot_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/rimshot.tscn")
const tomblaster_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/tomblaster.tscn")
const thumper_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/thumper.tscn")
const crasher_1_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/crasher_var_1.tscn")

## Enemy bullets
const screamer_bullet_scene: PackedScene = preload("res://ShmupSandbox/Enemies/EnemyProjectiles_Scenes/screamer_bullet.tscn")
const rumbler_bullet_scene: PackedScene = preload("res://ShmupSandbox/Enemies/EnemyProjectiles_Scenes/rumbler_bullet.tscn")
