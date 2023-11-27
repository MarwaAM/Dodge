extends Node

@export var mob_scene: PackedScene
@export var state_machine: Node

var spwns = 0
var score 

func _ready():
	state_machine.play_sound($Music, $Music.playing)
	toggle_start_button(true)
	get_server_high_score()
	
func new_game():
	state_machine.play_sound($Music, $Music.playing)
	set_level_values()
	get_tree().call_group("mobs", "queue_free")

	score = 0
	$Player.start($StartPosition.position)
	$HUD.update_score(score)
	$HUD.show_timed_message("Get Ready")
	$StartTimer.start()

func game_over():
	state_machine.stop_sound($Music)
	state_machine.play_sound($Death, $Death.playing)

	$HUD.updateHighScore(score)
	
	reset_level()
	$HUD.game_over()

func set_level_values():
	var level_spwans = get_node("Levels/Level"+str(state_machine.get_current_level())).max_spwans
	state_machine.set_max_spwans(level_spwans)

func next_level():
	state_machine.set_next_level()
	reset_level()
	new_game()
	
func reset_level():
	$ScoreTimer.stop()
	$MobTimer.stop()
	spwns = 0

func toggleMusic(pressed):
	state_machine.toggle_sound(!pressed, $Music)
	
	
## Timers Functionality ##
func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _on_mob_timer_timeout():
	if spwns < state_machine.get_max_spwans():
		spwns += 1
		var mob = mob_scene.instantiate()
	
		var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
		mob_spawn_location.progress_ratio = randf()
		
		var direction = mob_spawn_location.rotation + PI / 2
		mob.position = mob_spawn_location.position

		# Add some randomness to the direction.
		direction += randf_range(-PI / 4, PI / 4)
		mob.rotation = direction

		# Choose the velocity for the mob.
		var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
		mob.linear_velocity = velocity.rotated(direction)

		# Spawn the mob by adding it to the Main scene.
		add_child(mob)
	else:
		$NextLevel.show()
	
## High Score Functionality ##
func get_server_high_score():
	$HighScore.request_completed.connect(_on_request_completed)
	await $HighScore.request(state_machine.url)

func _on_request_completed(_result, response_code, _headers, body):
	toggle_start_button(false)	
	if response_code != 201:
		return
	elif body:
		var ServerHighScore = JSON.parse_string(body.get_string_from_utf8())
		if ServerHighScore:
			$HUD.updateHighScore(ServerHighScore, "server")
 
func updateServeHighScore(highScore):
	var body = { "highScore": highScore }
	var json = JSON.stringify(body)
	var headers = ["Content-Type: application/json"]
	await $HighScore.request(state_machine.url, headers, HTTPClient.METHOD_POST, json)
	
func toggle_start_button(loading: bool):
	if loading:
		$HUD/StartButton.disabled = true
		$HUD/StartButton.text = "Loading.."
	else:
		$HUD/StartButton.disabled = false
		$HUD/StartButton.text = "Start"
		
	
	

#func get_user_id():
#	if not FileAccess.file_exists("user://savegame.save"):
#		var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
#		save_game.store_line("1")
#	else:
#		var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
#		var id = save_game.get_line()
#		print(id)
