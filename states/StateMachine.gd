extends Node


var url = "https://dodge-http-server.vercel.app/hs?id=" + OS.get_unique_id()

func _ready():
	reset_current_level()
	reset_max_spwans()



## Music States
var sound_on = true

func play_sound(sound, is_playing):
	if sound_on && !is_playing:
		sound.play()

func stop_sound(sound):
	if sound_on:
		sound.stop()

func toggle_sound(on, sound):
	sound_on = on
	if on:
		sound.play()
	else:
		sound.stop()
	

## Mob States
var max_spwans: int
func get_max_spwans():
	return max_spwans
	
func set_max_spwans(value):
	max_spwans = value
	
func reset_max_spwans():
	max_spwans = 0


## Levels States	
var current_level: int

func get_current_level():
	return current_level
	
func set_next_level():
	current_level += 1
	
func reset_current_level():
	current_level = 1
