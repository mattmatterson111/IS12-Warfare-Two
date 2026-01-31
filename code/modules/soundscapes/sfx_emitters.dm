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
	var/enabled = TRUE
	var/min_delay = 2 SECONDS
	var/max_delay = 35 SECONDS
	icon_state = "sound"

/obj/sound_emitter/periodic/New()
	set waitfor = 0
	. = ..()
	if(enabled)
		sleep(rand(1, 10 SECONDS))
		trigger()

/obj/sound_emitter/periodic/proc/trigger()
	if(!enabled || QDELETED(src))
		return
	
	if(prob(chance_to_play))
		on_success()
		playsound(loc, pick(sounds), volume, vary)
	
	addtimer(CALLBACK(src, .proc/trigger), rand(min_delay, max_delay))

/obj/sound_emitter/periodic/IO_receive_input(input_name, atom/activator, atom/caller)
	set waitfor = 0
	switch(lowertext(input_name))
		if("enable")
			if(!enabled)
				enabled = TRUE
				color = null
				sleep(rand(1, 10 SECONDS))
				trigger()
			return TRUE
		if("disable")
			if(enabled)
				enabled = FALSE
				color = "#777777"
			return TRUE
		if("toggle")
			if(enabled)
				return IO_receive_input("Disable", activator, caller)
			else
				return IO_receive_input("Enable", activator, caller)
	return FALSE

/obj/sound_emitter/periodic/Destroy()
	enabled = FALSE
	. = ..()

/obj/sound_emitter/periodic/proc/on_success()
	return

/obj/sound_emitter/periodic/Process()
	if(!chance_to_play || !prob(chance_to_play)) return
	on_success()
	playsound(loc, pick(sounds), volume, vary)