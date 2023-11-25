extends CanvasLayer

signal start_game
signal high_score_update(highscore)

var highScore = 0
var highScoreMessage = "High Score: "

func _ready():
	setHighScoreMessage()
	
func game_over():
	show_timed_message("Game Over!")
	await $MessageTimer.timeout
	show_message("Dodge 'Em!")
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)

func show_message(text):
	$Message.text = text
	$Message.show()
	
func show_timed_message(text):
	show_message(text)
	$MessageTimer.start()

func updateHighScore(score, incoming = ""):
	if score > highScore:
		highScore = score
		setHighScoreMessage()
		if incoming != 'server':
			emit_signal("high_score_update", highScore)

func setHighScoreMessage():
	$HighScore.text = highScoreMessage + str(highScore)
	
func _on_message_timer_timeout():
	$Message.hide()

func _on_start_button_pressed():
	$StartButton.hide()
	start_game.emit()
