/obj/sound_emitter/periodic/env_leak
	icon_state = "env_leak"

	sounds = list(
		"sound1" = 'sound/effects/water_drip_1.ogg',
		"sound2" = 'sound/effects/water_drip_2.ogg',
		"sound3" = 'sound/effects/water_drip_3.ogg',
		"sound4" = 'sound/effects/water_drip_4.ogg',
		"sound5" = 'sound/effects/water_drip_5.ogg',
		"sound6" = 'sound/effects/water_drip_6.ogg',
		"sound7" = 'sound/effects/water_drip_7.ogg',
		"sound8" = 'sound/effects/water_drip_8.ogg',
		"sound9" = 'sound/effects/water_drip_9.ogg',
		"sound10" = 'sound/effects/water_drip_10.ogg'
	)
	volume = 3
	vary = TRUE
	range = 0.5 // Aka falloff
	chance_to_play = 25

/obj/sound_emitter/periodic/env_leak/setup_sound()
	sleep(rand(10, 120))
	if(prob(chance_to_play)) return . = ..()
	color = "#585858"

/obj/sound_emitter/periodic/env_leak/on_success()
	var/mob/living/m = locate(/mob/living) in loc
	if(!m) return
	if(!m.client) return
	if(prob(chance_to_play))
		to_chat(m, SPAN_YELLOW("A drop of water lands on your head."))