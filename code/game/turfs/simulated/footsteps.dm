#define FOOTSTEP_CARPET 	"carpet"
#define FOOTSTEP_TILES 		"tiles"
#define FOOTSTEP_PLATING 	"plating"
#define FOOTSTEP_WOOD 		"wood"
#define FOOTSTEP_ASTEROID 	"asteroid"
#define FOOTSTEP_DIRT		"dirt"
#define FOOTSTEP_GRASS 		"grass"
#define FOOTSTEP_WATER		"water"
#define FOOTSTEP_BLANK		"blank"
#define FOOTSTEP_REINFPLATING "reinforcedplating"
#define FOOTSTEP_SNOW		"snow"
#define FOOTSTEP_MUD 		"mud"
#define FOOTSTEP_CONCRETE	"concrete"
#define ARMOR_FOOTSTEP_CONCRETE "armorcrete"
#define ARMOR_FOOTSTEP_CONCRETE_CROUCHING "armorcretecrouch"
#define ARMOR_FOOTSTEP_BRIDGE "armorwood"
#define ARMOR_FOOTSTEP_BRIDGE_CROUCHING "armorwoodcrouch"
#define ARMOR_FOOTSTEP_DIRT "armordirtcrouch"
#define ARMOR_FOOTSTEP_DIRT_CROUCHING "armordirtcrouch"
#define ARMOR_FOOTSTEP_WATER "armorwatercrouch"
#define ARMOR_FOOTSTEP_WATER_CROUCHING "armorwatercrouch"
#define FOOTSTEP_ARMORED_HULL "armoredhull"


