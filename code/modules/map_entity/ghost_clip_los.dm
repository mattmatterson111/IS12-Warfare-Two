// Ghost Clip Line-of-Sight Checks
// Blocks ghost observation/teleportation when a ghost clip is BETWEEN ghost and target

// Check if line from source to target passes through any ghost clips
// Returns TRUE if blocked, FALSE if clear
/proc/ghostclip_blocks_los(turf/source, turf/target)
	if(!source || !target)
		return FALSE

	// Get turfs along the line between source and target
	var/list/line_turfs = getline(source, target)
	for(var/turf/T in line_turfs)
		for(var/obj/O in T)
			if(O.atom_flags & ATOM_FLAG_GHOSTCLIP)
				return TRUE
	return FALSE

// Check if ghost can see/reach target, respecting ghost clips
// Returns TRUE if allowed, FALSE if blocked
/proc/ghost_can_reach(mob/observer/ghost/G, atom/target)
	if(!G || !target)
		return FALSE

	// Staff bypass
	if(G.client?.holder)
		return TRUE

	var/turf/ghost_turf = get_turf(G)
	var/turf/target_turf = get_turf(target)

	if(!ghost_turf || !target_turf)
		return FALSE

	// Check direct location
	for(var/obj/O in target_turf)
		if(O.atom_flags & ATOM_FLAG_GHOSTCLIP)
			return FALSE

	// Check line of sight
	if(ghostclip_blocks_los(ghost_turf, target_turf))
		return FALSE

	return TRUE
