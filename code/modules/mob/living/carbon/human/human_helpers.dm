#define HUMAN_EATING_NO_ISSUE		0
#define HUMAN_EATING_NBP_MOUTH		1
#define HUMAN_EATING_BLOCKED_MOUTH	2

#define add_clothing_protection(A)	\
	var/obj/item/clothing/C = A; \
	flash_protection += C.flash_protection; \
	equipment_tint_total += C.tint;

/mob/living/carbon/human/can_eat(var/food, var/feedback = 1)
	var/list/status = can_eat_status()
	if(status[1] == HUMAN_EATING_NO_ISSUE)
		return 1
	if(feedback)
		if(status[1] == HUMAN_EATING_NBP_MOUTH)
			to_chat(src, "Where do you intend to put \the [food]? You don't have a mouth!")
		else if(status[1] == HUMAN_EATING_BLOCKED_MOUTH)
			to_chat(src, "<span class='warning'>\The [status[2]] is in the way!</span>")
	return 0

/mob/living/carbon/human/can_force_feed(var/feeder, var/food, var/feedback = 1)
	var/list/status = can_eat_status()
	if(status[1] == HUMAN_EATING_NO_ISSUE)
		return 1
	if(feedback)
		if(status[1] == HUMAN_EATING_NBP_MOUTH)
			to_chat(feeder, "Where do you intend to put \the [food]? \The [src] doesn't have a mouth!")
		else if(status[1] == HUMAN_EATING_BLOCKED_MOUTH)
			to_chat(feeder, "<span class='warning'>\The [status[2]] is in the way!</span>")
	return 0

/mob/living/carbon/human/proc/can_eat_status()
	if(!check_has_mouth())
		return list(HUMAN_EATING_NBP_MOUTH)
	var/obj/item/blocked = check_mouth_coverage()
	if(blocked)
		return list(HUMAN_EATING_BLOCKED_MOUTH, blocked)
	return list(HUMAN_EATING_NO_ISSUE)

#undef HUMAN_EATING_NO_ISSUE
#undef HUMAN_EATING_NBP_MOUTH
#undef HUMAN_EATING_BLOCKED_MOUTH

/mob/living/carbon/human/proc/update_equipment_vision()
	flash_protection = 0
	equipment_tint_total = 0
	equipment_see_invis	= 0
	equipment_vision_flags = 0
	equipment_prescription = 0
	equipment_light_protection = 0
	equipment_darkness_modifier = 0
	equipment_overlays.Cut()
	var/use_original_cone = TRUE

	if(istype(src.head, /obj/item/clothing/head))
		add_clothing_protection(head)
		update_helmet_vision(head)
		use_original_cone = FALSE

	if(istype(src.glasses, /obj/item/clothing/glasses))
		process_glasses(glasses)

	if(istype(src.wear_mask, /obj/item/clothing/mask))
		add_clothing_protection(wear_mask)
		update_mask_vision(wear_mask)
		use_original_cone = FALSE

	if(use_original_cone)
		fov_mask.icon_state = "combat_mask"
		fov.icon_state = "combat"

/mob/living/carbon/human/proc/process_glasses(var/obj/item/clothing/glasses/G)
	if(G && G.active)
		equipment_darkness_modifier += G.darkness_view
		equipment_vision_flags |= G.vision_flags
		equipment_prescription += G.prescription
		equipment_light_protection += G.light_protection
		if(G.overlay)
			equipment_overlays |= G.overlay
		if(G.see_invisible >= 0)
			if(equipment_see_invis)
				equipment_see_invis = min(equipment_see_invis, G.see_invisible)
			else
				equipment_see_invis = G.see_invisible

		add_clothing_protection(G)
		G.process_hud(src)


/mob/living/carbon/human/proc/update_helmet_vision(var/obj/item/clothing/head/H)
	if(H.helmet_vision)
		fov_mask.icon_state = "helmet_mask"
		fov.icon_state = "helmet"
	else
		fov_mask.icon_state = "combat_mask"
		fov.icon_state = "combat"


/mob/living/carbon/human/proc/update_mask_vision(var/obj/item/clothing/mask/M)
	if(M.helmet_vision)
		fov_mask.icon_state = "helmet_mask"
		fov.icon_state = "helmet"
	else
		fov_mask.icon_state = "combat_mask"
		fov.icon_state = "combat"

/mob/living/carbon/human/get_gender()
	return gender

