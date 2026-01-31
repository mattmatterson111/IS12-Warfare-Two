








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
