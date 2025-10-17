/obj/sound_emitter/
	icon = 'icons/hammer/source.dmi'
	anchored = 1.0
	unacidable = 1
	simulated = 0
	invisibility = 101

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
		'sound/effects/water_drip_1.ogg'
	)
	var/volume = 100
	var/vary = FALSE
	var/chance_to_play = 100
	icon_state = "sound"

/obj/sound_emitter/periodic/New()
	. = ..()
	if(prob(chance_to_play))
		sleep(rand(10, 1000))
		setup_sound()
		START_PROCESSING(SSslowprocess, src)
	else
		color = "#777777"

/obj/sound_emitter/periodic/Destroy()
	STOP_PROCESSING(SSslowprocess, src)
	. = ..()

/obj/sound_emitter/periodic/proc/on_success()
	return

/obj/sound_emitter/periodic/Process()
	if(!chance_to_play || !prob(chance_to_play)) return
	on_success()
	playsound(loc, pick(sounds), volume, vary)