// Payload Effect Landmarks

/obj/effect/landmark/payload_marker
	icon = 'icons/hammer/source.dmi'
	icon_state = "landmark2"
	var/run_once = FALSE
	invisibility = 0
	anchored = TRUE

/obj/effect/landmark/payload_marker/New()
	. = ..()
	name = type

/obj/effect/landmark/payload_marker/proc/on_run(var/obj/structure/payload/pl)
	set waitfor = 0
	handle_cart(pl)
	if(run_once)
		qdel(src)
	return

/obj/effect/landmark/payload_marker/proc/handle_cart(var/obj/structure/payload/pl)
	return

// Speed Handling

/obj/effect/landmark/payload_marker/speed
	run_once = TRUE

/obj/effect/landmark/payload_marker/speed/increase/handle_cart(obj/structure/payload/pl)
	pl.modify_base_speed(2, "multiply")

/obj/effect/landmark/payload_marker/speed/decrease/handle_cart(obj/structure/payload/pl)
	pl.modify_base_speed(0.5, "multiply")

/obj/effect/landmark/payload_marker/speed/reset/handle_cart(obj/structure/payload/pl)
	pl.modify_base_speed(0, "reset")

// War Gate - blocks movement until battle_time

/obj/effect/landmark/payload_marker/war_gate
	run_once = FALSE  // Stays until war begins
	var/obj/structure/track/blocked_track = null

/obj/effect/landmark/payload_marker/war_gate/handle_cart(obj/structure/payload/pl)
	// If war hasn't begun, block payload by moving it back
	if(!SSwarfare.battle_time)
		pl.move_override = TRUE
		playsound(loc, 'sound/effects/payload/cart_contested_1.ogg', 50, FALSE)
		return

/obj/effect/landmark/payload_marker/war_gate/Destroy()
	for(var/obj/structure/payload/fuck in loc.contents)
		fuck.move_override = FALSE
	. = ..()

// Boost Pad - temporary speed burst

/obj/effect/landmark/payload_marker/boost
	run_once = TRUE
	var/boost_multiplier = 3
	var/boost_duration = 3 SECONDS

/obj/effect/landmark/payload_marker/boost/handle_cart(obj/structure/payload/pl)
	playsound(loc, 'sound/effects/payload/speed.ogg', 60, TRUE)
	var/original_base = pl.base_speed_mod
	pl.modify_base_speed(boost_multiplier, "multiply")

	// Add glowing drop shadow filter
	var/boost_filter = filter(type = "drop_shadow", x = 0, y = -1, offset = 2, size = 1, color = "#ffff00")
	LAZYADD(pl.filters, boost_filter)

	spawn(boost_duration)
		// Restore original speed
		pl.base_speed_mod = original_base
		// Remove the filter
		LAZYREMOVE(pl.filters, boost_filter)

// Smoke Screen

/obj/effect/landmark/payload_marker/smoke
	run_once = TRUE
	var/smoke_radius = 5

/obj/effect/landmark/payload_marker/smoke/handle_cart(obj/structure/payload/pl)
	playsound(loc, 'sound/effects/smoke.ogg', 50, TRUE)
	// Spawn smoke effect
	var/datum/effect/effect/system/smoke_spread/S = new /datum/effect/effect/system/smoke_spread()
	S.set_up(smoke_radius, 0, loc)
	S.start()

// Horn - audible announcement

/obj/effect/landmark/payload_marker/horn
	run_once = FALSE  // Can trigger multiple times
	var/horn_cooldown = 10 SECONDS
	var/last_horn_time = 0
	var/sfx = 'sound/effects/payload/horn.ogg'

/obj/effect/landmark/payload_marker/horn/handle_cart(obj/structure/payload/pl)
	if(world.time - last_horn_time < horn_cooldown)
		return
	last_horn_time = world.time
	// Use cart contested sound as horn since horn.ogg may not exist
	playsound(pl, sfx, 100, FALSE)

// Announcement

/obj/effect/landmark/payload_marker/announcement
	run_once = FALSE  // Can trigger multiple times
	var/announcement_cooldown = 10 SECONDS
	var/last_announcement_time = 0
	var/announcement_text

/obj/effect/landmark/payload_marker/announcement/handle_cart(obj/structure/payload/pl)
	if(world.time - last_announcement_time < announcement_cooldown)
		return
	last_announcement_time = world.time
	to_chat(world, announcement_text)

// Healing Aura - heals wounds and organs

/obj/effect/landmark/payload_marker/heal
	run_once = TRUE
	var/heal_radius = 5
	var/heal_cooldown = 5 SECONDS
	var/last_heal_time = 0

/obj/effect/landmark/payload_marker/heal/proc/get_faction_color(faction)
	switch(faction)
		if(RED_TEAM)
			return "#ff6666"
		if(BLUE_TEAM)
			return "#6666ff"
		else
			return "#ffff66"

