/obj/item/storage/toggle
	name = "do not spawn"
	desc = "base item for christs sake."

	var/open = FALSE

	var/start_open = FALSE
	// okay fine. ^

	storage_slots = 14

	var/base_state

	var/open_sound

	//storage_ui = /datum/storage_ui/default/classic // to-do: make a subtype that is a fully resprited ver

/obj/item/storage/toggle/update_icon()
	..()
	icon_state = "[base_state][open]"

/obj/item/storage/toggle/proc/openthis(var/mob/user)
	open = TRUE
	playsound(user.loc, open_sound, 50, 1)
	update_icon()

/obj/item/storage/toggle/proc/closethis(var/mob/user)
	open = FALSE
	playsound(user.loc, close_sound, 50, 1)
	update_icon()

/obj/item/storage/toggle/proc/toggle(var/mob/user)
	if(!open)
		openthis(user)
	else
		closethis(user)

/obj/item/storage/toggle/open()
	if(!open)
		return
	return . = ..()

/obj/item/storage/toggle/handle_item_insertion(obj/item/W, prevent_warning, NoUpdate)
	if(!open)
		if(!prevent_warning)
			to_chat(usr, "<span class='danger'>I need to open \the [src] first!</span>")
		return FALSE
	return . = ..()


/obj/item/storage/toggle/remove_from_storage(obj/item/W, atom/new_location, NoUpdate)
	if(!open)
		return FALSE
	return . = ..()

/obj/item/storage/toggle/attack_self(mob/user)
	if(user.get_active_hand() == src)
		toggle(user)
		return
	return . = ..()

/obj/item/storage/toggle/RightClick(mob/user)
	if(CanPhysicallyInteract(user))
		toggle(user)

/obj/item/storage/toggle/AltClick(mob/user)
	if(CanPhysicallyInteract(user))
		toggle(user)

/obj/item/storage/toggle/vialbox
	name = "remedy kit"
	desc = "A box of secrets."
	icon = 'icons/obj/storage.dmi'
	icon_state = "vialbox0"
	base_state = "vialbox"

	slot_flags = SLOT_BELT

	can_hold = list(/obj/item/reagent_containers/glass/bottle/antique/slim,
		/obj/item/reagent_containers/glass/bottle/antique/vial,
		/obj/item/storage/pill_bottle,
		/obj/item/reagent_containers/syringe)
	var/static/content_states = list(
		"generic" = "vialbox-g",
		/obj/item/reagent_containers/glass/bottle/antique = "vialbox-v",
		/obj/item/storage/pill_bottle = "vialbox-v"
	)
	var/list/content_overlays = list()
	storage_ui = /datum/storage_ui/default/hud_metal
	storage_slots = 8
	startswith = list(
		/obj/item/reagent_containers/glass/bottle/antique/slim/dylovene = 1,
		/obj/item/reagent_containers/glass/bottle/antique/slim/chloroform = 1,
		/obj/item/reagent_containers/glass/bottle/antique/vial/dexalin = 1,
		/obj/item/reagent_containers/glass/bottle/antique/vial/spaceacillin = 1,
		/obj/item/reagent_containers/glass/bottle/antique/vial = 3,
		/obj/item/reagent_containers/syringe = 1)

/obj/item/storage/toggle/vialbox/proc/get_contentstate(var/atom/a)
	for(var/typestate in content_states)
		if(istype(a, typestate))
			return content_states[typestate]
		continue
	return content_states["generic"]

/obj/item/storage/toggle/vialbox/proc/add_contentoverlays()
	for(var/mutable_appearance/overlay in content_overlays)
		overlays += overlay

/obj/item/storage/toggle/vialbox/proc/remove_contentoverlays()
	for(var/mutable_appearance/overlay in content_overlays)
		overlays -= overlay

/obj/item/storage/toggle/vialbox/update_icon()
	. = ..()
	remove_contentoverlays()

	if(length(content_overlays))
		content_overlays.Cut()

	if(!open)
		return
	var/index = 1
	for(var/obj/item/I in contents)
		var/mutable_appearance/content_overlay = mutable_appearance(icon, "[get_contentstate(I)][index]")
		to_world("[get_contentstate(I)][listgetindex(contents, I)] - [src]")
		content_overlays += content_overlay
		index++
	add_contentoverlays()

/obj/item/storage/toggle/vialbox/blue
	icon_state = "vialbox_b0"
	base_state = "vialbox_b"