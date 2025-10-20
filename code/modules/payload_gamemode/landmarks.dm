/obj/effect/payload/
	icon = 'icons/hammer/source.dmi'
	icon_state = "landmark2"
	var/run_once = FALSE
	invisibility = 101
	anchored = TRUE

/obj/effect/payload/proc/on_run(var/obj/structure/payload/pl)
	set waitfor = 0
	handle_cart(pl)
	if(run_once)
		qdel(src)
	return

/obj/effect/payload/proc/handle_cart(var/obj/structure/payload/pl)
	return

/* -------------------------------------------------------------------------- */
/*                               SPEED HANDLING                               */
/* -------------------------------------------------------------------------- */

/obj/effect/payload/speed
	run_once = TRUE

/obj/effect/payload/speed/increase/handle_cart(obj/structure/payload/pl)
	pl.speed_mod*=2
/obj/effect/payload/speed/decrease/handle_cart(obj/structure/payload/pl)
	pl.speed_mod-=2
/obj/effect/payload/speed/reset/handle_cart(obj/structure/payload/pl)
	pl.speed_mod = initial(pl.speed_mod)

/* -------------------------------------------------------------------------- */
/*                               MOVEMENT TOGGLE                              */
/* -------------------------------------------------------------------------- */

/obj/effect/payload/movement_override
	run_once = TRUE

/obj/effect/payload/movement_override/handle_cart(obj/structure/payload/pl)
	pl.move_override = !pl.move_override

/* -------------------------------------------------------------------------- */
/*                                 CHECKPOINT                                 */
/* -------------------------------------------------------------------------- */

/* ------------- This applies to the cart's movement regression ------------- */

/obj/effect/payload/checkpoint
	run_once = TRUE
	var/obj/track = null

/obj/effect/payload/checkpoint/Initialize()
	. = ..()
	if(!loc) return // somehow??
	track = locate(/obj/structure/track/) in loc.contents
	if(!track)
		message_admins("COULD NOT INITIALIZE CHECKPOINT AT: ''[x] [y]''")
		qdel(src)
	var/duplicate = locate(/obj/effect/payload) in loc.contents
	if(duplicate)
		message_admins("DUPLICATE PAYLOAD LANDMARK FOUND: ''[x] [y]''")

/obj/effect/payload/checkpoint/handle_cart(obj/structure/payload/pl)
	if(!track) return
	pl.checkpoint = track

/* --------------------------------- VISIBLE -------------------------------- */

/obj/effect/payload/checkpoint/visible
	name = "tracks"
	desc = "It tracks."
	icon = 'code/modules/payload_gamemode/icons/tracks.dmi'
	icon_state = "checkpoint"
	run_once = FALSE
	invisibility = 0
	var/captured_by = null
	var/capture_sfx = 'sound/effects/payload/checkpoint.ogg'
	var/global_capture_sfx = 'sound/effects/capture.ogg'
	var/message = null // HAVE REACHED THE SECOND CHECKPOINt etc set it in strongdmm idc
	var/mutable_appearance/glow_overlay
	alpha = 255

/obj/effect/payload/checkpoint/visible/update_icon()
	. = ..()
	if(!captured_by) return
	if(glow_overlay) return
	glow_overlay = mutable_appearance(src.icon, "[icon_state]-glow")
	if(captured_by == RED_TEAM)
		glow_overlay.color = "#FF0000"
	else if(captured_by == BLUE_TEAM)
		glow_overlay.color = "#00c3ff"
	else
		glow_overlay.color = "#ffce46"
	glow_overlay.plane = GLOW_PLANE
	overlays += glow_overlay

/obj/effect/payload/checkpoint/visible/on_run(obj/structure/payload/pl)
	if(captured_by) return
	. = ..()

/obj/effect/payload/checkpoint/visible/handle_cart(obj/structure/payload/pl)
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

/obj/effect/payload/checkpoint/visible/warfare/handle_cart(obj/structure/payload/pl)
	. = ..()
	switch(pl.warfare_faction)
		if(RED_TEAM)
			GLOB.red_captured_zones += src
		if(BLUE_TEAM)
			GLOB.blue_captured_zones += src

/* -------------------------------------------------------------------------- */
/*                               ROUND-END POINT                              */
/* -------------------------------------------------------------------------- */

/obj/effect/payload/end
	run_once = TRUE
	var/end_after = 1200
	var/losing_team // incase we want to script it for special shit
	var/roundend_sound = 'sound/ambience/round_over.ogg'

/obj/effect/payload/end/handle_cart(obj/structure/payload/pl)
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

	sound_to(world,roundend_sound)

	sleep(end_after)
	world.Reboot()

/* ------------------------------ EXPLOSIVE END ----------------------------- */

/obj/effect/payload/end/explosive/handle_cart(obj/structure/payload/pl)
	playsound(loc, 'sound/effects/payload/kaboom_ring.ogg', 75, 0)
	sleep(1 SECOND)
	explosion(loc, 3, 5, 7, 5)
	pl.visible_message(SPAN_DANGER("THE PAYLOAD EXPLODES!"))
	qdel(pl)
	. = ..()

/* ------------------------------ EXPLOSIVE END ----------------------------- */

/obj/effect/payload/end/explosive/handle_cart(obj/structure/payload/pl)
	playsound(loc, 'sound/effects/payload/kaboom_ring.ogg', 75, 0)
	sleep(1 SECOND)
	explosion(loc, 3, 5, 7, 5)
	pl.visible_message(SPAN_DANGER("THE PAYLOAD EXPLODES!"))
	qdel(pl)
	. = ..()

/obj/effect/payload/end/paint/handle_cart(obj/structure/payload/pl)
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