/obj/effect/landmark/payload_marker/heal/handle_cart(obj/structure/payload/pl)
	if(world.time - last_heal_time < heal_cooldown)
		return
	last_heal_time = world.time

	playsound(loc, 'sound/effects/payload/heal.ogg', 60, TRUE)

	var/faction_color = get_faction_color(pl.warfare_faction)

	for(var/mob/living/carbon/human/H in range(heal_radius, pl))
		if(H.warfare_faction != pl.warfare_faction)
			continue
		if(H.stat == DEAD)
			continue

		// Heal all damage types
		H.adjustBruteLoss(-50)
		H.adjustFireLoss(-50)
		H.adjustToxLoss(-25)
		H.adjustOxyLoss(-25)

		// Heal random wounds from organs
		var/wounds_healed = 0
		for(var/obj/item/organ/external/E in H.organs)
			if(length(E.wounds) && wounds_healed < 3)
				var/datum/wound/W = pick(E.wounds)
				if(W)
					E.wounds -= W
					qdel(W)
					wounds_healed++

		// Heal organ damage
		for(var/obj/item/organ/internal/O in H.internal_organs)
			if(O.damage > 0)
				O.damage = max(0, O.damage - 10)

		// Apply faction-colored drop shadow filter temporarily
		var/heal_filter = filter(type = "drop_shadow", x = 0, y = -1, offset = 2, size = 1, color = faction_color)
		spawn(2 SECONDS)
			LAZYREMOVE(H.filters, heal_filter)

		to_chat(H, SPAN_NOTICE("<b>I am filled with vigor! FOR THE [uppertext(pl.warfare_faction)]!</b>"))


// Gun Repair - fixes guns in range

/obj/effect/landmark/payload_marker/repair
	run_once = TRUE
	var/repair_radius = 5
	var/repair_cooldown = 10 SECONDS
	var/last_repair_time = 0

/obj/effect/landmark/payload_marker/repair/handle_cart(obj/structure/payload/pl)
	if(world.time - last_repair_time < repair_cooldown)
		return
	last_repair_time = world.time

	var/repaired_any = FALSE

	for(var/mob/living/carbon/human/H in range(repair_radius, pl))
		if(H.warfare_faction != pl.warfare_faction)
			continue
		if(H.stat == DEAD)
			continue

		// Check all guns in inventory
		for(var/obj/item/gun/projectile/G in H.contents)
			var/did_repair = FALSE
			// Fix condition
			if(G.condition < 100)
				G.condition = 100
				did_repair = TRUE
			// Unjam
			if(G.is_jammed)
				G.is_jammed = FALSE
				did_repair = TRUE
			if(did_repair)
				G.update_icon()
				repaired_any = TRUE

	if(repaired_any)
		playsound(loc, 'sound/items/Welder.ogg', 50, TRUE)

// Movement Toggle

/obj/effect/landmark/payload_marker/movement_override
	run_once = TRUE

/obj/effect/landmark/payload_marker/movement_override/handle_cart(obj/structure/payload/pl)
	pl.move_override = !pl.move_override

// Checkpoint - cart won't regress past this

/obj/effect/landmark/payload_marker/checkpoint
	run_once = TRUE
	var/obj/track = null

/obj/effect/landmark/payload_marker/checkpoint/Initialize()
	. = ..()
	if(!loc)
		return
	track = locate(/obj/structure/track/) in loc.contents
	if(!track)
		message_admins("COULD NOT INITIALIZE CHECKPOINT AT: ''[x] [y]''")
		qdel(src)
	/*
	var/duplicate = locate(/obj/effect/landmark/payload_marker) in loc.contents
	if(duplicate && duplicate != src)
		message_admins("DUPLICATE PAYLOAD LANDMARK FOUND: ''[x] [y]''")
	*/

/obj/effect/landmark/payload_marker/checkpoint/handle_cart(obj/structure/payload/pl)
	if(!track)
		return
	pl.checkpoint = track

/* --------------------------------- VISIBLE -------------------------------- */

/obj/effect/landmark/payload_marker/checkpoint/visible
	name = "tracks"
	desc = "It tracks."
	icon = 'code/modules/payload_gamemode/icons/tracks.dmi'
	icon_state = "checkpoint"
	run_once = FALSE
	invisibility = 0
	var/captured_by = null
	var/capture_sfx = 'sound/effects/payload/checkpoint.ogg'
	var/global_capture_sfx = 'sound/effects/capture.ogg'
	var/message = null  // HAVE REACHED THE SECOND CHECKPOINT etc set it in strongdmm
	var/mutable_appearance/glow_overlay
	alpha = 255

