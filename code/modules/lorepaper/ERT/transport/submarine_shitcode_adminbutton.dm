/client/proc/control_ert_ship()
	set name = "Control ERT ship"
	set category = "roleplay"
	set desc = "HELL CODE"

	var/key = input("Select a ship") as anything in GLOB.special_shuttles

	var/obj/machinery/button/transport_controller/controller = GLOB.special_shuttles[key]
	if(isnull(controller))
		to_chat(src, "NO SHUTTLES")
		return
	var/destination = input(src, "Please select a destination.") as anything in GLOB.shuttle_destinations
	controller.activate(src, destination)

/atom/proc/getpixel_x(atom/thing)
	if (thing)
		var/turf/T = get_turf(thing)
		var/world_pixel_x = (T.x - 1) * 32 + thing.pixel_x
		return (world_pixel_x - (x - 1) * 32)

/atom/proc/getpixel_y(atom/thing)
	if (thing)
		var/turf/T = get_turf(thing)
		var/world_pixel_y = (T.y - 1) * 32 + thing.pixel_y
		return (world_pixel_y - (y - 1) * 32)

// adding extra shit that makes the anims work
/obj/machinery/button/transport_controller
	var/obj/idle_pos = /obj/effect/sub_marker/float

	var/obj/surface_pos = /obj/effect/sub_marker/surface

	var/obj/dive_pos = /obj/effect/sub_marker/dive

	var/current_id

	var/obj/structure/vehicle/vehiclefx = /obj/structure/vehicle/submarine

	var/list/speakers_in_area = list()

/obj/machinery/button/transport_controller/Initialize()
	. = ..()
	if(GLOB.special_shuttles[transport_name()])
		locked = TRUE
		return
	GLOB.special_shuttles[transport_name()] = src
	name = "[transport_name()] controls"
	vehiclefx = new vehiclefx()
	vehiclefx.pixel_x = vehiclefx.static_pixel_x
	vehiclefx.pixel_y = vehiclefx.static_pixel_y
	update_marker_positions(start_id)
	vehiclefx.forceMove(idle_pos.loc)
	speakers_in_area = get_speakers()

/obj/machinery/button/transport_controller/proc/anim_fx_to(atom/anchor, atom/destination, from_alpha, to_alpha)
	vehiclefx.forceMove(anchor.loc)
	vehiclefx.alpha = from_alpha
	var/gettox = vehiclefx.static_pixel_x
	var/gettoy = vehiclefx.static_pixel_y
	var/getfromx = vehiclefx.getpixel_x(destination) + vehiclefx.static_pixel_x
	var/getfromy = vehiclefx.getpixel_y(destination) + vehiclefx.static_pixel_y
	vehiclefx.pixel_x = getfromx
	vehiclefx.pixel_y = getfromy
	animate(vehiclefx, pixel_x = gettox, pixel_y = gettoy, alpha = to_alpha, time = 8 SECONDS, easing = EASE_IN)


/obj/machinery/button/transport_controller/proc/on_surface() // Entering
	anim_fx_to(idle_pos, surface_pos, 0, 255)
	flick("open", vehiclefx)
	var/sound = sound_surface(TRUE)
	for(var/mob/M in get_people_inside())
		to_chat(M, "Sound is [sound]")
		sound_to(M, sound(sound, volume = 85))
	to_world("Surfacing")
/obj/machinery/button/transport_controller/proc/on_transit() // transit, basically unused tbh
	var/sound = sound_transit()
	for(var/mob/M in get_people_inside())
		to_chat(M, "Sound is [sound]")
		sound_to(M, sound(sound, volume = 85))
	to_world("beginning transit")
/obj/machinery/button/transport_controller/proc/on_dive() // Leaving
	anim_fx_to(dive_pos, idle_pos, 255, 0)
	var/sound = sound_dive(TRUE)
	for(var/mob/M in get_people_inside(TRUE))
		to_chat(M, "Sound is [sound]")
		sound_to(M, sound(sound, volume = 85))
	to_world("Diving")

/obj/machinery/button/transport_controller/proc/get_speakers()
	var/list/filtered = list()
	for(var/obj/o in get_area(src))
		if(!istype(o, /obj/structure/announcementspeaker))
			continue
		filtered += o
	return filtered

/obj/machinery/button/transport_controller/proc/playsound_from_speakers(sound, volume)
	if(!length(speakers_in_area)) return
	for(var/obj/o in speakers_in_area)
		soundoverlay(o, newplane = FOOTSTEP_ALERT_PLANE)
		playsound(o.loc, sound, volume, 0)

