/obj/machinery/button/test_heli
	name = "Helicontrols"
	desc = "Flies the helicopter back and forth."
	var/moved = FALSE
	var/locked = FALSE
	var/area/start_zone = /area/shuttle/helicopter/start
	var/area/end_zone = /area/shuttle/helicopter/end
	var/area/transport_zone = /area/shuttle/helicopter/in_transport

/area/shuttle/helicopter
	sound_env = LIVINGROOM

/area/shuttle/helicopter/start
	name = "helicopter start"

/area/shuttle/helicopter/in_transport
	name = "in transport"
	forced_ambience = list('sound/effects/helicopter_loop.ogg')

/area/shuttle/helicopter/end
	name = "end"


/area/shuttle/helicopter/natostart
	name = "helicopter start"

/area/shuttle/helicopter/nato_in_transport
	name = "in transport"
	forced_ambience = list('sound/effects/helicopter_loop.ogg')

/area/shuttle/helicopter/natoend
	name = "end"

/obj/machinery/button/test_heli/nato
	start_zone = /area/shuttle/helicopter/natostart
	end_zone = /area/shuttle/helicopter/natoend
	transport_zone = /area/shuttle/helicopter/nato_in_transport


/obj/effect/doorblocker
	name = "doorblocker"
	density = FALSE
	opacity = FALSE
	anchored = TRUE

/obj/machinery/button/test_heli/activate(mob/living/user)
	if(!SSwarfare.battle_time)
		to_chat(user, "It's not time to leave base yet.")
		return

	if(locked)
		to_chat(user, "Helicopter is already on course. Don't fuck with the controls now.")
		return

	if(!moved && !locked)
		playsound(src, 'sound/effects/helicopter_takeoff.ogg', 100)
		locked = TRUE
		addtimer(CALLBACK(src, PROC_REF(move_to_transport), start_zone, end_zone), 45 SECONDS) //Ok, we're taking off, move us to the transport zone please.
		moved = TRUE

	if(moved && !locked)
		playsound(src, 'sound/effects/helicopter_takeoff.ogg', 100)
		locked = TRUE
		addtimer(CALLBACK(src, PROC_REF(move_to_transport), end_zone, start_zone), 45 SECONDS) //We have already moved, so send us back to where we started.
		moved = FALSE

/obj/machinery/button/test_heli/proc/move_to_transport(var/area/starting_zone, var/area/ending_destination)//This is the proc that moves us.
	var/area/my_zone = locate(starting_zone)
	var/area/end_zone = locate(transport_zone)
	if(my_zone && end_zone)
		my_zone.move_contents_to(end_zone)
		var/area/A = get_area(src)
		for(var/obj/effect/doorblocker/D in A)
			D.opacity = TRUE
			D.density = TRUE
		addtimer(CALLBACK(src, PROC_REF(move_to_destination), ending_destination), 1 MINUTE)//Now wait one minute and move us again please.

/obj/machinery/button/test_heli/proc/move_to_destination(var/area/destination)//Ok this is the LZ
	var/area/my_zone = locate(transport_zone)
	var/area/end_zone = locate(destination)
	if(my_zone && end_zone)
		my_zone.move_contents_to(end_zone)
		var/area/A = get_area(src)
		for(var/obj/effect/doorblocker/D in A)
			D.opacity = FALSE
			D.density = FALSE
		locked = FALSE
		playsound(src, 'sound/effects/helicopter_landing.ogg', 100)
