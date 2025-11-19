/obj/structure/closet/crate/wooden
	name = "wooden crate"
	icon = 'icons/obj/war_crates.dmi'
	desc = "A rectangular wooden crate."
	icon_state = "milcrate"
	icon_opened = "milcrate-open"
	icon_closed = "milcrate"
	atom_flags = ATOM_FLAG_CLIMBABLE

	var/pry_sound = 'sound/effects/wood_crate_open.ogg'

	var/cover = /obj/item/crate_cover
	var/loose = FALSE

/obj/item/crate_cover
	name = "crate cover"
	desc = "A wooden cover for a crate.\nCould probably use it to re-seal a crate.. albeit loosely."
	icon = 'icons/obj/war_crates.dmi'
	icon_state = "milcrate-cover"
	layer = BELOW_OBJ_LAYER // Kept being overlayed ontop of items

/obj/structure/closet/crate/wooden/RightClick(mob/living/user)
	return FALSE

/obj/structure/closet/crate/wooden/attackby(obj/item/W, mob/user)
	if(isCrowbar(W))
		if(opened)
			to_chat(user, SPAN_SIZE("There is no cover to pry off.</span>"))
			return
		if(loose)
			open()
			update_icon()
			new cover(get_turf(src))
			return
		user.visible_message(SPAN_WHITE("[user] pries \the [src] open.</span>"), \
			SPAN_WHITE("You pry open \the [src].</span>"), \
			SPAN_WHITE("You hear splitting wood.</span>"))
		if(cover)
			new cover(get_turf(src))
		loose = TRUE
		playsound(src, pry_sound, 50, TRUE)
		open()
		update_icon()
		return
	if(istype(W, cover))
		if(opened)
			user.drop_item()
			qdel(W)
			close()
			return
	. = ..()

/obj/structure/closet/crate/wooden/attack_hand(mob/user)
	if(!opened)
		if(!loose)
			to_chat(user, "[SPAN_SIZE("You need to pry the cover off first.")]\n[SPAN_SIZE("A crowbar would work well for this.")]")
			return
		if(cover)
			new cover(get_turf(src))
		open()
		update_icon()

/obj/structure/closet/crate/wooden/examine(mob/user, distance)
	. = ..()
	if(opened)
		return
	if(Adjacent(user))
		if(!loose)
			to_chat(user, SPAN_SIZE("I could probably open it using a crowbar.."))
		else
			to_chat(user, SPAN_SIZE("The cover's loose, I could probably open it with just my hands.."))

// Stuff to be moved to another file someday

/obj/structure/closet/crate/wooden/pickaxes/WillContain()
	return list(/obj/item/pickaxe/newpick = 10)

/obj/structure/closet/crate/wooden/hardhats/blue/WillContain()
	return list(/obj/item/clothing/head/hardhat/dblue = 10)

/obj/structure/closet/crate/wooden/hardhats/WillContain()
	return list(/obj/item/clothing/head/hardhat/red = 10)


/obj/structure/closet/crate/wooden/large
	name = "wooden crate"
	icon = 'icons/obj/war_crates.dmi'
	desc = "A boxy wooden crate."
	icon_state = "woodcrate"
	icon_opened = "woodcrate-open"
	icon_closed = "woodcrate"
	atom_flags = ATOM_FLAG_CLIMBABLE

	cover = /obj/item/crate_cover/large

/obj/item/crate_cover/large
	name = "crate cover"
	desc = "A wooden cover for a crate.\nCould probably use it to re-seal a crate.. albeit loosely."
	icon = 'icons/obj/war_crates.dmi'
	icon_state = "woodcrate-cover"
	layer = BELOW_OBJ_LAYER // Kept being overlayed ontop of items

/obj/structure/closet/crate/wooden/large/meatball
	name = "meatball crate"
	desc = "I'd.. better stay away from that.."
	icon_state = "meatball"
	icon_closed = "meatball"
	cover = null

/obj/structure/closet/crate/wooden/large/meatball/Initialize()
	. = ..()
	START_PROCESSING(SSslowprocess, src)

/obj/structure/closet/crate/wooden/large/meatball/Destroy()
	STOP_PROCESSING(SSslowprocess, src)
	. = ..()

/obj/structure/closet/crate/wooden/large/meatball/Process()
	if(prob(2))
		playsound(src, 'sound/effects/meatball.ogg', 25, TRUE, ignore_walls = FALSE, falloff = 3)
		visible_message(SPAN_DANGER("\the [src] growls.."))
		receive_damage()

/obj/structure/closet/crate/wooden/large/meatball/attack_hand(mob/user)
	if(!opened) return . = ..()
	user.doing_something = TRUE
	if(do_after(user, 5 SECONDS, src))
		user.doing_something = FALSE
		user.forceMove(src)
		user.visible_message(SPAN_DANGER("[user] is dragged into \the [src]!</span>"), \
			SPAN_DANGER("Something meaty reaches out of \the [src], pulling you inside!</span>"), \
			SPAN_DANGER("Something bad happened just now</span>"))
		user.ghostize()
		user.death()
		playsound(get_turf(src), 'sound/effects/hatched.ogg', 90, 0)
		sleep(7 SECONDS)
		user.forceMove(get_turf(src))
		user.gib()
	else
		user.doing_something = FALSE
		. = ..()

/obj/item/forcewield
	icon = 'icons/obj/war_crates.dmi'
	icon_state = "metal01-mini"
	item_state = "metal01-held"
	item_icons = list(
		slot_l_hand_str = 'icons/obj/war_crates.dmi',
		slot_r_hand_str = 'icons/obj/war_crates.dmi',
		)
	var/open_state = "metal01-mini-open"
	var/open_sound
	var/close_sound

	slowdown_general = 5
	throw_range = 1
	anchored = TRUE
	w_class = ITEM_SIZE_NO_CONTAINER
	var/silent_wield = TRUE // If TRUE, wielding will have no sound or visible messages <3

/obj/item/forcewield/attempt_wield(mob/user)
	if(wielded) //Trying to unwield it
		unwield(user, silent_wield)
	else //Trying to wield it
		wield(user, silent_wield)

/obj/item/forcewield/unwield(mob/user)
	. = ..()
	if(user.get_active_hand() == src)
		user.drop_item()
	else
		user.hand = !user.hand
		user.drop_item()
		user.hand = !user.hand
	dropped(user)
	return

/obj/item/forcewield/attack_hand(mob/user)
	if(user.isChild())
		to_chat(user, "<span class='warning'>It's too heavy!</span>")
		return
	if(user.get_inactive_hand() && isworld(loc))
		to_chat(user, "<span class='warning'>You need your other hand to be empty!</span>")
		return
	. = ..()
	wield(user)

/obj/structure/closet/crate/club

/obj/structure/closet/crate/club/WillContain()
	return list(
		/obj/item/melee/classic_baton/trench_club = 5)

/obj/structure/closet/crate/grenade

/obj/structure/closet/crate/grenade/WillContain()
	return list(
		/obj/item/grenade/frag/warfare = 5)