/turf/simulated/var/global/list/footstep_sounds = list(
	FOOTSTEP_WOOD = list(
		'sound/effects/footstep/wood1.ogg',
		'sound/effects/footstep/wood2.ogg',
		'sound/effects/footstep/wood3.ogg',
		'sound/effects/footstep/wood4.ogg',
		'sound/effects/footstep/wood5.ogg'),
	FOOTSTEP_TILES = list(
		'sound/effects/footstep/floor1.ogg',
		'sound/effects/footstep/floor2.ogg',
		'sound/effects/footstep/floor3.ogg',
		'sound/effects/footstep/floor4.ogg'),
	FOOTSTEP_PLATING =  list(
		'sound/effects/footstep/plating1.ogg',
		'sound/effects/footstep/plating2.ogg',
		'sound/effects/footstep/plating3.ogg',
		'sound/effects/footstep/plating4.ogg',
		'sound/effects/footstep/plating5.ogg'),
	FOOTSTEP_CARPET = list(
		'sound/effects/footstep/carpet1.ogg',
		'sound/effects/footstep/carpet2.ogg',
		'sound/effects/footstep/carpet3.ogg',
		'sound/effects/footstep/carpet4.ogg',
		'sound/effects/footstep/carpet5.ogg'),
	FOOTSTEP_ASTEROID = list(
		'sound/effects/footstep/asteroid1.ogg',
		'sound/effects/footstep/asteroid2.ogg',
		'sound/effects/footstep/asteroid3.ogg',
		'sound/effects/footstep/asteroid4.ogg',
		'sound/effects/footstep/asteroid5.ogg'),
	FOOTSTEP_DIRT = list(
		'sound/effects/footstep/dirt1.ogg',
		'sound/effects/footstep/dirt2.ogg',
		'sound/effects/footstep/dirt3.ogg'),
	FOOTSTEP_GRASS = list(
		'sound/effects/footstep/grass1.ogg',
		'sound/effects/footstep/grass2.ogg',
		'sound/effects/footstep/grass3.ogg',
		'sound/effects/footstep/grass4.ogg'),
	FOOTSTEP_WATER = list(
		'sound/effects/footstep/water_max1.ogg',
		'sound/effects/footstep/water_max2.ogg'),
	FOOTSTEP_SNOW = list(
		'sound/effects/footstep/snowstep1.ogg',
		'sound/effects/footstep/snowstep2.ogg',
		'sound/effects/footstep/snowstep3.ogg',
		'sound/effects/footstep/snowstep1.ogg'),
	FOOTSTEP_MUD = list(
		'sound/effects/footstep/mud1.ogg',
		'sound/effects/footstep/mud2.ogg',
		'sound/effects/footstep/mud3.ogg',
		'sound/effects/footstep/mud4.ogg',
		'sound/effects/footstep/mud5.ogg'),
	FOOTSTEP_BLANK = list(
		'sound/effects/footstep/blank.ogg'),
	FOOTSTEP_REINFPLATING = list(
		'sound/effects/footstep/reinfplating1.ogg',
		'sound/effects/footstep/reinfplating2.ogg',
		'sound/effects/footstep/reinfplating3.ogg',
		'sound/effects/footstep/reinfplating4.ogg',
		'sound/effects/footstep/reinfplating5.ogg',
		'sound/effects/footstep/reinfplating6.ogg'),
	FOOTSTEP_CONCRETE = list(
		'sound/effects/footsteps/concrete/crete1.ogg',
		'sound/effects/footsteps/concrete/crete2.ogg',
		'sound/effects/footsteps/concrete/crete3.ogg',
		'sound/effects/footsteps/concrete/crete4.ogg',
		'sound/effects/footsteps/concrete/crete5.ogg'),
	ARMOR_FOOTSTEP_CONCRETE = list(
		'sound/effects/footsteps/armor/concrete/step1.ogg',
		'sound/effects/footsteps/armor/concrete/step2.ogg',
		'sound/effects/footsteps/armor/concrete/step3.ogg',
		'sound/effects/footsteps/armor/concrete/step4.ogg',
		'sound/effects/footsteps/armor/concrete/step5.ogg'),
	ARMOR_FOOTSTEP_CONCRETE_CROUCHING = list(
		'sound/effects/footsteps/armor/concrete/crouch1.ogg',
		'sound/effects/footsteps/armor/concrete/crouch2.ogg',
		'sound/effects/footsteps/armor/concrete/crouch3.ogg',
		'sound/effects/footsteps/armor/concrete/crouch4.ogg',
		'sound/effects/footsteps/armor/concrete/crouch5.ogg'),
	ARMOR_FOOTSTEP_BRIDGE = list(
		'sound/effects/footsteps/armor/wood/step1.ogg',
		'sound/effects/footsteps/armor/wood/step2.ogg',
		'sound/effects/footsteps/armor/wood/step3.ogg',
		'sound/effects/footsteps/armor/wood/step4.ogg',
		'sound/effects/footsteps/armor/wood/step5.ogg'),
	ARMOR_FOOTSTEP_BRIDGE_CROUCHING = list(
		'sound/effects/footsteps/armor/wood/crouch1.ogg',
		'sound/effects/footsteps/armor/wood/crouch2.ogg',
		'sound/effects/footsteps/armor/wood/crouch3.ogg',
		'sound/effects/footsteps/armor/wood/crouch4.ogg',
		'sound/effects/footsteps/armor/wood/crouch5.ogg'),
	ARMOR_FOOTSTEP_DIRT = list(
		'sound/effects/footsteps/armor/dirt/step1.ogg',
		'sound/effects/footsteps/armor/dirt/step2.ogg',
		'sound/effects/footsteps/armor/dirt/step3.ogg',
		'sound/effects/footsteps/armor/dirt/step4.ogg',
		'sound/effects/footsteps/armor/dirt/step5.ogg'),
	ARMOR_FOOTSTEP_DIRT_CROUCHING = list(
		'sound/effects/footsteps/armor/dirt/crouch1.ogg',
		'sound/effects/footsteps/armor/dirt/crouch2.ogg',
		'sound/effects/footsteps/armor/dirt/crouch3.ogg',
		'sound/effects/footsteps/armor/dirt/crouch4.ogg',
		'sound/effects/footsteps/armor/dirt/crouch5.ogg'),
	ARMOR_FOOTSTEP_WATER = list(
		'sound/effects/footsteps/armor/water/step1.ogg',
		'sound/effects/footsteps/armor/water/step2.ogg',
		'sound/effects/footsteps/armor/water/step3.ogg',
		'sound/effects/footsteps/armor/water/step4.ogg',
		'sound/effects/footsteps/armor/water/step5.ogg'),
	ARMOR_FOOTSTEP_WATER_CROUCHING = list(
		'sound/effects/footsteps/armor/water/crouch1.ogg',
		'sound/effects/footsteps/armor/water/crouch2.ogg',
		'sound/effects/footsteps/armor/water/crouch3.ogg',
		'sound/effects/footsteps/armor/water/crouch4.ogg',
		'sound/effects/footsteps/armor/water/crouch5.ogg'),
	FOOTSTEP_ARMORED_HULL = list(
		'sound/effects/footstep/hull1.ogg',
		'sound/effects/footstep/hull2.ogg',
		'sound/effects/footstep/hull3.ogg',
		'sound/effects/footstep/hull4.ogg'))