/obj/effect/landmark/payload_marker/checkpoint/visible/update_icon()
	. = ..()
	if(!captured_by)
		return
	if(glow_overlay)
		return
	glow_overlay = mutable_appearance(src.icon, "[icon_state]-glow")
	if(captured_by == RED_TEAM)
		glow_overlay.color = "#FF0000"
	else if(captured_by == BLUE_TEAM)
		glow_overlay.color = "#00c3ff"
	else
		glow_overlay.color = "#ffce46"
	glow_overlay.plane = GLOW_PLANE
	overlays += glow_overlay

/obj/effect/landmark/payload_marker/checkpoint/visible/on_run(obj/structure/payload/pl)
	if(captured_by)
		return
	. = ..()

/obj/effect/landmark/payload_marker/checkpoint/visible/handle_cart(obj/structure/payload/pl)
	. = ..()
	if(capture_sfx)
		playsound(loc, capture_sfx, 75, 0)
	if(global_capture_sfx)
		sound_to(world, global_capture_sfx)
	captured_by = pl.warfare_faction
	if(message)
		to_world(SPAN_YELLOW_LARGE("THE [uppertext(captured_by)] [message]."))
	update_icon()

/* -------------------------- WARFARE CONTROL POINT ------------------------- */

/obj/effect/landmark/payload_marker/checkpoint/visible/warfare/handle_cart(obj/structure/payload/pl)
	. = ..()
	switch(pl.warfare_faction)
		if(RED_TEAM)
			GLOB.red_captured_zones += src
		if(BLUE_TEAM)
			GLOB.blue_captured_zones += src

// Round-End Point

/obj/effect/landmark/payload_marker/end
	run_once = TRUE
	var/end_after = 1200
	var/losing_team  // In case we want to script it for special events
	var/roundend_sound = 'sound/ambience/round_over.ogg'

/obj/effect/landmark/payload_marker/end/handle_cart(obj/structure/payload/pl)
	pl.move_override = TRUE
	if(!losing_team)
		var/team = pl.warfare_faction
		switch(team)
			if(RED_TEAM)
				losing_team = BLUE_TEAM
			if(BLUE_TEAM)
				losing_team = RED_TEAM
	SSwarfare.end_warfare(losing_team)

	if(ticker && ticker.mode)
		ticker.mode.check_finished()
		ticker.declare_completion()

	sound_to(world, roundend_sound)

	sleep(end_after)
	world.Reboot()

/* ------------------------------ EXPLOSIVE END ----------------------------- */

/obj/effect/landmark/payload_marker/end/explosive/handle_cart(obj/structure/payload/pl)
	playsound(loc, 'sound/effects/payload/kaboom_ring.ogg', 75, 0)
	sleep(1 SECOND)
	explosion(loc, 3, 5, 7, 5)
	pl.visible_message(SPAN_DANGER("THE PAYLOAD EXPLODES!"))
	qdel(pl)
	. = ..()

/* -------------------------------- PAINT END ------------------------------- */

/obj/effect/landmark/payload_marker/end/paint/handle_cart(obj/structure/payload/pl)
	playsound(loc, 'sound/effects/payload/kaboom_ring.ogg', 75, 0)
	sleep(1 SECOND)
	var/to_color = "#FFFFFF"
	switch(pl.warfare_faction)
		if(RED_TEAM)
			to_color = "#ff3939"
		if(BLUE_TEAM)
			to_color = "#71aaff"
		else
			to_color = "#ffd667"
	for(var/atom/a in circleview(src, 16))
		a.color = to_color
	playsound(loc, 'sound/effects/payload/splat.ogg', 75, 0)
	pl.visible_message(SPAN_DANGER("THE PAYLOAD EXPLODES!"))
	animate(pl, 5 SECONDS, alpha = 0)
	QDEL_IN(pl, 5 SECONDS)
	. = ..()

// Spawn Shift - enables/disables cryospawns

/obj/effect/landmark/payload_marker/spawn_shift
	run_once = TRUE
	var/enable_id = null   // ID of CS units to enable (e.g. "red_forward_1")
	var/disable_id = null  // ID of CS units to disable (e.g. RED_TEAM)

/obj/effect/landmark/payload_marker/spawn_shift/handle_cart(obj/structure/payload/pl)
	// Disable old spawn points
	if(disable_id && length(GLOB.all_cryospawns[disable_id]))
		for(var/obj/structure/soldiercryo/special/C in GLOB.all_cryospawns[disable_id])
			C.disable_spawn()
		message_admins("Payload spawn shift: Disabled CS units with ID '[disable_id]'")

	// Enable new spawn points
	if(enable_id && length(GLOB.all_cryospawns[enable_id]))
		for(var/obj/structure/soldiercryo/special/C in GLOB.all_cryospawns[enable_id])
			C.enable_spawn()
		message_admins("Payload spawn shift: Enabled CS units with ID '[enable_id]'")

