/obj/item/cane
	name = "cane"
	desc = "A cane used by a true gentlemen. Or a clown."
	icon = 'icons/obj/weapons/canesword.dmi'
	icon_state = "canesword_hidden"
	item_state = "stick"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 5.0
	throwforce = 7.0
	w_class = ITEM_SIZE_SMALL
	matter = list(DEFAULT_WALL_MATERIAL = 50)
	attack_verb = list("bludgeoned", "whacked", "disciplined", "thrashed")

/obj/item/cane/concealed
	var/obj/item/concealed_object = null
	// storing the item ^
	var/shaft_icon_state = "canesword_sheath"
	var/shaft_item_state = "foldcane"
	// empty cane stuff ^
	var/sheathe_sound = 'sound/items/holster_sword1.ogg'
	var/unsheathe_sound = 'sound/items/unholster_sword01.ogg'
	// unsheathing/sheating sounds ^
	var/obj/spawn_with = /obj/item/material/sword/cane/
	// the obj that it spawns with, used to determine if it's the right type, too.
	var/spawn_empty = FALSE
	// if it should spawn empty.
	var/delay = 0.15 SECONDS
	// saving you the headache. ^

/obj/item/cane/concealed/New()
	..()
	if(!spawn_empty)
		concealed_object = new spawn_with(src)
		concealed_object.attack_self()
	else
		update_icon()

/obj/item/cane/concealed/proc/unsheathe(var/mob/user)
	if(user.doing_something)
		return
	user.doing_something = TRUE
	if(do_after(user, delay))
		user.doing_something = FALSE
		user.visible_message("<span class='warning'>[user] has unsheathed \a [concealed_object] from [src]!</span>", "You unsheathe \the [concealed_object] from [src].")
		// Calling drop/put in hands to properly call item drop/pickup procs
		//playsound(user.loc, unsheathe_sound, 50, 1)
		user.drop_from_inventory(src)
		user.put_in_hands(concealed_object)
		user.put_in_hands(src)
		concealed_object = null
		update_icon()
		user.update_inv_l_hand()
		user.update_inv_r_hand()
		return TRUE
	else
		user.doing_something = FALSE

/obj/item/cane/concealed/attack_self(var/mob/user)
	if(concealed_object)
		unsheathe(user)
	else
		if(istype(user.get_inactive_hand(), spawn_with))
			sheathe(user.get_inactive_hand(), user, put_in_hand=FALSE)
			return
		..()

/obj/item/cane/concealed/proc/sheathe(var/obj/W, var/mob/user, var/put_in_hand=TRUE)
	if(user.doing_something)
		return
	user.doing_something = TRUE
	if(do_after(user, delay))
		user.doing_something = FALSE
		user.visible_message("<span class='warning'>[user] has sheathed \a [W] into [src]!</span>", "You sheathe \the [W] into [src].")
		playsound(user.loc, sheathe_sound, 50, 1)
		user.drop_from_inventory(W)
		W.loc = src
		src.concealed_object = W
		if(put_in_hand)
			user.put_in_hands(src)
		update_icon()
		user.update_inv_l_hand()
		user.update_inv_r_hand()
		return TRUE
	else
		user.doing_something = FALSE

/obj/item/cane/concealed/attackby(var/obj/item/W, var/mob/user)
	if(!src.concealed_object && istype(W, spawn_with))
		sheathe(W, user)
	else
		..()

/obj/item/cane/concealed/update_icon()
	if(concealed_object)
		SetName(initial(name))
		icon_state = initial(icon_state)
		item_state = initial(item_state)
	else
		SetName("cane shaft")
		icon_state = shaft_icon_state
		item_state = shaft_item_state

/obj/item/material/sword/cane
	icon = 'icons/obj/weapons/canesword.dmi'
	icon_state = "cane_sword"

	item_state = "sabre"
	name = "cane sword"
	desc = "A sword specially modified to nest inside the body of a cane"
	slot_flags = SLOT_BELT
	grab_sound_is_loud = TRUE
	grab_sound = 'sound/items/unholster_sword01.ogg'

/obj/item/cane/concealed/prac
	spawn_with = /obj/item/storage/cane

/obj/item/storage/cane
	icon = 'icons/obj/weapons/canesword.dmi'
	icon_state = "cane_sword"
	w_class = ITEM_SIZE_HUGE
	slot_flags = SLOT_BACK
	max_w_class = ITEM_SIZE_LARGE
	max_storage_space = DEFAULT_BOX_STORAGE
	startswith = list(/obj/item/storage/toggle/cloth, /obj/item/reagent_containers/glass/bottle/antitoxin, /obj/item/reagent_containers/glass/bottle/inaprovaline, /obj/item/reagent_containers/glass/ampule/morphine)

/obj/item/storage/toggle/cloth
	icon = 'icons/obj/items.dmi'
	icon_state = "sheet-wetleather"
	color = "#897e9b"
	open_sound = 'sound/effects/teleretract3.ogg'
	close_sound = 'sound/effects/teleextend4.ogg'
	startswith = list(/obj/item/reagent_containers/syringe/ = 2)
	can_hold = list(/obj/item/reagent_containers/syringe/)
	storage_ui = /datum/storage_ui/default/slotted
	storage_slots = 2
	w_class = ITEM_SIZE_LARGE
