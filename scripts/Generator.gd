extends Node

var sample_hz: float = 22050.0
@export var pulse_hz: float = 440.0
var phase: float = 0.0

var playback: AudioStreamPlayback = null


func _ready():
	$Player.stream.mix_rate = sample_hz
	$Player.play()
	playback = $Player.get_stream_playback()
	_fill_buffer()


func _process(_delta):
	_fill_buffer()


func _fill_buffer():
	var increment = pulse_hz / sample_hz
	var to_fill = playback.get_frames_available()
	while to_fill > 0:
		playback.push_frame(Vector2.ONE * sin(phase * TAU))
		phase = fmod(phase + increment, 1.0)
		to_fill -= 1