/mob/living/carbon/human/fully_replace_character_name(var/new_name, var/in_depth = TRUE)
	var/old_name = real_name
	. = ..()
	if(!. || !in_depth)
		return

	var/datum/computer_file/crew_record/R = get_crewmember_record(old_name)
	if(R)
		R.set_name(new_name)

	//update our pda and id if we have them on our person
	var/list/searching = GetAllContents(searchDepth = 3)
	var/search_id = 1
	var/search_pda = 1

	for(var/A in searching)
		if(search_id && istype(A,/obj/item/card/id))
			var/obj/item/card/id/ID = A
			if(ID.registered_name == old_name)
				ID.registered_name = new_name
				ID.update_name()
				search_id = 0
		else if(search_pda && istype(A,/obj/item/device/pda))
			var/obj/item/device/pda/PDA = A
			if(PDA.owner == old_name)
				PDA.set_owner(new_name)
				search_pda = 0


//Get species or synthetic temp if the mob is a FBP. Used when a synthetic type human mob is exposed to a temp check.
//Essentially, used when a synthetic human mob should act diffferently than a normal type mob.
/mob/living/carbon/human/proc/getSpeciesOrSynthTemp(var/temptype)
	switch(temptype)
		if(COLD_LEVEL_1)
			return isSynthetic()? SYNTH_COLD_LEVEL_1 : species.cold_level_1
		if(COLD_LEVEL_2)
			return isSynthetic()? SYNTH_COLD_LEVEL_2 : species.cold_level_2
		if(COLD_LEVEL_3)
			return isSynthetic()? SYNTH_COLD_LEVEL_3 : species.cold_level_3
		if(HEAT_LEVEL_1)
			return isSynthetic()? SYNTH_HEAT_LEVEL_1 : species.heat_level_1
		if(HEAT_LEVEL_2)
			return isSynthetic()? SYNTH_HEAT_LEVEL_2 : species.heat_level_2
		if(HEAT_LEVEL_3)
			return isSynthetic()? SYNTH_HEAT_LEVEL_3 : species.heat_level_3

/mob/living/carbon/human/proc/getCryogenicFactor(var/bodytemperature)
	if(isSynthetic())
		return 0
	if(!species)
		return 0

	if(bodytemperature > species.cold_level_1)
		return 0
	else if(bodytemperature > species.cold_level_2)
		. = 5 * (1 - (bodytemperature - species.cold_level_2) / (species.cold_level_1 - species.cold_level_2))
		. = max(2, .)
	else if(bodytemperature > species.cold_level_3)
		. = 20 * (1 - (bodytemperature - species.cold_level_3) / (species.cold_level_2 - species.cold_level_3))
		. = max(5, .)
	else
		. = 80 * (1 - bodytemperature / species.cold_level_3)
		. = max(20, .)
	return round(.)

/mob/living/carbon/human
	var/next_sonar_ping = 0

/mob/living/carbon/human/proc/sonar_ping()
	set name = "Listen In"
	set desc = "Allows you to listen in to movement and noises around you."
	set category = "IC"

	if(incapacitated())
		to_chat(src, "<span class='warning'>You need to recover before you can use this ability.</span>")
		return
	if(world.time < next_sonar_ping)
		to_chat(src, "<span class='warning'>You need another moment to focus.</span>")
		return
	if(is_deaf() || is_below_sound_pressure(get_turf(src)))
		to_chat(src, "<span class='warning'>You are for all intents and purposes currently deaf!</span>")
		return
	next_sonar_ping += 10 SECONDS
	var/heard_something = FALSE
	to_chat(src, "<span class='notice'>You take a moment to listen in to your environment...</span>")
	for(var/mob/living/L in range(client.view, src))
		var/turf/T = get_turf(L)
		if(!T || L == src || L.stat == DEAD || is_below_sound_pressure(T))
			continue
		heard_something = TRUE
		var/image/ping_image = image(icon = 'icons/effects/effects.dmi', icon_state = "sonar_ping", loc = src)
		ping_image.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		ping_image.layer = BEAM_PROJECTILE_LAYER
		ping_image.pixel_x = (T.x - src.x) * WORLD_ICON_SIZE
		ping_image.pixel_y = (T.y - src.y) * WORLD_ICON_SIZE
		show_image(src, ping_image)
		spawn(8)
			qdel(ping_image)
		var/feedback = list("<span class='notice'>There are noises of movement ")
		var/direction = get_dir(src, L)
		if(direction)
			feedback += "towards the [dir2text(direction)], "
			switch(get_dist(src, L) / client.view)
				if(0 to 0.2)
					feedback += "very close by."
				if(0.2 to 0.4)
					feedback += "close by."
				if(0.4 to 0.6)
					feedback += "some distance away."
				if(0.6 to 0.8)
					feedback += "further away."
				else
					feedback += "far away."
		else // No need to check distance if they're standing right on-top of us
			feedback += "right on top of you."
		feedback += "</span>"
		to_chat(src, jointext(feedback,null))
	if(!heard_something)
		to_chat(src, "<span class='notice'>You hear no movement but your own.</span>")

