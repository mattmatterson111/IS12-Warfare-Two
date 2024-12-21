/turf/simulated/wall/perspecticrete/ex_act(severity)
	return FALSE

/turf/simulated/sand
	icon = 'icons/turf/defuse/floor.dmi'
	icon_state = "sand"

/turf/simulated/sand/New()
	. = ..()
	dir = pick(GLOB.alldirs)

/turf/simulated/sand/get_footstep_sound(crouching, armor)
	return safepick(footstep_sounds[FOOTSTEP_GRASS])

/obj/structure/effect/decal
	mouse_opacity = 0
	density = 0
	anchored = 1

/obj/structure/effect/decal/sitemarker
	icon = 'icons/obj/defuse/64x64decals.dmi'
	icon_state = "site"

/obj/effect/lighting_dummy/yellowlight/New()
	..()
	GLOB.lighting_dummies += src
	if(aspect_chosen(/datum/aspect/nightfare)) //For init. Note this will probably force this mode on until behavior has been made for deactivating aspects.
		return
	set_light(2, 1, "#dfd9c8")