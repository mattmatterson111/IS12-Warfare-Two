
/decl/soundscape/nothing
	name = "nothing"
	dsp = 0
	playlooping = list()
	playrandom = list()





/decl/soundscape/indoor/generic
	name = "indoor.generic"
	dsp = 1
	fadetime = 1.0

	playlooping = list(
		list("wave" = 'sound/ambience/stationambience.ogg', "volume" = 0.4, "pitch" = 100)
	)



/decl/soundscape/outdoor/generic
	name = "outdoor.generic"
	dsp = 1
	fadetime = 1.5





/decl/soundscape/warfare/trench
	name = "warfare.trench"
	dsp = 1
	fadetime = 2.0

	playrandom = list(
		list(
			"time" = list(5, 15),
			"volume" = list(0.2, 0.5),
			"waves" = list(
				'sound/ambience/ambigen1.ogg',
				'sound/ambience/ambigen2.ogg',
				'sound/ambience/ambigen3.ogg',
				'sound/ambience/cold_outside.ogg'
			)
		)
	)

/decl/soundscape/warfare/battlefield
	name = "warfare.battlefield"
	dsp = 1
	fadetime = 1.0

	playrandom = list(
		list(
			"time" = list(3, 10),
			"volume" = list(0.3, 0.6),
			"waves" = list(
				'sound/ambience/ambigen1.ogg',
				'sound/ambience/ambigen2.ogg',
				'sound/ambience/ambigen3.ogg'
			)
		)
	)

	playlooping = list(
		list("wave" = 'sound/ambience/distant_warfare.ogg', "volume" = 0.6, "pitch" = 100)
	)

/decl/soundscape/warfare/bunker
	name = "warfare.bunker"
	dsp = 14  
	fadetime = 1.0

	playlooping = list(
		list("wave" = 'sound/ambience/ambigulag.ogg', "volume" = 0.3, "pitch" = 100)
	)





/decl/soundscape/industrial/machinery
	name = "industrial.machinery"
	dsp = 6  
	fadetime = 1.0
	
	playlooping = list(
		list("wave" = 'sound/ambience/ambieng1.ogg', "volume" = 0.4, "pitch" = 100)
	)
	
	playrandom = list(
		list(
			"time" = list(4, 12),
			"volume" = list(0.2, 0.5),
			"waves" = list(
				'sound/ambience/ambimo1.ogg',
				'sound/ambience/ambimo2.ogg'
			)
		)
	)


/decl/soundscape/industrial/generator
	name = "industrial.generator"
	dsp = 6
	fadetime = 1.0

	playlooping = list(
		list("wave" = 'sound/ambience/ai_port_hum.ogg', "volume" = 0.4, "pitch" = 100)
	)





/decl/soundscape/nature/forest
	name = "nature.forest"
	dsp = 1
	fadetime = 2.0

	playlooping = list(
		list("wave" = 'sound/ambience/jungle.ogg', "volume" = 0.3, "pitch" = 100)
	)

	playrandom = list(
		list(
			"time" = list(8, 20),
			"volume" = list(0.2, 0.4),
			"waves" = list(
				'sound/ambience/eeriejungle1.ogg',
				'sound/ambience/eeriejungle2.ogg'
			)
		)
	)

/decl/soundscape/nature/rain
	name = "nature.rain"
	dsp = 1
	fadetime = 1.5





/decl/soundscape/underground/cave
	name = "underground.cave"
	dsp = 14  
	fadetime = 2.0
	
	playlooping = list(
		list("wave" = 'sound/ambience/new/underground.ogg', "volume" = 0.5, "pitch" = 100)
	)

/decl/soundscape/underground/tunnel
	name = "underground.tunnel"
	dsp = 14
	fadetime = 1.5
	
	playlooping = list(
		list("wave" = 'sound/ambience/new/crematorium.ogg', "volume" = 0.3, "pitch" = 100)
	)





/obj/effect/map_entity/env_soundscape/preset/trench
	name = "trench_soundscape"
	soundscape = "warfare.trench"
	radius = 12


/obj/effect/map_entity/env_soundscape/preset/bunker
	name = "bunker_soundscape"
	soundscape = "warfare.bunker"
	radius = 8


/obj/effect/map_entity/env_soundscape/preset/battlefield
	name = "battlefield_soundscape"
	soundscape = "warfare.battlefield"
	radius = 20


/obj/effect/map_entity/env_soundscape/preset/indoor
	name = "indoor_soundscape"
	soundscape = "indoor.generic"
	radius = 10


/obj/effect/map_entity/env_soundscape/preset/forest
	name = "forest_soundscape"
	soundscape = "nature.forest"
	radius = 15


/obj/effect/map_entity/env_soundscape/preset/cave
	name = "cave_soundscape"
	soundscape = "underground.cave"
	radius = 10