/mob/living/carbon/human/reset_layer()
	if(is_anonymous)
		plane = ANON_PLANE
		layer = BASE_MOB_LAYER
	else if(hiding)
		plane = HIDING_MOB_PLANE
		layer = HIDING_MOB_LAYER
	else if(lying)
		plane = LYING_HUMAN_PLANE
		layer = LYING_MOB_LAYER //Put lying humans in trenches below standing humans.
	else if(!locate(/obj/structure/bridge, src.loc) && istype(src.loc, /turf/simulated/floor/trench))//WHen in the trench, you are on the lying plane, so that people outside of the trench can loom over you threatenly.
		plane = LYING_HUMAN_PLANE
		layer = LYING_HUMAN_LAYER
	else if(locate(/obj/structure/bridge, src.loc) && src.plane == LYING_HUMAN_PLANE)
		plane = LYING_HUMAN_PLANE
		layer = LYING_HUMAN_LAYER
	else
		plane = HUMAN_PLANE
		layer = BASE_MOB_LAYER
	//	..()

/mob/living/carbon/human/proc/has_headset_in_ears()
	return istype(get_equipped_item(slot_l_ear), /obj/item/device/radio/headset) || istype(get_equipped_item(slot_r_ear), /obj/item/device/radio/headset)

/mob/living/carbon/human/proc/make_grab(var/mob/living/carbon/human/attacker, var/mob/living/carbon/human/victim, var/grab_tag)
	var/obj/item/grab/G

	if(!grab_tag)
		G = new attacker.current_grab_type(attacker, victim)
	else
		var/obj/item/grab/given_grab_type = all_grabobjects[grab_tag]
		G = new given_grab_type(attacker, victim)

	if(!G.pre_check())
		qdel(G)
		return 0

	if(G.can_grab())
		G.init()
		return 1
	else
		qdel(G)
		return 0

/mob/living/carbon/human
	var/list/cloaking_sources

// Returns true if, and only if, the human has gone from uncloaked to cloaked
/mob/living/carbon/human/proc/add_cloaking_source(var/datum/cloaking_source)
	var/has_uncloaked = clean_cloaking_sources()
	LAZYDISTINCTADD(cloaking_sources, weakref(cloaking_source))

	// We don't present the cloaking message if the human was already cloaked just before cleanup.
	if(!has_uncloaked && LAZYLEN(cloaking_sources) == 1)
		update_icons()
		src.visible_message("<span class='warning'>\The [src] seems to disappear before your eyes!</span>", "<span class='notice'>You feel completely invisible.</span>")
		return TRUE
	return FALSE

#define CLOAK_APPEAR_OTHER "<span class='warning'>\The [src] appears from thin air!</span>"
#define CLOAK_APPEAR_SELF "<span class='notice'>You have re-appeared.</span>"

// Returns true if, and only if, the human has gone from cloaked to uncloaked
/mob/living/carbon/human/proc/remove_cloaking_source(var/datum/cloaking_source)
	var/was_cloaked = LAZYLEN(cloaking_sources)
	clean_cloaking_sources()
	LAZYREMOVE(cloaking_sources, weakref(cloaking_source))

	if(was_cloaked && !LAZYLEN(cloaking_sources))
		update_icons()
		visible_message(CLOAK_APPEAR_OTHER, CLOAK_APPEAR_SELF)
		return TRUE
	return FALSE

// Returns true if the human is cloaked, otherwise false (technically returns the number of cloaking sources)
/mob/living/carbon/human/proc/is_cloaked()
	if(clean_cloaking_sources())
		update_icons()
		visible_message(CLOAK_APPEAR_OTHER, CLOAK_APPEAR_SELF)
	return LAZYLEN(cloaking_sources)

#undef CLOAK_APPEAR_OTHER
#undef CLOAK_APPEAR_SELF

// Returns true if the human is cloaked by the given source
/mob/living/carbon/human/proc/is_cloaked_by(var/cloaking_source)
	return LAZYISIN(cloaking_sources, weakref(cloaking_source))

// Returns true if this operation caused the mob to go from cloaked to uncloaked
/mob/living/carbon/human/proc/clean_cloaking_sources()
	if(!cloaking_sources)
		return FALSE

	var/list/rogue_entries = list()
	for(var/entry in cloaking_sources)
		var/weakref/W = entry
		if(!W.resolve())
			cloaking_sources -= W
			rogue_entries += W

	if(rogue_entries.len) // These entries did not cleanup after themselves before being destroyed
		var/rogue_entries_as_string = jointext(map(rogue_entries, /proc/log_info_line), ", ")
		crash_with("[log_info_line(src)] - Following cloaking entries were removed during cleanup: [rogue_entries_as_string]")

	UNSETEMPTY(cloaking_sources)
	return !cloaking_sources // If cloaking_sources wasn't initially null but is now, we've uncloaked