/decl/flooring/var/footstep_type
/decl/flooring/footstep_type = FOOTSTEP_BLANK
/decl/flooring/carpet/footstep_type = FOOTSTEP_CARPET
/decl/flooring/tiling/footstep_type = FOOTSTEP_TILES
/decl/flooring/linoleum/footstep_type = FOOTSTEP_TILES
/decl/flooring/wood/footstep_type = FOOTSTEP_WOOD
/decl/flooring/reinforced/footstep_type = FOOTSTEP_PLATING

/turf/simulated/proc/get_footstep_sound(var/crouching, var/armor)
	return safepick(footstep_sounds[FOOTSTEP_PLATING])

/turf/simulated/floor/get_footstep_sound(crouching, wearingarmor)
	if(is_plating())
		return safepick(footstep_sounds[FOOTSTEP_PLATING])
	else if(!flooring || !flooring.footstep_type)
		return safepick(footstep_sounds[FOOTSTEP_BLANK])
	else
		return safepick(footstep_sounds[flooring.footstep_type])

/turf/simulated/floor/asteroid/get_footstep_sound()
	return safepick(footstep_sounds[FOOTSTEP_ASTEROID])

/turf/simulated/floor/exoplanet/get_footstep_sound()
	return safepick(footstep_sounds[FOOTSTEP_CARPET])

/turf/simulated/floor/exoplanet/grass/get_footstep_sound()
	return safepick(footstep_sounds[FOOTSTEP_GRASS])

/turf/simulated/floor/exoplanet/water/shallow/get_footstep_sound(crouching, wearingarmor)
	if(wearingarmor)
		if(crouching)
			return safepick(footstep_sounds[ARMOR_FOOTSTEP_WATER_CROUCHING])
		return safepick(footstep_sounds[ARMOR_FOOTSTEP_WATER])
	return safepick(footstep_sounds[FOOTSTEP_WATER])

/turf/simulated/floor/fixed/get_footstep_sound(crouching, wearingarmor)
	if(wearingarmor)
		return "armorwalk"
	return safepick(footstep_sounds[FOOTSTEP_PLATING])

/turf/simulated/floor/plating/reinforced/get_footstep_sound(crouching, wearingarmor)
	if(wearingarmor)
		return "armorwalk"
	return safepick(footstep_sounds[FOOTSTEP_REINFPLATING])

/turf/simulated/floor/trenches/get_footstep_sound(crouching, wearingarmor)
	return safepick(footstep_sounds[FOOTSTEP_MUD])

/turf/simulated/floor/dirty/get_footstep_sound(crouching, wearingarmor)
	if(wearingarmor)
		if(crouching)
			return safepick(footstep_sounds[ARMOR_FOOTSTEP_DIRT_CROUCHING])
		return safepick(footstep_sounds[ARMOR_FOOTSTEP_DIRT])
	return safepick(footstep_sounds[FOOTSTEP_DIRT])

/turf/simulated/floor/trench/get_footstep_sound(crouching, wearingarmor)
	return safepick(footstep_sounds[FOOTSTEP_MUD])

/turf/simulated/open/get_footstep_sound()
	return safepick(footstep_sounds[FOOTSTEP_BLANK])
/turf/simulated/floor/wood/get_footstep_sound(crouching, wearingarmor)
	if(wearingarmor)
		if(crouching)
			return safepick(footstep_sounds[ARMOR_FOOTSTEP_BRIDGE_CROUCHING])
		return safepick(footstep_sounds[ARMOR_FOOTSTEP_BRIDGE])
	return safepick(footstep_sounds[FOOTSTEP_WOOD])


/turf/simulated/floor/concrete/get_footstep_sound(crouching, wearingarmor)
	if(wearingarmor)
		if(crouching)
			return safepick(footstep_sounds[ARMOR_FOOTSTEP_CONCRETE_CROUCHING])
		return safepick(footstep_sounds[ARMOR_FOOTSTEP_CONCRETE])
	return safepick(footstep_sounds[FOOTSTEP_CONCRETE])

/turf/simulated/floor/stones/get_footstep_sound(crouching, wearingarmor)
	if(wearingarmor)
		if(crouching)
			return safepick(footstep_sounds[ARMOR_FOOTSTEP_CONCRETE_CROUCHING])
		return safepick(footstep_sounds[ARMOR_FOOTSTEP_CONCRETE])
	return safepick(footstep_sounds[FOOTSTEP_CONCRETE])