/obj/machinery/button/transport_controller/proc/update_marker_positions(destination_id)
	// Look for sub_markers that match the destination ID pattern
	for (var/obj/effect/sub_marker/M in GLOB.shuttle_destinations[destination_id])
		if (!M.id)
			continue

		if (istype(M, /obj/effect/sub_marker/float))
			idle_pos = M
			continue
		else if (istype(M, /obj/effect/sub_marker/surface))
			surface_pos = M
			continue
		else if (istype(M, /obj/effect/sub_marker/dive))
			dive_pos = M
			continue


/obj/machinery/button/transport_controller/activate(mob/living/user, destination_id) // if none

	if(locked)
		to_chat(user, "The [transport_name()] is already en route. Don't mess with the controls now.")
		return
	if(!destination_id)
		destination_id = input(user, "Input the destination code")

	if(!destination_id)
		return FALSE

	if(!length(GLOB.shuttle_destinations[destination_id]))
		return FALSE
	locked = TRUE

	var/area/A = get_area(src)
	for(var/obj/effect/darkout_teleporter/tp in A)
		tp.enabled = FALSE
		tp.change_id("TRANSITINTRANSIT")
	for(var/obj/machinery/door/blast/shutters/s in A)
		s.close()
	update_teleports(destination_id)
	update_teleports(start_id)
	update_teleports(current_id)

	flick("close", vehiclefx)
	vehiclefx.icon_state = "closed"

	playsound_from_speakers(speaker_alarm(), 85)
	sleep(8 SECONDS)

	on_dive()


	if(!moved)
		addtimer(CALLBACK(src, PROC_REF(move_to_transport), destination_id), 60 SECONDS)
		moved = TRUE
		update_marker_positions(destination_id)
/*
	else
		addtimer(CALLBACK(src, PROC_REF(move_to_transport), start_id), 60 SECONDS)
		moved = FALSE
		update_marker_positions(start_id)
*/
	playsound(src, sound_dive(), 100)
	sleep(2 SECONDS)
	for(var/mob/M in get_people_inside())
		to_chat(M, "playing the loop")
		sound_to(M, sound(sound_loop(), channel = 76, volume = 100, repeat = 1))


/obj/machinery/button/transport_controller/proc/get_people_inside()
	var/list/people = list()
	for(var/mob/M in get_area(src))
		if(!M.client)
			continue
		people += M
	return people

/obj/machinery/button/transport_controller/proc/move_to_transport(destination_id) // basically the middle point of their venture
	var/area/A = get_area(src)
	for(var/obj/effect/darkout_teleporter/tp in A) // if it wasnt done already SOMEHOW
		tp.enabled = FALSE
		tp.change_id("TRANSITINTRANSIT")
	for(var/obj/machinery/light/L in A)
		if(!prob(25))
			continue
		L.flicker(rand(2,5))

	update_teleports(destination_id)
	update_teleports(start_id)
	update_teleports(current_id)
	on_transit()
	addtimer(CALLBACK(src, PROC_REF(move_to_destination), destination_id), 60 SECONDS)

/obj/machinery/button/transport_controller/proc/move_to_destination(destination_id)
	playsound_from_speakers(speaker_alarm(), 85)
	sleep(8 SECONDS)
	for(var/mob/M in get_people_inside())
		sound_to(M, sound(null, channel = 76))
		shake_camera(M, 2, 2)
	var/area/A = get_area(src)
	for(var/obj/effect/darkout_teleporter/tp in A)
		tp.enabled = TRUE
		tp.change_id(destination_id)
	for(var/obj/machinery/door/blast/shutters/s in A)
		s.open()
	update_teleports(destination_id)
	update_teleports(start_id)
	update_teleports(current_id)

	for(var/obj/machinery/light/L in A)
		if(!prob(25))
			continue
		L.flicker(rand(2,5))

	playsound(src, sound_surface(), 100)
	on_surface()
	current_id = destination_id
	locked = FALSE

// Stopped using areas, but still leaving it here incase I come back to it
/*
	if(!moved)
		addtimer(CALLBACK(src, PROC_REF(move_to_transport), start_zone, end_zone), 5 SECONDS)
		moved = TRUE
	else
		addtimer(CALLBACK(src, PROC_REF(move_to_transport), end_zone, start_zone), 5 SECONDS)
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
		addtimer(CALLBACK(src, PROC_REF(move_to_destination), ending_destination), 5 SECONDS)

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