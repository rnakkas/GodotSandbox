class_name LevelProto extends Node

@export var spawn_schedule: Array[SpawnEvent] = []

var elapsed_time: float = 0.0
var events_queue: Array[SpawnEvent]

func _init() -> void:
	_create_spawn_schedule()

func _create_spawn_schedule() -> void:
	spawn_schedule = [
		SpawnEvent.new(3.2, SceneManager.skulljack_PS, Vector2(1100, 120)),
		SpawnEvent.new(3.8, SceneManager.skulljack_PS, Vector2(1100, 200)),
		SpawnEvent.new(4.4, SceneManager.skulljack_PS, Vector2(1100, 300)),
		SpawnEvent.new(6.4, SceneManager.doomboard_PS, Vector2(1050, 100)),
		
		SpawnEvent.new(9.4, SceneManager.screamer_1_PS, Vector2(1100, 160)),
		SpawnEvent.new(9.5, SceneManager.screamer_1_PS, Vector2(1100, 220)),
		SpawnEvent.new(9.7, SceneManager.screamer_1_PS, Vector2(1100, 460)),
		
		SpawnEvent.new(10.1, SceneManager.screamer_1_PS, Vector2(1100, 500)),
		SpawnEvent.new(10.2, SceneManager.screamer_1_PS, Vector2(1150, 490)),
		SpawnEvent.new(10.3, SceneManager.screamer_1_PS, Vector2(1150, 480)),
		SpawnEvent.new(10.4, SceneManager.screamer_1_PS, Vector2(1000, 300)),
		SpawnEvent.new(10.7, SceneManager.screamer_1_PS, Vector2(1000, 275)),
		SpawnEvent.new(10.4, SceneManager.screamer_1_PS, Vector2(1000, 200)),

		SpawnEvent.new(10.6, SceneManager.screamer_1_PS, Vector2(1100, 320)),
		SpawnEvent.new(11.0, SceneManager.screamer_1_PS, Vector2(1150, 330)),
		SpawnEvent.new(11.1, SceneManager.screamer_1_PS, Vector2(1150, 220)),
		SpawnEvent.new(11.3, SceneManager.screamer_1_PS, Vector2(1000, 450)),

		SpawnEvent.new(11.5, SceneManager.screamer_1_PS, Vector2(1100, 200)),
		SpawnEvent.new(11.5, SceneManager.screamer_1_PS, Vector2(1200, 220)),
		SpawnEvent.new(11.7, SceneManager.screamer_1_PS, Vector2(1200, 400)),
		SpawnEvent.new(12.1, SceneManager.screamer_1_PS, Vector2(1100, 320)),

		SpawnEvent.new(12.5, SceneManager.screamer_3_PS, Vector2(1100, 320)),
		SpawnEvent.new(12.8, SceneManager.screamer_3_PS, Vector2(1150, 330)),
		SpawnEvent.new(13.1, SceneManager.screamer_3_PS, Vector2(1150, 220)),
		SpawnEvent.new(13.6, SceneManager.screamer_3_PS, Vector2(1000, 450)),
		SpawnEvent.new(14.0, SceneManager.screamer_3_PS, Vector2(1000, 475)),
		SpawnEvent.new(14.4, SceneManager.screamer_3_PS, Vector2(1000, 355)),

		SpawnEvent.new(15.1, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_1),
		SpawnEvent.new(15.3, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_1),
		SpawnEvent.new(15.5, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_1),
		SpawnEvent.new(15.7, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_1),
		SpawnEvent.new(18.0, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_3),
		SpawnEvent.new(18.3, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_3),
		SpawnEvent.new(18.6, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_3),
]


func _ready() -> void:
	events_queue = spawn_schedule.duplicate(true)
	
func _process(delta: float) -> void:
	elapsed_time += delta
	Helper.run_spawn_schedule(elapsed_time, events_queue)
