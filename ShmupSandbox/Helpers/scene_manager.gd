class_name SceneManager extends Node

################################################
# SCENE MANAGER:
#   Holds and preloads all required packed scenes
#   May be extended in future to handle scene transitions etc
################################################

################################################
# Packed Scenes
################################################
## Game

static var game_scene: PackedScene = preload("res://ShmupSandbox/Main/Scenes/game.tscn")

## Player

static var player_sprite_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/player_spawn_sprite.tscn")
static var player_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/player_cat.tscn")

## Powerups

static var powerup_packed_scene: PackedScene = preload("res://ShmupSandbox/Pickups/Scenes/pickup_powerup.tscn")
static var score_item_packed_scene: PackedScene = preload("res://ShmupSandbox/Pickups/Scenes/pickup_score.tscn")
static var score_fragment_packed_scene: PackedScene = preload("res://ShmupSandbox/Pickups/Scenes/score_fragment.tscn")

## Player bullets

static var base_bullet_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/base_bullet.tscn")
static var od_bullet_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/od_bullet.tscn")
static var ch_lvl_1_bullet_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/ch_bullet_lvl_1.tscn")
static var ch_lvl_2_bullet_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/ch_bullet_lvl_2.tscn")
static var ch_lvl_3_bullet_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/ch_bullet_lvl_3.tscn")

## Bombs

static var bomb_fuzz_scene: PackedScene = preload("res://ShmupSandbox/Player/Scenes/bomb_fuzz.tscn")

## Enemies

static var skulljack_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/skulljack.tscn")
static var doomboard_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/doomboard.tscn")
static var boomer_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/boomer.tscn")
static var screamer_1_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/screamer_var_1.tscn")
static var screamer_2_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/screamer_var_2.tscn")
static var screamer_3_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/screamer_var_3.tscn")
static var soul_carrier_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/soul_carrier.tscn")
static var rumbler_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/rumbler.tscn")
static var vile_v_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/vile_v.tscn")
static var axecutioner_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/axecutioner.tscn")
static var bass_behemoth_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/bass_behemoth.tscn")
static var rimshot_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/rimshot.tscn")
static var tomblaster_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/tomblaster.tscn")
static var thumper_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/thumper.tscn")
static var crasher_1_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/crasher_var_1.tscn")
static var crasher_2_PS: PackedScene = preload("res://ShmupSandbox/Enemies/Scenes/crasher_var_2.tscn")

## Enemy formations

static var skulljack_formation_alpha_PS: PackedScene = preload("res://ShmupSandbox/Enemies/EnemyFormations/skulljack_formation_alpha.tscn")
static var skulljack_formation_bravo_PS: PackedScene = preload("res://ShmupSandbox/Enemies/EnemyFormations/skulljack_formation_bravo.tscn")
static var skulljack_formation_charlie_PS: PackedScene = preload("res://ShmupSandbox/Enemies/EnemyFormations/skulljack_formation_charlie.tscn")

## Enemy bullets

static var screamer_bullet_scene: PackedScene = preload("res://ShmupSandbox/Enemies/EnemyProjectiles_Scenes/screamer_bullet.tscn")
static var rumbler_bullet_scene: PackedScene = preload("res://ShmupSandbox/Enemies/EnemyProjectiles_Scenes/rumbler_bullet.tscn")
