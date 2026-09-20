








/obj/machinery/door/open(var/forced = 0)
	. = ..()
	IO_fire_output("OnOpen", null)

/obj/machinery/door/close(var/forced = 0)
	. = ..()
	IO_fire_output("OnClose", null)

/obj/machinery/door/IO_receive_input(input_name, atom/activator, atom/caller, list/params)
	debug_flash(MAP_ENTITY_COLOR_INPUT)
	switch(lowertext(input_name))
		if("open")
			spawn(0)
				open()
			return TRUE
		if("close")
			spawn(0)
				close()
			return TRUE
		if("toggle")
			spawn(0)
				if(density)
					open()
				else
					close()
			return TRUE
	return FALSE






/obj/machinery/door/airlock/IO_receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	debug_flash(MAP_ENTITY_COLOR_INPUT)
	switch(lowertext(input_name))
		if("lock", "bolt")
			lock()
			IO_fire_output("OnLock", null)
			return TRUE
		if("unlock", "unbolt")
			unlock()
			IO_fire_output("OnUnlock", null)
			return TRUE
		if("togglelock", "togglebolt")
			if(locked)
				unlock()
				IO_fire_output("OnUnlock", null)
			else
				lock()
				IO_fire_output("OnLock", null)
			return TRUE
	return FALSE






/obj/machinery/door/blast/open()
	. = ..()
	if(.)
		IO_fire_output("OnOpen", null)

/obj/machinery/door/blast/close()
	. = ..()
	if(.)
		IO_fire_output("OnClose", null)

/obj/machinery/door/blast/IO_receive_input(input_name, atom/activator, atom/caller, list/params)
	debug_flash(MAP_ENTITY_COLOR_INPUT)
	switch(lowertext(input_name))
		if("open")
			open()
			return TRUE
		if("close")
			close()
			return TRUE
		if("toggle")
			if(density)
				open()
			else
				close()
			return TRUE
	return FALSE





/obj/machinery/light/IO_receive_input(input_name, atom/activator, atom/caller, list/params)
	debug_flash(MAP_ENTITY_COLOR_INPUT)
	switch(lowertext(input_name))
		if("turnon")
			seton(TRUE)
			return TRUE
		if("turnoff")
			seton(FALSE)
			return TRUE
		if("toggle")
			seton(!on)
			return TRUE
	return FALSE

/obj/machinery/button/IO_receive_input(input_name, atom/activator, atom/caller, list/params)
	debug_flash(MAP_ENTITY_COLOR_INPUT)
	var/mob/living/user = null
	if(istype(activator, /mob/living))
		user = activator
	switch(lowertext(input_name))
		if("press", "activate", "trigger", "toggle")
			activate(user)
			return TRUE
	return FALSE

// Button variants that only implemented hand-interaction behavior need activate() for IO to work.
/obj/machinery/button/windowtint/activate(mob/living/user)
	toggle_tint()

/obj/machinery/button/ignition/activate(mob/living/user)
	use_power(5)
	active = 1
	icon_state = "launcheract"
	for(var/obj/machinery/sparker/M in SSmachines.machinery)
		if(M.id == id)
			spawn(0)
				M.ignite()
	for(var/obj/machinery/igniter/M in SSmachines.machinery)
		if(M.id == id)
			M.ignite()
	sleep(50)
	icon_state = "launcherbtt"
	active = 0

/obj/machinery/button/flasher/activate(mob/living/user)
	use_power(5)
	active = 1
	icon_state = "launcheract"
	for(var/obj/machinery/flasher/M in SSmachines.machinery)
		if(M.id == src.id)
			spawn()
				M.flash()
	sleep(50)
	icon_state = "launcherbtt"
	active = 0

/obj/machinery/button/holosign/activate(mob/living/user)
	use_power(5)
	active = !active
	update_icon()
	for(var/obj/machinery/holosign/M in SSmachines.machinery)
		if(M.id == src.id)
			spawn(0)
				M.toggle()
				return







/obj/machinery/door/blast/shutters/instant
	name = "instant shutter"
	desc = "A quick-acting shutter."

/obj/machinery/door/blast/shutters/instant/force_open()
	operating = 1
	if(open_sound)
		playsound(loc, open_sound, 60, 1)
	flick(icon_state_opening, src)
	set_density(0)
	set_opacity(0)
	layer = open_layer
	plane = initial(plane)
	update_icon()
	update_nearby_tiles()
	operating = 0

/obj/machinery/door/blast/shutters/instant/force_close()
	operating = 1
	if(close_sound)
		playsound(loc, close_sound, 60, 1)
	flick(icon_state_closing, src)
	set_density(1)
	if(opaque)
		set_opacity(1)
	layer = closed_layer
	plane = closed_plane
	update_icon()
	update_nearby_tiles()
	operating = 0

/obj/machinery/door/blast/shutters/instant/open
	icon_state = "shutter0"
	begins_closed = FALSE
