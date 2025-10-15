/obj/sound_emitter/
	icon = 'icons/hammer/source.dmi'

/obj/sound_emitter/loop
	var/list/sounds = list(
		"sound1" = 'sound/effects/pc_idle.ogg'
	)
	var/volume = 100
	var/range = 7
	icon_state = "sound_loop"

/obj/sound_emitter/loop/Initialize()
	. = ..()
	setup_sound()

/obj/sound_emitter/loop/setup_sound()
	sound_emitter = new(src, is_static = TRUE, audio_range = src.range)

	for (var/key in src.sounds)
		var/sound/audio = sound(src.sounds[key])
		audio.repeat = TRUE
		audio.volume = src.volume
		sound_emitter.add(audio, key)

	sound_emitter.play(safepick(sounds)) // <3


/obj/sound_emitter/periodic
	var/list/sounds = list(
		"sound1" = 'sound/effects/water_drip_1.ogg'
	)
	var/volume = 100
	var/vary = FALSE
	var/range = 3
	var/chance_to_play = 100
	icon_state = "sound"

/obj/sound_emitter/periodic/Initialize()
	. = ..()
	START_PROCESSING(SSslowprocess, src)

/obj/sound_emitter/periodic/Destroy()
	STOP_PROCESSING(SSslowprocess, src)
	. = ..()

/obj/sound_emitter/periodic/setup_sound()
	sound_emitter = new(src, is_static = TRUE, audio_range = src.range)

	for (var/key in src.sounds)
		var/sound/audio = sound(src.sounds[key])
		audio.repeat = FALSE
		audio.volume = src.volume
		sound_emitter.add(audio, key)

/obj/sound_emitter/periodic/proc/on_success()
	return

/obj/sound_emitter/periodic/Process()
	if(!chance_to_play || !prob(chance_to_play)) return
	on_success()
	sound_emitter.play(safepick(sounds))