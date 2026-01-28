// Map Entity I/O Extension for Objects
// Allows any /obj to receive and send map entity signals via io_targetname

GLOBAL_LIST_EMPTY(io_objects_by_name)  // io_targetname -> list of objects

/atom/movable
	// I/O System Variables
	var/io_targetname = ""  // Register this object for map entity I/O
	var/list/io_connections = null  // "Output:Target:Input:Delay" format
	var/list/io_parsed_connections = null

/atom/movable/Initialize()
	. = ..()
	if(io_targetname)
		IO_register()
	if(io_connections)
		IO_parse_connections()

/atom/movable/Destroy()
	IO_unregister()
	return ..()

// Register this object to receive I/O signals
/atom/movable/proc/IO_register()
	if(!io_targetname)
		return
	var/key = lowertext(io_targetname)
	LAZYINITLIST(GLOB.io_objects_by_name[key])
	GLOB.io_objects_by_name[key] += src

// Unregister from I/O system
/atom/movable/proc/IO_unregister()
	if(!io_targetname)
		return
	var/key = lowertext(io_targetname)
	if(GLOB.io_objects_by_name[key])
		GLOB.io_objects_by_name[key] -= src
		if(!length(GLOB.io_objects_by_name[key]))
			GLOB.io_objects_by_name -= key

// Parse io_connections list into lookup format
/atom/movable/proc/IO_parse_connections()
	io_parsed_connections = list()
	for(var/conn in io_connections)
		var/list/parts = splittext(conn, ":")
		if(length(parts) >= 3)
			var/output_name = parts[1]
			var/target = parts[2]
			var/input = parts[3]
			var/delay = length(parts) >= 4 ? text2num(parts[4]) : 0
			LAZYINITLIST(io_parsed_connections[output_name])
			io_parsed_connections[output_name] += list(list(
				"target" = target,
				"input" = input,
				"delay" = delay
			))

// Receive an input signal from the map entity system
// Override this in subtypes to handle specific inputs
/atom/movable/proc/IO_receive_input(input_name, atom/activator, atom/caller)
	// Base implementation - override in subtypes
	// Example:
	// switch(lowertext(input_name))
	//     if("open")
	//         open()
	//         IO_fire_output("OnOpen", activator)
	//     if("close")
	//         close()
	//         IO_fire_output("OnClose", activator)
	return FALSE

// Fire an output to connected map entities
/atom/movable/proc/IO_fire_output(output_name, atom/activator)
	if(!io_parsed_connections || !io_parsed_connections[output_name])
		return

	for(var/list/conn in io_parsed_connections[output_name])
		var/target_name = conn["target"]
		var/input_name = conn["input"]
		var/delay = conn["delay"]

		// Find map entities with this targetname
		var/list/targets = find_io_targets(target_name)
		for(var/atom/target in targets)
			if(delay > 0)
				spawn(delay)
					if(target && !QDELETED(target))
						send_io_input(target, input_name, activator, src)
			else
				send_io_input(target, input_name, activator, src)

// Helper to send input to any valid IO target
/proc/send_io_input(atom/target, input_name, atom/activator, atom/caller)
	if(istype(target, /obj/effect/map_entity))
		var/obj/effect/map_entity/ME = target
		ME.receive_input(input_name, activator, caller)
	else if(istype(target, /atom/movable))
		var/atom/movable/O = target
		O.IO_receive_input(input_name, activator, caller)

// Find all valid IO targets (map entities + registered objects)
/proc/find_io_targets(target_name)
	if(!target_name)
		return list()

	var/key = lowertext(target_name)
	var/list/results = list()

	// Check map entities
	if(GLOB.map_entities_by_name[key])
		results += GLOB.map_entities_by_name[key]

	// Check registered objects
	if(GLOB.io_objects_by_name[key])
		results += GLOB.io_objects_by_name[key]

	return results

// Global proc to fire an output from anywhere
// Format: "targetname:input" or "targetname:input:param"
/proc/IO_output(connection_string, atom/activator, atom/caller)
	var/list/parts = splittext(connection_string, ":")
	if(length(parts) < 2)
		return FALSE

	var/target_name = parts[1]
	var/input_name = parts[2]
	var/param = length(parts) >= 3 ? parts[3] : null

	var/list/targets = find_io_targets(target_name)
	for(var/target in targets)
		if(istype(target, /obj/effect/map_entity))
			var/obj/effect/map_entity/ME = target
			var/list/params = param ? list("value" = param) : null
			ME.receive_input(input_name, activator, caller, params)
		else if(istype(target, /atom/movable))
			var/atom/movable/O = target
			O.IO_receive_input(input_name, activator, caller)

	return TRUE
