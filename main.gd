extends Node

@export var mob_scene: PackedScene
@export var max_spwans = 60 
var music_on = true
var spwns = 0
var score 
var url = "https://dodge-http-server.vercel.app/hs?id=" + OS.get_unique_id()

func _ready():
	$Music.play()
	toggle_start_button(true)
	$HighScore.request_completed.connect(_on_request_completed)
	await $HighScore.request(url)

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
	await $HighScore.request(url, headers, HTTPClient.METHOD_POST, json)
	
	
func game_over():
	$Music.stop()
	$Death.play()
	$HUD.updateHighScore(score)
	$ScoreTimer.stop()
	$MobTimer.stop()
	spwns = 0
	$HUD.game_over()
	
func new_game():
	if music_on:
		$Music.play()
	get_tree().call_group("mobs", "queue_free")

	score = 0
	$Player.start($StartPosition.position)
	$HUD.update_score(score)
	$HUD.show_timed_message("Get Ready")
	$StartTimer.start()

func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)


func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()


func _on_mob_timer_timeout():
	if spwns < max_spwans:
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

func toggleMusic(pressed):
	music_on = !pressed	
	if pressed:
		$Music.stop()
	else:
		$Music.play()
		
		
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
