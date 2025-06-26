/turf/simulated/floor/urban
	icon = 'icons/turf/urban/urban_outside.dmi'
	var/ex_turf = /turf/simulated/floor/urban/destroyed

/turf/simulated/floor/urban/ex_act(severity)
	// Shitty way to go about it but yeah.. ugh..
	switch(severity)
		if(1.0)
			src.ChangeTurf(ex_turf)
		if(2.0)
			if(prob(75))
				src.ChangeTurf(ex_turf)
		if(3.0)
			if(prob(35))
				src.ChangeTurf(ex_turf)

	return

/turf/simulated/floor/urban/destroyed
	name = "rubble"
	icon_state = "broken_ground"

/turf/simulated/floor/urban/urban_pavement_brick
	name = "pavement"
	icon_state = "pv_brick"

/turf/simulated/floor/urban/urban_pavement_pattern
	name = "pavement"
	icon_state = "pv_pattern"

/turf/simulated/floor/urban/urban_pavement_soft
	name = "concrete"
	icon_state = "pv_soft"

/turf/simulated/floor/urban/urban_pavement_harsh
	name = "concrete"
	icon_state = "pv_harsh"

/turf/simulated/floor/urban/concrete
	name = "concrete"
	icon = 'icons/turf/floors.dmi'
	icon_state = "concrete"
	atom_flags = ATOM_FLAG_CLIMBABLE

/turf/simulated/floor/urban/concrete/New()
	. = ..()
	dir = pick(GLOB.alldirs)
	if(prob(15))
		icon_state = "concrete_cracked"
		dir = pick(GLOB.alldirs)


//[[-- Decals --]]

/obj/effect/floor_decal/urban
	icon = 'icons/turf/urban/urban_outside.dmi'
	alpha = 255
	mouse_opacity = FALSE

/obj/effect/floor_decal/urban/trim1
	icon_state = "pv_trim"

/obj/effect/floor_decal/urban/trim2
	icon_state = "building_trim_end"

/obj/effect/floor_decal/urban/trim3
	icon_state = "building_trim_outer"

/obj/effect/floor_decal/urban/pv_light
	icon_state = "pv_light"

/obj/effect/floor_decal/urban/pv_inner_c
	icon_state = "pv_inner_c"

/obj/effect/floor_decal/urban/pv_outer_c
	icon_state = "pv_outer_c"

/obj/effect/floor_decal/urban/cracks
	icon = 'icons/obj/urban/32x32deco.dmi'
	icon_state = "pv_cracks"

/obj/effect/floor_decal/urban/cracks/alt
	icon_state = "pv_cracks_sequel"

//	atom_flags = ATOM_FLAG_CLIMBABLE


/*
/turf/simulated/floor/concrete/can_climb(mob/living/user, post_climb_check)
	if(locate(/obj/structure/bridge, get_turf(user)))
		return FALSE
	if (!(atom_flags & ATOM_FLAG_CLIMBABLE) || !can_touch(user))
		return FALSE

	if (!user.Adjacent(src))
		to_chat(user, "<span class='danger'>You can't climb there, the way is blocked.</span>")
		return FALSE

	return TRUE



/turf/simulated/floor/concrete/update_icon()
	overlays.Cut()
	for(var/direction in GLOB.cardinal)
		var/turf/turf_to_check = get_step(src,direction)
		if(istype(turf_to_check, src))
			continue

		else
			var/image/dirt = image('icons/turf/flooring/decals.dmi', "concrete_trim", dir = turn(direction, 180))
			dirt.plane = src.plane
			dirt.layer = src.layer+2
			//dirt.color = "#877a8b"
			//dirt.alpha = 200

			overlays += dirt

*/


// water FUCK

/turf/simulated/floor/exoplanet/water/shallow/lightless/urban
	icon = 'icons/turf/urban/urban_sewer.dmi'
	icon_state = "stillwater"
	water_type = /obj/effect/water/sewerwater
	color = "#A9A900"

/turf/simulated/floor/exoplanet/water/shallow/lightless/urban/New()
	. = ..()
	icon = 'icons/turf/floors.dmi'
	icon_state = "concrete"
	color = "#FFFFFF"
	if(prob(15))
		icon_state = "concrete_cracked"
	dir = pick(GLOB.alldirs)

/turf/simulated/floor/exoplanet/water/shallow/lightless/urban/update_icon()

	overlays.Cut()
	for(var/direction in GLOB.cardinal)
		var/turf/turf_to_check = get_step(src,direction)
		if(istype(turf_to_check, /turf/simulated/floor/exoplanet/water/shallow))
			continue

		else if(istype(turf_to_check, /turf/simulated))
			var/image/water_side = image('icons/turf/urban/urban_sewer.dmi', "border", dir = direction)//turn(direction, 180))
			water_side.plane = src.plane
			water_side.layer = src.layer+2
			water_side.color = "#877a8b"

			overlays += water_side
		var/image/wave_overlay = image('icons/obj/warfare.dmi', "waves")
		overlays += wave_overlay

/obj/effect/water/sewerwater
	name = "water"
	icon = 'icons/turf/urban/urban_sewer.dmi'
	icon_state = "stillwater"