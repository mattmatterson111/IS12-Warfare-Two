/obj/structure/closet/crate/wooden
	name = "wooden crate"
	icon = 'icons/obj/closet.dmi'
	desc = "A rectangular wooden crate."
	icon_state = "milcrate"
	icon_opened = "milcrateopen"
	icon_closed = "milcrate"
	atom_flags = ATOM_FLAG_CLIMBABLE

	var/pry_sound = 'sound/effects/wood_crate_open.ogg'

	var/cover = /obj/item/crate_cover
	var/loose = FALSE

/obj/item/crate_cover
	name = "crate cover"
	desc = "A wooden cover for a crate.\nCould probably use it to re-seal a crate.. albeit loosely."
	icon = 'icons/obj/closet.dmi'
	icon_state = "milcrate_cover"
	layer = BELOW_OBJ_LAYER // Kept being overlayed ontop of items

/obj/structure/closet/crate/wooden/attackby(obj/item/W, mob/user)
	if(isCrowbar(W))
		if(opened)
			to_chat(user, SPAN_SIZE("There is no cover to pry off.</span>"))
			return
		user.visible_message(SPAN_WHITE("[user] pries \the [src] open.</span>"), \
			SPAN_WHITE("You pry open \the [src].</span>"), \
			SPAN_WHITE("You hear splitting wood.</span>"))
		new cover(get_turf(src))
		loose = TRUE
		playsound(src, pry_sound, 50, TRUE)
		open()
		update_icon()
		return
	if(istype(W, /obj/item/crate_cover))
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
