/obj/item/device/flashlight/lamp/captain/urban_streetlamp/floodlamp
	name = "\improper floodlight"
	desc = "Ough- fuck! That's bright!"
	icon = 'icons/obj/32x64.dmi'
	icon_state = "floodlight1"
	plane = ABOVE_HUMAN_PLANE
	anchored = TRUE
	on = TRUE
	brightness_on = 8
	light_power = 4
	light_range = 16
	light_color = "#d8cdb6"

/obj/item/device/flashlight/lamp/captain/urban_streetlamp/floodlamp/short
	icon_state = "floodlight0"

/turf/simulated/wall/perspectisub
	name = "metal wall"
	desc = "Good luck getting through one of these."
	icon_state = "metalwall0"
	walltype = "metalwall"
	mineral = "rust"
	plane = WALL_PLANE
	integrity = 15000 //Tough bois

/turf/unsimulated/wall/submarine // no
	name = "metal wall"
	desc = "Good luck getting through one of these."
	icon_state = "main"
	icon = 'icons/turf/ertwalls.dmi'
// also tysm Zion for the temp sprites <3 i'll redo these sometime later down the line
/turf/unsimulated/wall/submarine/innercorners
	icon_state = "innercorners"

/turf/unsimulated/wall/submarine/innercorners/plus
	icon_state = "more_innercorner_piecs"

/turf/unsimulated/wall/submarine/long
	icon_state = "long"

/turf/unsimulated/wall/submarine/outside
	icon_state = "outsidepieces"

/turf/unsimulated/wall/submarine/outside/plus
	icon_state = "outsidepieces2"

/turf/unsimulated/wall/submarine/doors
	icon_state = "door"

/turf/simulated/floor/ert/metal01
	icon_state = "metal01"

/turf/simulated/floor/ert/metal02
	icon_state = "metal02"

/turf/simulated/floor/ert/metal01/get_footstep_sound(crouching, armor)
	return safepick(footstep_sounds[FOOTSTEP_ARMORED_HULL])

/turf/simulated/floor/ert/metal02/get_footstep_sound(crouching, armor)
	return safepick(footstep_sounds[FOOTSTEP_ARMORED_HULL])

/obj/machinery/door/unpowered/simple/sub
	icon = 'icons/obj/doors/subdoor.dmi'
	icon_base = "door"
	icon_state = "door"
	color = null
	material = REINFORCED_STEEL_MATERIAL

/obj/machinery/door/unpowered/simple/sub/Initialize(mapload, d)
	. = ..()
	var/image/I = image(icon, src, "[icon_state]_over")
	I.plane = ABOVE_HUMAN_PLANE
	I.layer = ABOVE_HUMAN_LAYER
	overlays += I

/obj/structure/vehicle // fake versions of the transport whatevers
	var/static_pixel_x
	var/static_pixel_y

/obj/structure/vehicle/submarine
	icon = 'icons/obj/224x64.dmi'
	icon_state = "ship"
	static_pixel_x = -32
	static_pixel_y = -275

/obj/effect/concrete_block
	icon = 'icons/obj/structures.dmi'
	icon_state = "concreteblok"
	mouse_opacity = 0
	anchored = TRUE
	density = FALSE

/turf/simulated/wall/wood2
	name = "wooden wall"
	desc = "Good luck getting through one of these."
	icon_state = "woodt0"
	walltype = "woodt"
	mineral = "wood"
	plane = WALL_PLANE
	integrity = 15000 //Tough bois