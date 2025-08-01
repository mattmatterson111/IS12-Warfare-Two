/obj/item/storage/toggle
	name = "do not spawn"
	desc = "base item for christs sake."

	var/open = FALSE

	var/start_open = FALSE
	// okay fine. ^

	storage_slots = 14

	var/open_icon_state
	var/closed_icon_state

	var/item_open_sound
	var/item_close_sound

	//storage_ui = /datum/storage_ui/default/classic // to-do: make a subtype that is a fully resprited ver

/obj/item/storage/toggle/update_icon()
	..()
	if(!closed_icon_state)
		closed_icon_state = icon_state
	if(!open_icon_state)
		open_icon_state = icon_state
	if(open)
		icon_state = open_icon_state
	else
		if(closed_icon_state)
			icon_state = closed_icon_state
		else
			icon_state = initial(icon_state)

/obj/item/storage/toggle/proc/openthis(var/mob/user)
	open = TRUE
	playsound(user.loc, item_open_sound, 50, 1)
	update_icon()

/obj/item/storage/toggle/proc/closethis(var/mob/user)
	open = FALSE
	playsound(user.loc, item_close_sound, 50, 1)
	update_icon()

/obj/item/storage/toggle/proc/toggle(var/mob/user)
	if(!open)
		openthis(user)
	else
		closethis(user)

/obj/item/storage/toggle/open()
	if(!open)
		return
	..()

/obj/item/storage/toggle/attack_self(mob/user)
	if(user.get_active_hand() == src)
		toggle(user)
		return
	..()

/obj/item/storage/toggle/RightClick(mob/user)
	if(CanPhysicallyInteract(user))
		toggle(user)

/obj/item/storage/toggle/AltClick(mob/user)
	if(CanPhysicallyInteract(user))
		toggle(user)