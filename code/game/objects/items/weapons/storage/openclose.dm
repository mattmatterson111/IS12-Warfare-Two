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
		content_overlays += content_overlay
		index++
	add_contentoverlays()

/obj/item/storage/toggle/vialbox/blue
	icon_state = "vialbox_b0"
	base_state = "vialbox_b"




/obj/item/waxstamp
	name = "wax stamp"
	desc = "It stamps. That's all it does."
	icon = 'icons/obj/captainmail.dmi'
	icon_state = "stamper_red"

/obj/item/waxstamp/blue
	icon_state = "stamper_blue"

/obj/item/storage/toggle/envelope
	name = "envelope"
	desc = "used to safely contain paper- or other small objects."
	icon = 'icons/obj/captainmail.dmi'
	icon_state = "env0"
	base_state = "env"

	can_hold = list(/obj/item/paper,
					/obj/item/reagent_containers/pill,
					/obj/item/ammo_casing,
					/obj/item/clothing/mask/smokable/cigarette,
					/obj/item/flame/match,
					/obj/item/spacecash)
	storage_slots = 2
	storage_ui = /datum/storage_ui/default/envelope

	/// what type of wax got poured on it
	var/wax = null
	var/waxsealed = FALSE
	var/image/wax_overlay

	open_sound = 'sound/effects/env_open.ogg'
	close_sound = 'sound/effects/env_close.ogg'
	use_sound = 'sound/effects/envuse.ogg'

/obj/item/storage/toggle/envelope/update_icon()
	. = ..()
	if(wax_overlay)
		cut_overlay(wax_overlay)
	if(is_type_in_list(/obj/item/paper, contents) && open)
		icon_state = "[icon_state]-p"
	if(!waxsealed && wax)
		wax_overlay = icon(src.icon, "unstamp_[wax]")
		add_overlay(wax_overlay)
	if(waxsealed && wax)
		wax_overlay = icon(src.icon, "stamp_[wax]")
		add_overlay(wax_overlay)
/obj/item/storage/toggle/envelope/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/pen))
		var/newname = sanitize(input(user, "What shall this envelope be named?", "MAX 20 CHARACTERS") as text)
		if(length(newname) > 20)
			to_chat(user, SPAN_YELLOW("The name was too long, please write a shorter one instead."))
		if(do_after(user, 10))
			name = newname
			playsound(get_turf(src), "sound/effects/paper/sign[rand(1,4)].ogg", 75, TRUE)
			user.play_screen_text(pick("That'll do.","This should be good enough.","Mmhm."), alert = /atom/movable/screen/text/screen_text/audible/mood/hl2)

	if(waxsealed) return . = ..()
	if(istype(W, /obj/item/flame/candle))
		var/obj/item/flame/candle/C = W
		if(!C.lit) return . = ..()
		if(!C.wax >= 51)
			to_chat(user, SPAN_YELLOW("It doesn't seem like there's enough wax left in this one.."))
			return . = ..()
		wax = C.waxtype
		C.wax -= 50
		C.update_icon()
		update_icon()
		visible_message("[user] dabbles a portion of the [W]'s wax onto \the [src].", "You dable a portion of the [W]'s wax onto \the [src].")
		playsound(get_turf(src), 'sound/effects/wax.ogg', 100, 1, ignore_walls = FALSE)
		user.play_screen_text("It's ready to be sealed.", alert = /atom/movable/screen/text/screen_text/audible/mood/hl2)
		return FALSE
	if(istype(W, /obj/item/waxstamp))
		if(!wax) return . = ..()
		visible_message("[user] presses the [W] to \the [src], sealing the envelope.", "You press the [W] to \the [src], sealing the envelope.")
		user.play_screen_text("I've sealed the envelope.", alert = /atom/movable/screen/text/screen_text/audible/mood/hl2)
		waxsealed = TRUE
		update_icon()
		playsound(get_turf(src), 'sound/effects/softstamp.ogg', 100, 1, ignore_walls = FALSE)
	return . = ..()

/obj/item/storage/toggle/envelope/RightClick(mob/user)
	if(wax)
		wax = null
		visible_message("[user] cleans the wax off of \the [src].", "You clean the wax off of \the [src].")
		update_icon()
		playsound(get_turf(src), 'sound/effects/cleanwax.ogg', 100, 1, ignore_walls = FALSE)
		user.play_screen_text("I remove the wax.", alert = /atom/movable/screen/text/screen_text/audible/mood/hl2)
		return FALSE
	return . = ..()

/obj/item/storage/toggle/envelope/toggle(mob/user)
	set waitfor = 0
	if(waxsealed)
		var/areyousure = alert("Are you sure you wish to open this? It'll ruin the wax seal..", "Confirm Destruction", "Yes", "No")
		if(areyousure == "No") return
		waxsealed = FALSE
		wax = null
		visible_message("[user] opens the [src], destroying the seal.", "You open the [src], destroying the seal.")
		user.play_screen_text("I removed the seal.", alert = /atom/movable/screen/text/screen_text/audible/mood/hl2)
		openthis(user)
		sleep(3)
		storage_ui.on_hand_attack(user)
	. = ..()