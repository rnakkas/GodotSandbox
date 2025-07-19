class_name LevelProto extends Node

static var spawn_schedule: Array[SpawnEvent] = [
	SpawnEvent.new(3.2, SceneManager.boomer_PS, Vector2(1100, 120)),
	SpawnEvent.new(4.5, SceneManager.doomboard_PS, Vector2(1200, 100)),
	SpawnEvent.new(8.7, SceneManager.screamer_1_PS, Vector2(1100, 200)),
	SpawnEvent.new(8.7, SceneManager.screamer_1_PS, Vector2(1200, 220)),
	SpawnEvent.new(8.7, SceneManager.screamer_1_PS, Vector2(1200, 160)),
	SpawnEvent.new(12.5, SceneManager.screamer_2_PS, Vector2(0, 0), GameManager.enemy_path_sine_wave_1)
]

var elapsed_time: float = 0.0
var events_queue: Array[SpawnEvent]

func _ready() -> void:
	events_queue = spawn_schedule.duplicate(true)
	print_debug(events_queue[0].time)
	

func _process(delta: float) -> void:
	elapsed_time += delta
	while events_queue.size() > 0 && events_queue[0].time <= elapsed_time:
		print_debug(
			"time: ", events_queue[0].time,
			" | spawn enemy: ", events_queue[0].enemy_scene,
			" | pos: ", events_queue[0].pos,
			" | path name: ", events_queue[0].path_name)
		
		SignalsBus.spawn_enemy_event.emit(events_queue[0].enemy_scene, events_queue[0].pos, events_queue[0].path_name)
		events_queue.pop_front()