/turf/simulated/Entered(var/mob/living/carbon/human/H)
	..()
	if(istype(H))
		H.handle_footsteps()
		H.step_count++

/datum/species/var/silent_steps
/datum/species/nabber/silent_steps = 1

/mob/living/carbon/human/var/step_count

/mob/living/carbon/human/proc/handle_footsteps()
	var/turf/simulated/T = get_turf(src)
	if(!istype(T))
		return

	if(buckled || lying || throwing)
		return //people flying, lying down or sitting do not step

	if(m_intent == "run")
		if(step_count % 2) //every other turf makes a sound
			return

	if(species.silent_steps)
		return //species is silent

	if(!has_gravity(src))
		if(step_count % 3) // don't need to step as often when you hop around
			return

	if(!has_organ(BP_L_FOOT) && !has_organ(BP_R_FOOT))
		return //no feet no footsteps

	var/wearingarmor = FALSE
	if(istype(wear_suit,/obj/item/clothing/suit/armor) && shoes)
		wearingarmor = TRUE

	var/S = T.get_footstep_sound(src.crouching, wearingarmor)
	if(S)
		var/range = -(world.view - 2)
		//var/armor_range = -(world.view - 2)
		var/volume = 50
		if(m_intent == "walk")
			volume -= 45
			range -= 0.333
		if(!shoes)
			volume -= 60
			range -= 0.333


			// SOMEONE PLEASE REMIND ME TO WRITE THIS SHITTY THING BELOW SOMEDAY
		if(locate(/obj/structure/bridge, get_turf(src)) && !in_trench) // HERE BEGINS THE SHITTY FOOTSTEP OVERRIDE TO MAKE CERTAIN STRUCTURES & TURFS SOUND NICE WITH ARMOR!
		// TO-DO: rewrite someday.
		// Rewritten it enough.. I don't wanna fuckin bother with trench bridges anymore they're so fucking buggy and need an overall rewrite!!!
			var/list/footstepsounds_temp = list('sound/effects/footstep/wood1.ogg',
			'sound/effects/footstep/wood2.ogg',
			'sound/effects/footstep/wood3.ogg',
			'sound/effects/footstep/wood4.ogg',
			'sound/effects/footstep/wood5.ogg')
			if(istype(wear_suit,/obj/item/clothing/suit/armor) && shoes)
				if(m_intent == "walk" && !crouching)
					footstepsounds_temp = list('sound/effects/footsteps/armor/wood/step1.ogg',
					'sound/effects/footsteps/armor/wood/step2.ogg',
					'sound/effects/footsteps/armor/wood/step3.ogg',
					'sound/effects/footsteps/armor/wood/step4.ogg',
					'sound/effects/footsteps/armor/wood/step5.ogg',)
					volume = 34
				else if(m_intent == "run" && !crouching)
					footstepsounds_temp = list('sound/effects/footsteps/armor/wood/run1.ogg',
					'sound/effects/footsteps/armor/wood/run2.ogg',
					'sound/effects/footsteps/armor/wood/run3.ogg',
					'sound/effects/footsteps/armor/wood/run4.ogg',
					'sound/effects/footsteps/armor/wood/run5.ogg',)
					volume = 42 // slightly quieter.. its too loud..
				if(crouching)
					footstepsounds_temp = list('sound/effects/footsteps/armor/wood/crouch1.ogg',
					'sound/effects/footsteps/armor/wood/crouch2.ogg',
					'sound/effects/footsteps/armor/wood/crouch3.ogg',
					'sound/effects/footsteps/armor/wood/crouch4.ogg',
					'sound/effects/footsteps/armor/wood/crouch5.ogg',)
					volume = 50
				playsound(T, safepick(footstepsounds_temp), volume, 1, range)
		else
			if(iswater(get_turf(src)) && wearingarmor) // this just makes it sound cooler..
				playsound(T, safepick(T.footstep_sounds[FOOTSTEP_WATER]), volume, 1, range)
			playsound(T, S, volume, 1, range)
		var/list/clients_to_show = list()

		for(var/mob/living/carbon/human/H in view())
			clients_to_show += H.get_client()
		if(!length(clients_to_show))
			return
		if(crouching) // allows for sneaky gameplay..
			return
		clients_to_show -= src.get_client()
		var/image/I = image('icons/effects/footstepsound.dmi', loc = T, icon_state = "default")
		I.plane = FOOTSTEP_ALERT_PLANE
		flick_overlay(I, clients_to_show, 4)
