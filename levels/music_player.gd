extends AudioStreamPlayer

@export var loop_enabled: bool = true
@export var loop_start: float = 07.5
@export var loop_end: float = 67.8  # Default range; adjust as needed

func _ready():
	if stream:
		var audio_length = stream.get_length()
		print("Audio file duration:", audio_length)
		
		# Ensure loop_end doesn't exceed audio duration
		if loop_end <= 0.0 or loop_end > audio_length:
			loop_end = audio_length - 0.05
			print("Adjusted loop end to:", loop_end)

		# Ensure loop_start is valid
		if loop_start < 0.0 or loop_start >= audio_length:
			loop_start = 0.0
			print("Adjusted loop start to:", loop_start)
	else:
		print("No audio stream assigned.")

	play()  # Start playback immediately

func _process(delta):
	if loop_enabled and loop_end > 0.0:
		var current_pos = get_playback_position()
		print("Current Playback Position:", current_pos)
		
		if current_pos >= loop_end:
			print("Reached loop end. Seeking to loop start:", loop_start)
			seek(loop_start)
