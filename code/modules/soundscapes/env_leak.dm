/obj/sound_emitter/periodic/env_leak
	icon_state = "env_leak"
	io_targetname = "env_leak"
	enabled = FALSE

	sounds = list(
		'sound/effects/water_drip_1.ogg',
		'sound/effects/water_drip_2.ogg',
		'sound/effects/water_drip_3.ogg',
		'sound/effects/water_drip_4.ogg',
		'sound/effects/water_drip_5.ogg',
		'sound/effects/water_drip_6.ogg',
		'sound/effects/water_drip_7.ogg',
		'sound/effects/water_drip_8.ogg',
		'sound/effects/water_drip_9.ogg',
		'sound/effects/water_drip_10.ogg'
	)
	volume = 45
	vary = TRUE
	chance_to_play = 45

/obj/sound_emitter/periodic/env_leak/on_success()
	var/mob/living/m = locate(/mob/living) in loc
	if(!m) return
	if(!m.client) return
	if(prob(chance_to_play))
		to_chat(m, SPAN_YELLOW("A drop of water lands on your head."))