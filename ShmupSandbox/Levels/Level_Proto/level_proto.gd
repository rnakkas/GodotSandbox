class_name LevelProto extends Node

@export var spawn_schedule: Array[SpawnEvent] = []
@export var boss_message: String = "TIME TO RIDE THE LIGHTNING!"

var elapsed_time: float = 0.0
var events_queue: Array[SpawnEvent]
var ready_for_boss: bool

func _init() -> void:
	_create_spawn_schedule()

###### NOTE: Use this to test different enemy spawn scheduling

func _create_spawn_schedule() -> void:
	spawn_schedule = [
		# Wave 1
		SpawnEvent.new(3.2, SceneManager.skulljack_PS, Vector2(1100, 120)),
		SpawnEvent.new(5.0, SceneManager.skulljack_PS, Vector2(1100, 400)),
		SpawnEvent.new(6.0, SceneManager.skulljack_PS, Vector2(1100, 300)),

		# Wave 2
		SpawnEvent.new(7.2, SceneManager.skulljack_formation_alpha_PS, Vector2(1100, 120)),
		
		# Wave 3
		SpawnEvent.new(8.4, SceneManager.doomboard_PS, Vector2(1100, 270)),

		# Wave 4
		SpawnEvent.new(15.5, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_4),
		SpawnEvent.new(16.0, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_3),
		SpawnEvent.new(16.5, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_2),
		SpawnEvent.new(17.0, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_1),
		
		# Wave 5
		SpawnEvent.new(19.0, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_2),
		SpawnEvent.new(19.5, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_3),
		SpawnEvent.new(20.0, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_4),
		SpawnEvent.new(20.5, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_5),

		# # Wave 6
		# SpawnEvent.new(22.0, SceneManager.soul_carrier_PS, Vector2(1000, 320)),
		# SpawnEvent.new(22.5, SceneManager.soul_carrier_PS, Vector2(1000, 160)),

		# # Wave 7
		# SpawnEvent.new(25.0, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_5),
		# SpawnEvent.new(25.5, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_3),
		# SpawnEvent.new(26.0, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_4),
		# SpawnEvent.new(26.5, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_2),
		# SpawnEvent.new(26.5, SceneManager.boomer_PS, Vector2(1100, 400)),
		# SpawnEvent.new(27.0, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_3),
		# SpawnEvent.new(28.5, SceneManager.boomer_PS, Vector2(1100, 0)),
		# SpawnEvent.new(29.0, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_1),
		# SpawnEvent.new(30.5, SceneManager.boomer_PS, Vector2(1100, 180)),
		# SpawnEvent.new(31.0, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_2),
		# SpawnEvent.new(31.5, SceneManager.boomer_PS, Vector2(1100, 500)),
		# SpawnEvent.new(32.0, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_4),


		# # Wave 8
		# SpawnEvent.new(33.0, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_5),
		# SpawnEvent.new(33.5, SceneManager.boomer_PS, Vector2(1100, 100)),
		# SpawnEvent.new(33.8, SceneManager.boomer_PS, Vector2(1100, 300)),
		# SpawnEvent.new(34.5, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_3),
		# SpawnEvent.new(35.0, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_4),
		# SpawnEvent.new(35.5, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_2),
		# SpawnEvent.new(35.8, SceneManager.boomer_PS, Vector2(1100, 200)),
		# SpawnEvent.new(36.3, SceneManager.boomer_PS, Vector2(1100, 400)),
		# SpawnEvent.new(37.0, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_3),
		# SpawnEvent.new(37.5, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_5),
		# SpawnEvent.new(38.0, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_3),
		# SpawnEvent.new(38.5, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_1),
		# SpawnEvent.new(38.8, SceneManager.boomer_PS, Vector2(1100, 100)),
		# SpawnEvent.new(39.8, SceneManager.boomer_PS, Vector2(1100, 400)),
		# SpawnEvent.new(40.8, SceneManager.boomer_PS, Vector2(1100, 480)),
		# SpawnEvent.new(41.8, SceneManager.boomer_PS, Vector2(1100, 300)),
		# SpawnEvent.new(43.0, SceneManager.boomer_PS, Vector2(1100, 100)),
		# SpawnEvent.new(44.0, SceneManager.boomer_PS, Vector2(1100, 260)),

		# # Wave 9
		# SpawnEvent.new(45.2, SceneManager.soul_carrier_PS, Vector2(1100, 380)),
		# SpawnEvent.new(47.0, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_5),
		# SpawnEvent.new(47.3, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_3),
		# SpawnEvent.new(47.6, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_4),
		# SpawnEvent.new(47.9, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_2),
		# SpawnEvent.new(48.2, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_3),
		# SpawnEvent.new(48.5, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_1),
		# SpawnEvent.new(49.5, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_2),
		# SpawnEvent.new(50.5, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_4),

		# # Wave 10
		# SpawnEvent.new(51.0, SceneManager.doomboard_PS, Vector2(1200, 270)),
		# SpawnEvent.new(54.5, SceneManager.skulljack_formation_alpha_PS, Vector2(1000, 180)),
		# SpawnEvent.new(58.2, SceneManager.soul_carrier_PS, Vector2(1100, 175)),
		# SpawnEvent.new(62.0, SceneManager.skulljack_formation_bravo_PS, Vector2(1000, 400)),
		# SpawnEvent.new(63.2, SceneManager.soul_carrier_PS, Vector2(1100, 380)),
		# SpawnEvent.new(65.0, SceneManager.skulljack_formation_charlie_PS, Vector2(1000, 270)),

		# ## Boss leadup
		# SpawnEvent.new(70.0, SceneManager.doomboard_PS, Vector2(1100, 350)),
		# SpawnEvent.new(75.0, SceneManager.doomboard_PS, Vector2(1100, 120))
	]


func _ready() -> void:
	events_queue = spawn_schedule.duplicate(true)
	SignalsBus.boss_warning_ended_event.connect(self._on_boss_warning_ended)
	
func _process(delta: float) -> void:
	elapsed_time += delta
	Helper.run_spawn_schedule(elapsed_time, events_queue)
	if events_queue.size() == 0 and !ready_for_boss:
		ready_for_boss = true
		await get_tree().create_timer(3.0).timeout
		SignalsBus.boss_incoming_warning_event.emit(boss_message)

# Spawn boss
func _on_boss_warning_ended() -> void:
	SignalsBus.spawn_enemy_event.emit(SceneManager.boss_tourmageddon_PS, Vector2(1300, 200), "")