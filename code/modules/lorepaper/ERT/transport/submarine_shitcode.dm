GLOBAL_LIST_EMPTY(blackout_teleports)
GLOBAL_LIST_EMPTY(shuttle_destinations)
// list [ id ]

/obj/effect/sub_marker
	icon = 'icons/obj/32x32.dmi'
	var/id

/obj/effect/sub_marker/Initialize()
	. = ..()
	if(!islist(GLOB.shuttle_destinations[id]))
		GLOB.shuttle_destinations[id] = list()
	GLOB.shuttle_destinations[id] += src

// literally just used for the anims
/obj/effect/sub_marker/dive
	icon_state = "submerge"
/obj/effect/sub_marker/surface
	icon_state = "rise"
/obj/effect/sub_marker/float
	icon_state = "float"

GLOBAL_LIST_EMPTY(special_shuttles)

/obj/machinery/button/transport_controller
	name = "Transport Controls"
	desc = "Controls the transport system."
	var/moved = FALSE
	var/locked = FALSE
/*
	// Override these in subtypes
	var/area/vehicle/start_zone = /area/vehicle/submarine/start_zone
	var/area/vehicle/end_zone = /area/vehicle/submarine/end_zone
	var/area/vehicle/transport_zone = /area/vehicle/submarine/transport_zone
*/

	var/start_id = "SUB_START"

/obj/machinery/button/transport_controller/proc/sound_dive(inside) return inside ? 'sound/effects/ert/submerge_inside.ogg' : null
/obj/machinery/button/transport_controller/proc/speaker_alarm() return 'sound/effects/ert/surfacesubmergealarm.ogg'
/obj/machinery/button/transport_controller/proc/sound_loop()		return 'sound/effects/ert/underwater_amb.ogg'
/obj/machinery/button/transport_controller/proc/sound_surface(inside)	return inside ? 'sound/effects/ert/surface_inside.ogg' : null
/obj/machinery/button/transport_controller/proc/sound_transit()	return pick('sound/effects/ert/ship_groan1.ogg', 'sound/effects/ert/ship_groan2.ogg')

/obj/machinery/button/transport_controller/proc/transport_name()	return "submarine"

/obj/effect/doorblocker
	name = "doorblocker"
	density = FALSE
	opacity = FALSE
	anchored = TRUE

/area/vehicle
	var/id
	dynamic_lighting = TRUE
	requires_power = FALSE

/area/vehicle/submarine
	id = "NULLNULLNULL"
	ambience = list('sound/effects/ert/ambient1.ogg','sound/effects/ert/ambient2.ogg')

/area/vehicle/submarine/end_zone
	id = "SUB_END"

/area/vehicle/submarine/start_zone
	id = "SUB_START"

/area/vehicle/submarine/transport_zone
	id = "SUB_INTRANSIT"

/*
	end_zone = locate(end_zone) in world
	transport_zone = locate(transport_zone) in world
	start_zone = locate(start_zone) in world

/obj/machinery/button/transport_controller/activate(mob/living/user)

	if(locked)
		to_chat(user, "The [transport_name()] is already en route. Don't mess with the controls now.")
		return

	playsound(src, sound_dive(), 100)
	locked = TRUE
	on_dive()

	if(!moved)
		addtimer(CALLBACK(src, .proc/move_to_transport, start_zone, end_zone), 5 SECONDS)
		moved = TRUE
	else
		addtimer(CALLBACK(src, .proc/move_to_transport, end_zone, start_zone), 5 SECONDS)
		moved = FALSE

/obj/machinery/button/transport_controller/proc/move_to_transport(var/area/vehicle/starting_zone, var/area/vehicle/ending_destination)
	if(starting_zone && transport_zone)
		starting_zone.move_contents_to(transport_zone)
		for(var/obj/effect/darkout_teleporter/tp in transport_zone)
			to_world("TRY3")
			tp.enabled = FALSE
			tp.change_id(transport_zone.id)
		update_teleports(starting_zone.id)
		update_teleports(transport_zone.id)
		update_teleports(ending_destination.id)
		for(var/obj/effect/doorblocker/D in transport_zone)
			D.opacity = TRUE
			D.density = TRUE
		on_transit()
		addtimer(CALLBACK(src, .proc/move_to_destination, ending_destination), 5 SECONDS)

/obj/machinery/button/transport_controller/proc/move_to_destination(var/area/vehicle/destination)

	if(transport_zone && destination)
		transport_zone.move_contents_to(destination)
		for(var/obj/effect/darkout_teleporter/tp in destination)
			to_world("TRY2")
			to_world("Its: [destination] with [destination.id]")
			tp.enabled = TRUE
			tp.change_id(destination.id)
		update_teleports(transport_zone.id)
		update_teleports(destination.id)
		locked = FALSE
		playsound(src, sound_surface(), 100)
		on_surface()
*/