/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	w_class = ITEM_SIZE_NORMAL
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	layer = BASE_OBJ_LAYER

	var/image/blood_overlay = null //this saves our blood splatter overlay, which will be processed not to go over the edges of the sprite
	var/randpixel = 6
	var/r_speed = 1.0
	var/health = null
	var/burn_point = null
	var/burning = null
	var/hitsound = null
	var/equipsound = null
	var/str_requirement = 0
	var/slot_flags = 0		//This is used to determine on which slots an item can fit.
	var/no_attack_log = 0			//If it's an item we don't want to log attack_logs with, set this to 1
	pass_flags = PASS_FLAG_TABLE
//	causeerrorheresoifixthis
	var/obj/item/master = null
	var/list/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	var/list/attack_verb = list("hit") //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"
	var/lock_picking_level = 0 //used to determine whether something can pick a lock, and how well.
	var/force = 0

	var/heat_protection = 0 //flags which determine which body parts are protected from heat. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/cold_protection = 0 //flags which determine which body parts are protected from cold. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags

	var/datum/action/item_action/action = null
	var/action_button_name //It is also the text which gets displayed on the action button. If not set it defaults to 'Use [name]'. If it's not set, there'll be no button.
	var/action_button_is_hands_free = 0 //If 1, bypass the restrained, lying, and stunned checks action buttons normally test for

	//This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	//It should be used purely for appearance. For gameplay effects caused by items covering body parts, use body_parts_covered.
	var/flags_inv = 0
	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags

	var/item_flags = 0 //Miscellaneous flags pertaining to equippable objects.

	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown_general = 0 // How much clothing is slowing you down. Negative values speeds you up. This is a genera##l slowdown, no matter equipment slot.
	var/slowdown_per_slot[slot_last] // How much clothing is slowing you down. This is an associative list: item slot - slowdown
	var/slowdown_accessory // How much an accessory will slow you down when attached to a worn article of clothing.
	var/canremove = 1 //Mostly for Ninja code at this point but basically will not allow the item to be removed if set to 0. /N
	var/list/armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/list/allowed = null //suit storage stuff.
	var/obj/item/device/uplink/hidden_uplink = null // All items can have an uplink hidden inside, just remember to add the triggers.
	var/zoomdevicename = null //name used for message when binoculars/scope is used
	var/zoom = 0 //1 if item is actively being used to zoom. For scoped guns and binoculars.

	var/icon_override = null  //Used to override hardcoded clothing dmis in human clothing proc.

	var/use_alt_layer = FALSE // Use the slot's alternative layer when rendering on a mob

	//** These specify item/icon overrides for _slots_

	var/list/item_state_slots = list(slot_wear_id_str = "id") //overrides the default item_state for particular slots.

	// Used to specify the icon file to be used when the item is worn. If not set the default icon for that slot will be used.
	// If icon_override or sprite_sheets are set they will take precendence over this, assuming they apply to the slot in question.
	// Only slot_l_hand/slot_r_hand are implemented at the moment. Others to be implemented as needed.
	var/list/item_icons

	var/list/worldicons
	var/originalstate

	//** These specify item/icon overrides for _species_

	/* Species-specific sprites, concept stolen from Paradise//vg/.
	ex:
	sprite_sheets = list(
		SPECIES_TAJARA = 'icons/cat/are/bad'
		)
	If index term exists and icon_override is not set, this sprite sheet will be used.
	*/
	var/list/sprite_sheets = list()

	var/hit_shake = 0.15 //shouldn't be greater than 0.1 or 0.25. Anything above that feels like too much.0.15

	// Species-specific sprite sheets for inventory sprites
	// Works similarly to worn sprite_sheets, except the alternate sprites are used when the clothing/refit_for_species() proc is called.
	var/list/sprite_sheets_obj = list()

	var/sharpness = 0 //This is a special snowflake var that lets us cut peoples' heads off.
	var/block_chance = 0 //This is the chance in percent that we will be able to block an attack with this weapon.
	var/list/parry_sounds = list() //List of parry sounds to play when we block.

	var/next_attack_time = 0
	var/weapon_speed_delay = 15
	var/drop_sound = 'sound/items/handle/generic_drop1.ogg'
	var/swing_sound = null
	var/grab_sound = null
	var/grab_sound_is_loud = FALSE
	var/wielded = 0
	var/wieldsound = 'sound/weapons/thudswoosh.ogg'
	var/unwieldsound = null
	var/wielded_icon = null
	var/force_unwielded = 0
	var/force_wielded = 0
	var/time_to_equip = 0
	var/time_to_unequip = 0
	var/bag_place_sound = "rustle"
	var/bag_pickup_sound = null

	var/table_pickup_sound = null //Sound it makes when you take something off a table.


/obj/item/New()
	..()
	originalstate = icon_state
	if(!swing_sound)
		if(sharp || edge)
			swing_sound = "swing_sound"
		else
			swing_sound = "blunt_swing"
	if(randpixel && (!pixel_x && !pixel_y) && isturf(loc)) //hopefully this will prevent us from messing with mapper-set pixel_x/y
		pixel_x = rand(-randpixel, randpixel)
		pixel_y = rand(-randpixel, randpixel)

/obj/item/Destroy()
	qdel(hidden_uplink)
	hidden_uplink = null
	if(ismob(loc))
		var/mob/m = loc
		m.drop_from_inventory(src)
		m.update_inv_r_hand()
		m.update_inv_l_hand()
		src.loc = null
	return ..()

/obj/item/device
	icon = 'icons/obj/device.dmi'

/mob/verb/wield_hotkey()//For the hotkeys.
	set name = ".wield"
	do_wield()

/mob/verb/toggle_gun_safety()
	set name = ".toggle_safety"
	set hidden = TRUE
	var/obj/item/I = get_active_hand()
	if(!I)
		return
	if(istype(I, /obj/item/gun))
		var/obj/item/gun/G = I
		G.toggle_safety(src)

/mob/proc/do_wield()//The proc we actually care about.
	if(!isliving(src))//So ghosts can't do this.
		return
	var/obj/item/I = get_active_hand()
	if(!I)
		return
	I.attempt_wield(src)

/obj/item/proc/unwield(mob/user)
	if(!wielded || !user)
		return
	wielded = 0
	if(force_unwielded)
		force = force_unwielded
	else
		force = (force / 1.5)
	var/sf = findtext(name," (Wielded)")
	if(sf)
		name = copytext(name,1,sf)
	else //something wrong
		name = "[initial(name)]"
	update_unwield_icon()
	update_icon()
	if(user)
		user.update_inv_r_hand()
		user.update_inv_l_hand()

	user.visible_message("<span class='warning'>[user] lets go of their other hand.")
	if(unwieldsound)
		playsound(loc, unwieldsound, 50, 1)
	var/obj/item/twohanded/offhand/O = user.get_inactive_hand()
	if(O && istype(O))
		user.drop_from_inventory(O)
	return

/obj/item/proc/wield(mob/user)
	if(wielded)
		return
	if(!is_held_twohanded(user))
		return
	if(user.get_inactive_hand())
		to_chat(user, "<span class='warning'>You need your other hand to be empty!</span>")
		return
	wielded = 1
	if(force_wielded)
		force = force_wielded
	else
		force = (force * 1.5)
	name = "wielded [name]"
	update_wield_icon()
	update_icon()//Legacy
	if(user)
		user.update_inv_r_hand()
		user.update_inv_l_hand()
	user.visible_message("<span class='warning'>[user] grabs the [initial(name)] with both hands.")
	if(wieldsound)
		playsound(loc, wieldsound, 50, 1)
	var/obj/item/twohanded/offhand/O = new(user) ////Let's reserve his other hand~
	O.name = "[name] - offhand"
	O.desc = "Your second grip on the [name]"
	O.weight = 0
	user.put_in_inactive_hand(O)
	return

/obj/item/proc/update_wield_icon()
	if(wielded && wielded_icon)
		item_state = wielded_icon

/obj/item/proc/update_unwield_icon()//That way it doesn't interupt any other special icon_states.
	if(wielded_icon)
		item_state = "[initial(item_state)]"

//For general weapons.
/obj/item/proc/attempt_wield(mob/user)
	if(wielded) //Trying to unwield it
		unwield(user)
	else //Trying to wield it
		wield(user)

//Checks if the item is being held by a mob, and if so, updates the held icons
/obj/item/proc/update_twohanding()
	update_held_icon()

/obj/item/proc/update_held_icon()
	if(ismob(src.loc))
		var/mob/M = src.loc
		if(M.l_hand == src)
			M.update_inv_l_hand()
		else if(M.r_hand == src)
			M.update_inv_r_hand()

/obj/item/proc/is_held_twohanded(mob/living/M)
	var/check_hand
	if(M.l_hand == src && !M.r_hand)
		check_hand = BP_R_HAND //item in left hand, check right hand
	else if(M.r_hand == src && !M.l_hand)
		check_hand = BP_L_HAND //item in right hand, check left hand
	else
		return FALSE

	//would check is_broken() and is_malfunctioning() here too but is_malfunctioning()
	//is probabilistic so we can't do that and it would be unfair to just check one.
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/hand = H.organs_by_name[check_hand]
		if(istype(hand) && hand.is_usable())
			return TRUE
	return FALSE


/obj/item/twohanded/offhand
	name = "offhand"
	icon_state = "offhand"
	w_class = ITEM_SIZE_NO_CONTAINER
	atom_flags = ATOM_FLAG_NO_BLOOD//ABSTRACT | NOBLOODY
	item_flags = ITEM_FLAG_ABSTRACT


/obj/item/twohanded/offhand/RightClick(mob/user)
	var/obj/item/I = user.get_active_hand()
	var/obj/item/II = user.get_inactive_hand()
	if(I)
		I.unwield(user)
	if(II)
		II.unwield(user)

	loc = null
	if(!QDELETED(src))
		qdel(src)


/obj/item/twohanded/offhand/unwield()
	//if(wielded)//Only delete if we're wielded
	wielded = FALSE
	loc = null
	if(!QDELETED(src))
		qdel(src)

/obj/item/twohanded/offhand/wield()
	if(wielded)//Only delete if we're wielded
		wielded = FALSE
		loc = null
		if(!QDELETED(src))
			qdel(src)

/obj/item/twohanded/offhand/dropped(mob/user)
	..()
	var/obj/item/I = user.get_active_hand()
	var/obj/item/II = user.get_inactive_hand()
	if(I)
		I.unwield(user)
	if(II)
		II.unwield(user)
	loc = null
	if(!QDELETED(src))
		qdel(src)


/obj/item/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if (prob(50))
				qdel(src)
		if(3)
			if (prob(5))
				qdel(src)

/obj/item/proc/move_to_top()
	set name = "Move To Top"
	set category = "Object"
	set src in oview(1)

	if(!istype(src.loc, /turf) || usr.stat || usr.restrained() )
		return

	var/turf/T = src.loc

	src.loc = null

	src.loc = T

/obj/item/examine(mob/user, var/distance = -1)
	var/size
	switch(src.w_class)
		if(ITEM_SIZE_TINY)
			size = "tiny"
		if(ITEM_SIZE_SMALL)
			size = "small"
		if(ITEM_SIZE_NORMAL)
			size = "normal-sized"
		if(ITEM_SIZE_LARGE)
			size = "large"
		if(ITEM_SIZE_HUGE)
			size = "bulky"
		if(ITEM_SIZE_HUGE + 1 to INFINITY)
			size = "huge"
	return ..(user, distance, "", SPAN_SIZE("<br>It is a [size] item."))

/obj/item/attack_hand(mob/user as mob)
	if (!user) return
	if (hasorgans(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.organs_by_name[BP_R_HAND]
		if (user.hand)
			temp = H.organs_by_name[BP_L_HAND]
		if(temp && !temp.is_usable() || temp && temp.status & ORGAN_BROKEN)
			to_chat(user, "<span class='notice'>You try to move your [temp.name], but cannot!</span>")
			return
		if(!temp)
			to_chat(user, "<span class='notice'>You try to use your hand, but realize it is no longer attached!</span>")
			return

	var/old_loc = src.loc

	src.pickup(user)
	if (istype(src.loc, /obj/item/storage))
		var/obj/item/storage/S = src.loc
		S.remove_from_storage(src)

	src.throwing = 0
	if (src.loc == user)
		if(!user.unEquip(src))
			return
	else
		if(isliving(src.loc))
			return
	if(user.put_in_active_hand(src))
		if (isturf(old_loc))
			var/obj/effect/temporary/item_pickup_ghost/ghost = new(old_loc, src)
			ghost.animate_towards(user)
		if(randpixel)
			pixel_x = rand(-randpixel, randpixel)
			pixel_y = rand(-randpixel/2, randpixel/2)
			pixel_z = 0
		else if(randpixel == 0)
			pixel_x = 0
			pixel_y = 0
	return

/obj/item/attack_ai(mob/user as mob)
	if (istype(src.loc, /obj/item/robot_module))
		//If the item is part of a cyborg module, equip it
		if(!isrobot(user))
			return
		var/mob/living/silicon/robot/R = user
		R.activate_module(src)
		R.hud_used.update_robot_modules_display()

/obj/item/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/storage))
		var/obj/item/storage/S = W
		if(S.use_to_pickup)
			if(S.collection_mode) //Mode is set to collect all items
				if(isturf(src.loc))
					S.gather_all(src.loc, user)
			else if(S.can_be_inserted(src, user))
				S.handle_item_insertion(src)

/obj/item/proc/talk_into(mob/M as mob, text)
	return

/obj/item/proc/moved(mob/user as mob, old_loc as turf)
	return

// apparently called whenever an item is removed from a slot, container, or anything else.
/obj/item/proc/dropped(mob/user as mob)
	if(randpixel)
		pixel_z = randpixel //an idea borrowed from some of the older pixel_y randomizations. Intended to make items appear to drop at a character
	if(zoom)
		zoom(user) //binoculars, scope, etc
	if(wielded)
		unwield(user)

	update_twohanding()
	if(user)
		if(user.l_hand)
			user.l_hand.update_twohanding()
		if(user.r_hand)
			user.r_hand.update_twohanding()
	if(worldicons)
		if(islist(worldicons))
			if(LAZYLEN(worldicons))
				originalstate = icon_state
				icon_state = safepick(worldicons)
		else
			originalstate = icon_state
			icon_state = worldicons

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	if(locate(/obj/structure/table) in loc)
		if(table_pickup_sound)
			playsound(src, table_pickup_sound, 50)
	return

// called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/storage/S as obj)
	if(bag_pickup_sound)
		playsound(src, bag_pickup_sound, 50)
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/storage/S as obj)
	if(bag_place_sound)
		playsound(src, bag_place_sound, 50)
	if(worldicons)
		icon_state = originalstate
		originalstate = icon_state
	return

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder as mob)
	return

/obj/item/proc/mill()
	return

/obj/item/proc/press()
	return


// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(var/mob/user, var/slot)
	hud_layerise()
	if(user.client)	user.client.screen |= src
	if(user.pulling == src) user.stop_pulling()

	//Update two-handing status
	var/mob/M = loc
	if(!istype(M))
		return
	if(M.l_hand)
		M.l_hand.update_twohanding()
	if(M.r_hand)
		M.r_hand.update_twohanding()

	if(wielded)
		unwield(user)
	if(LAZYLEN(worldicons))
		icon_state = originalstate


//Defines which slots correspond to which slot flags
var/list/global/slot_flags_enumeration = list(
	"[slot_wear_mask]" = SLOT_MASK,
	"[slot_back]" = SLOT_BACK,
	"[slot_wear_suit]" = SLOT_OCLOTHING,
	"[slot_gloves]" = SLOT_GLOVES,
	"[slot_shoes]" = SLOT_FEET,
	"[slot_belt]" = SLOT_BELT,
	"[slot_glasses]" = SLOT_EYES,
	"[slot_head]" = SLOT_HEAD,
	"[slot_l_ear]" = SLOT_EARS|SLOT_TWOEARS,
	"[slot_r_ear]" = SLOT_EARS|SLOT_TWOEARS,
	"[slot_w_uniform]" = SLOT_ICLOTHING,
	"[slot_wear_id]" = SLOT_ID,
	"[slot_tie]" = SLOT_TIE,
	"[slot_s_store]" = SLOT_S_STORE,
	"[slot_chest]" = SLOT_CHEST
	)

/obj/item/proc/unequipped(var/mob/user)
	return

//the mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
//If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
//Set disable_warning to 1 if you wish it to not give you outputs.
//Should probably move the bulk of this into mob code some time, as most of it is related to the definition of slots and not item-specific
//set force to ignore blocking overwear and occupied slots
/obj/item/proc/mob_can_equip(M as mob, slot, disable_warning = 0, force = 0)
	if(!slot) return 0
	if(!M) return 0

	if(!ishuman(M)) return 0

	var/mob/living/carbon/human/H = M
	var/list/mob_equip = list()
	if(H.species.hud && H.species.hud.equip_slots)
		mob_equip = H.species.hud.equip_slots

	if(H.species && !(slot in mob_equip))
		return 0

	//First check if the item can be equipped to the desired slot.
	if("[slot]" in slot_flags_enumeration)
		var/req_flags = slot_flags_enumeration["[slot]"]
		if(!(req_flags & slot_flags))
			return 0

	if(!force)
		//Next check that the slot is free
		if(H.get_equipped_item(slot))
			return 0

		//Next check if the slot is accessible.
		var/mob/_user = disable_warning? null : H
		if(!H.slot_is_accessible(slot, src, _user))
			return 0

	//Lastly, check special rules for the desired slot.
	switch(slot)
		if(slot_l_ear, slot_r_ear)
			var/slot_other_ear = (slot == slot_l_ear)? slot_r_ear : slot_l_ear
			if( (w_class > ITEM_SIZE_TINY) && !(slot_flags & SLOT_EARS) )
				return 0
			if( (slot_flags & SLOT_TWOEARS) && H.get_equipped_item(slot_other_ear) )
				return 0
		if(slot_belt)
			if(!H.w_uniform && (slot_w_uniform in mob_equip))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
				return 0
		if(slot_l_store, slot_r_store)
			if(!H.w_uniform && (slot_w_uniform in mob_equip))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
				return 0
			if(slot_flags & SLOT_DENYPOCKET)
				return 0
			if( w_class > ITEM_SIZE_SMALL && !(slot_flags & SLOT_POCKET) )
				return 0
			if(get_storage_cost() == ITEM_SIZE_NO_CONTAINER)
				return 0 //pockets act like storage and should respect ITEM_SIZE_NO_CONTAINER. Suit storage might be fine as is
		/*
		if(slot_s_store)
			if(!H.wear_suit && (slot_wear_suit in mob_equip))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>You need a suit before you can attach this [name].</span>")
				return 0
			if(!H.wear_suit.allowed)
				if(!disable_warning)
					to_chat(usr, "<span class='warning'>You somehow have a suit with no defined allowed items for suit storage, stop that.</span>")
				return 0
			if( !(istype(src, /obj/item/device/pda) || istype(src, /obj/item/pen) || is_type_in_list(src, H.wear_suit.allowed)) )
				return 0
		*/
		if(slot_handcuffed)
			if(!istype(src, /obj/item/handcuffs))
				return 0
		if(slot_in_backpack) //used entirely for equipping spawned mobs or at round start
			var/allow = 0
			if(H.back && istype(H.back, /obj/item/storage/backpack))
				var/obj/item/storage/backpack/B = H.back
				if(B.can_be_inserted(src,M,1))
					allow = 1
			if(!allow)
				return 0
	return 1

/obj/item/proc/mob_can_unequip(mob/M, slot, disable_warning = 0)
	if(!slot) return 0
	if(!M) return 0

	if(!canremove)
		return 0
	if(!M.slot_is_accessible(slot, src, disable_warning? null : M))
		return 0
	return 1

/obj/item/proc/verb_pickup()
	set src in oview(1)
	set category = "Object"
	set name = "Pick up"

	if(!(usr)) //BS12 EDIT
		return
	if(usr.incapacitated(INCAPACITATION_STUNNED) || usr.incapacitated(INCAPACITATION_KNOCKOUT) || usr.stat || usr.restrained() || !Adjacent(usr))//!usr.canmove
		return //If they're stunned, or knocked out, then they can't pick shit up. But if they're just lying down they can.
	if((!istype(usr, /mob/living/carbon)) || (istype(usr, /mob/living/carbon/brain)))//Is humanoid, and is not a brain
		to_chat(usr, "<span class='warning'>You can't pick things up!</span>")
		return
	if( usr.stat || usr.restrained() )//Is not asleep/dead and is not restrained
		to_chat(usr, "<span class='warning'>You can't pick things up!</span>")
		return
	if(src.anchored) //Object isn't anchored
		to_chat(usr, "<span class='warning'>You can't pick that up!</span>")
		return
	if(!usr.hand && usr.r_hand) //Right hand is not full
		to_chat(usr, "<span class='warning'>Your right hand is full.</span>")
		return
	if(usr.hand && usr.l_hand) //Left hand is not full
		to_chat(usr, "<span class='warning'>Your left hand is full.</span>")
		return
	if(!istype(src.loc, /turf)) //Object is on a turf
		to_chat(usr, "<span class='warning'>You can't pick that up!</span>")
		return
	//All checks are done, time to pick it up!
	usr.UnarmedAttack(src)
	return


//This proc is executed when someone clicks the on-screen UI button. To make the UI button show, set the 'icon_action_button' to the icon_state of the image of the button in screen1_action.dmi
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, laying, item is on the mob.
/obj/item/proc/ui_action_click()
	attack_self(usr)

//RETURN VALUES
//handle_shield should return a positive value to indicate that the attack is blocked and should be prevented.
//If a negative value is returned, it should be treated as a special return value for bullet_act() and handled appropriately.
//For non-projectile attacks this usually means the attack is blocked.
//Otherwise should return 0 to indicate that the attack is not affected in any way.
/obj/item/proc/handle_shield(mob/living/user, var/damage, atom/damage_source = null, mob/attacker = null, var/def_zone = null, var/attack_text = "the attack")
	return 0

/obj/item/proc/get_loc_turf()
	var/atom/L = loc
	while(L && !istype(L, /turf/))
		L = L.loc
	return loc

/obj/item/proc/eyestab(mob/living/carbon/M as mob, mob/living/carbon/user as mob)

	var/mob/living/carbon/human/H = M
	if(istype(H))
		for(var/obj/item/protection in list(H.head, H.wear_mask, H.glasses))
			if(protection && (protection.body_parts_covered & EYES))
				// you can't stab someone in the eyes wearing a mask!
				to_chat(user, "<span class='warning'>You're going to need to remove the eye covering first.</span>")
				return

	if(!M.has_eyes())
		to_chat(user, "<span class='warning'>You cannot locate any eyes on [M]!</span>")
		return

	admin_attack_log(user, M, "Attacked using \a [src]", "Was attacked with \a [src]", "used \a [src] to attack")

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(M)

	src.add_fingerprint(user)
	//if((CLUMSY in user.mutations) && prob(50))
	//	M = user
		/*
		to_chat(M, "<span class='warning'>You stab yourself in the eye.</span>")
		M.sdisabilities |= BLIND
		M.weakened += 4
		M.adjustBruteLoss(10)
		*/

	if(istype(H))

		var/obj/item/organ/internal/eyes/eyes = H.internal_organs_by_name[BP_EYES]

		if(H != user)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("<span class='danger'>[M] has been stabbed in the eye with [src] by [user].</span>", 1)
			to_chat(M, "<span class='danger'>[user] stabs you in the eye with [src]!</span>")
			to_chat(user, "<span class='danger'>You stab [M] in the eye with [src]!</span>")
		else
			user.visible_message( \
				"<span class='danger'>[user] has stabbed themself with [src]!</span>", \
				"<span class='danger'>You stab yourself in the eyes with [src]!</span>" \
			)

		eyes.damage += rand(3,4)
		if(eyes.damage >= eyes.min_bruised_damage)
			if(M.stat != 2)
				if(eyes.robotic < ORGAN_ROBOT) //robot eyes bleeding might be a bit silly
					to_chat(M, "<span class='danger'>Your eyes start to bleed profusely!</span>")
			if(prob(50))
				if(M.stat != 2)
					to_chat(M, "<span class='warning'>You drop what you're holding and clutch at your eyes!</span>")
					M.drop_item()
				M.eye_blurry += 10
				M.Paralyse(1)
				M.Weaken(4)
			if (eyes.damage >= eyes.min_broken_damage)
				if(M.stat != 2)
					to_chat(M, "<span class='warning'>You go blind!</span>")

		var/obj/item/organ/external/affecting = H.get_organ(eyes.parent_organ)
		affecting.take_damage(7)
	else
		M.take_organ_damage(7)
	M.eye_blurry += rand(3,4)
	return

/obj/item/clean_blood()
	. = ..()
	if(blood_overlay)
		overlays.Remove(blood_overlay)
	if(istype(src, /obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = src
		G.transfer_blood = 0

/obj/item/reveal_blood()
	if(was_bloodied && !fluorescent)
		fluorescent = 1
		blood_color = COLOR_LUMINOL
		blood_overlay.color = COLOR_LUMINOL
		update_icon()

/obj/item/add_blood(mob/living/carbon/human/M as mob)
	if (!..())
		return 0

	if(istype(src, /obj/item/melee/energy))
		return

	//if we haven't made our blood_overlay already
	if( !blood_overlay )
		generate_blood_overlay()

	//apply the blood-splatter overlay if it isn't already in there
	if(!blood_DNA.len)
		blood_overlay.color = blood_color
		overlays += blood_overlay

	//if this blood isn't already in the list, add it
	if(istype(M))
		if(blood_DNA[M.dna.unique_enzymes])
			return 0 //already bloodied with this blood. Cannot add more.
		blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	return 1 //we applied blood to the item

/obj/item/proc/generate_blood_overlay()
	if(blood_overlay)
		return

	var/icon/I = new /icon(icon, icon_state)
	I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD) //fills the icon_state with white (except where it's transparent)
	I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY) //adds blood and the remaining white areas become transparant

	//not sure if this is worth it. It attaches the blood_overlay to every item of the same type if they don't have one already made.
	for(var/obj/item/A in world)
		if(A.type == type && !A.blood_overlay)
			A.blood_overlay = image(I)

/obj/item/proc/showoff(mob/user)
	for (var/mob/M in view(user))
		M.show_message("[user] holds up [src]. <a HREF=?src=\ref[M];lookitem=\ref[src]>Take a closer look.</a>",1)

/mob/living/carbon/verb/showoff()
	set name = "Show Held Item"
	set category = "Object"

	var/obj/item/I = get_active_hand()
	if(I && I.simulated)
		I.showoff(src)

/*
For zooming with scope or binoculars. This is called from
modules/mob/mob_movement.dm if you move you will be zoomed out
modules/mob/living/carbon/human/life.dm if you die, you will be zoomed out.
*/
//Looking through a scope or binoculars should /not/ improve your periphereal vision. Still, increase viewsize a tiny bit so that sniping isn't as restricted to NSEW
/obj/item/proc/zoom(mob/user, var/tileoffset = 14) //tileoffset is client view offset in the direction the user is facing. viewsize is how far out this thing zooms. 7 is normal view
	if(!user.client)
		return

	var/devicename
	if(zoomdevicename)
		devicename = zoomdevicename
	else
		devicename = src.name

	var/cannotzoom

	var/mob/living/carbon/human/H = user
	if(user.incapacitated(INCAPACITATION_DISABLED))
		to_chat(user, "<span class='warning'>You are unable to focus through the [devicename].</span>")
		cannotzoom = 1
	else if(!zoom && istype(H) && H.equipment_tint_total >= TINT_MODERATE)
		to_chat(user, "<span class='warning'>Your visor gets in the way of looking through the [devicename].</span>")
		cannotzoom = 1
	else if(!zoom && usr.get_active_hand() != src)
		to_chat(user, "<span class='warning'>You are too distracted to look through the [devicename], perhaps if it was in your active hand this might work better.</span>")
		cannotzoom = 1

	if(!zoom && !cannotzoom)
		//if(user.hud_used.hud_shown)
		//	user.toggle_zoom_hud()	// If the user has already limited their HUD this avoids them having a HUD when they zoom in
		zoom = 1

		var/tilesize = 32
		var/viewoffset = tilesize * tileoffset

		switch(user.dir)
			if (NORTH)
				user.client.pixel_x = 0
				user.client.pixel_y = viewoffset
			if (SOUTH)
				user.client.pixel_x = 0
				user.client.pixel_y = -viewoffset
			if (EAST)
				user.client.pixel_x = viewoffset
				user.client.pixel_y = 0
			if (WEST)
				user.client.pixel_x = -viewoffset
				user.client.pixel_y = 0

		user.visible_message("\The [user] peers through the [zoomdevicename ? "[zoomdevicename] of [src]" : "[src]"].")
		if(ishuman(user))
			H.hide_cone()
		if(!user.zoomed)
			user.zoomed = TRUE

	else
		if(user.zoomed)
			user.zoomed = FALSE
			user.set_face_dir(FALSE)//Reset our facing direction.
		//if(!user.hud_used.hud_shown)
		//	user.toggle_zoom_hud()
		zoom = 0

		user.client.pixel_x = 0
		user.client.pixel_y = 0

		if(!cannotzoom)
			user.visible_message("[zoomdevicename ? "\The [user] looks up from [src]" : "\The [user] lowers [src]"].")
		if(ishuman(user))
			H.show_cone()

	return

/obj/item/proc/pwr_drain()
	return 0 // Process Kill

/obj/item/proc/use_spritesheet(var/bodytype, var/slot, var/icon_state)
	if(!sprite_sheets || !sprite_sheets[bodytype])
		return 0
	if(slot == slot_r_hand_str || slot == slot_l_hand_str)
		return 0

	if(icon_state in icon_states(sprite_sheets[bodytype]))
		return 1

	return (slot != slot_wear_suit_str && slot != slot_head_str)

/obj/item/proc/get_icon_state(mob/user_mob, slot)
	var/mob_state
	if(item_state_slots && item_state_slots[slot])
		mob_state = item_state_slots[slot]
	else if (item_state)
		mob_state = item_state
	else
		mob_state = icon_state
	return mob_state

/obj/item/proc/dir_shift(var/icon/given_icon, var/dir_given, var/x = 0, var/y = 0)
	var/icon/I = new(given_icon, dir = dir_given)
	I.Shift(EAST, x)
	I.Shift(NORTH, y)
	given_icon.Insert(I, dir = dir_given)
	return given_icon

/obj/item/proc/get_mob_overlay(mob/user_mob, slot)
	var/bodytype = "Default"
	var/mob/living/carbon/human/user_human
	if(ishuman(user_mob))
		user_human = user_mob
		bodytype = user_human.species.get_bodytype(user_human)

	var/mob_state = get_icon_state(user_mob, slot)

	var/mob_icon
	var/spritesheet = FALSE
	if(icon_override)
		mob_icon = icon_override
		if(slot == 	slot_l_hand_str)
			mob_state = "[mob_state]_l"
		if(slot == 	slot_r_hand_str)
			mob_state = "[mob_state]_r"
	else if(use_spritesheet(bodytype, slot, mob_state))
		if(slot == slot_l_ear)
			mob_state = "[mob_state]_l"
		if(slot == slot_r_ear)
			mob_state = "[mob_state]_r"
		spritesheet = TRUE
		mob_icon = sprite_sheets[bodytype]
	else if(item_icons && item_icons[slot])
		mob_icon = item_icons[slot]
	else
		mob_icon = default_onmob_icons[slot]
	var/image/ret_overlay = overlay_image(mob_icon,mob_state,color)//,RESET_COLOR)
	/*if(slot == slot_r_ear_str)
		var/matrix/M = matrix(transform)
		M.Scale(-1,1)
		M.Translate(-1,0)
		ret_overlay.transform = M
		switch(user_human.dir)
			if(WEST)	ret_overlay.dir = NORTH
			if(EAST)	ret_overlay.dir = WEST*/
	if(user_human && user_human.species && user_human.species.equip_adjust.len && !spritesheet)
		var/list/equip_adjusts = user_human.species.equip_adjust
		if(equip_adjusts[slot])
			var/image_key = "[user_human.species] [mob_icon] [mob_state] [color]"
			ret_overlay = user_human.species.equip_overlays[image_key]
			if(!ret_overlay)
				var/icon/final_I = new(mob_icon, icon_state = mob_state)
				var/list/shifts = equip_adjusts[slot]
				if(shifts && shifts.len)
					var/shift_facing
					for(shift_facing in shifts)
						var/list/facing_list = shifts[shift_facing]
						final_I = dir_shift(final_I, text2dir(shift_facing), facing_list["x"], facing_list["y"])
				ret_overlay = overlay_image(final_I, color)//, flags = RESET_COLOR)

				user_human.species.equip_overlays[image_key] = ret_overlay

	return ret_overlay

/obj/item/proc/get_examine_line()
	if(blood_DNA)
		. = "<span class='warning'>\icon[src] [gender==PLURAL?"some":"a"] [(blood_color != SYNTH_BLOOD_COLOUR) ? "blood" : "oil"]-stained [src]</span>"
	else
		. = "\icon[src] \a [src]"

//Kicking an item
/obj/item/kick_act(var/mob/living/user)
	if(!..())
		return
	var/turf/target = get_turf(src.loc)
	var/range = throw_range
	var/throw_dir = get_dir(user, src)
	for(var/i = 1; i < range; i++)
		var/turf/new_turf = get_step(target, throw_dir)
		target = new_turf
		if(new_turf.density)
			break
	throw_at(target, rand(1,3), throw_speed)
	user.visible_message("[user] kicks \the [src.name].")


/obj/item/throw_impact(atom/hit_atom)
	..()
	if(drop_sound)
		playsound(src, drop_sound, 50, 0)
	//if(LAZYLEN(worldicons))
	//	originalstate = icon_state
	//	icon_state = safepick(worldicons)


/obj/item/proc/grab_sound(mob/user)
	if(grab_sound)
		playsound(user, grab_sound, 50, FALSE)
		/*
		if(grab_sound_is_loud)
			user.visible_message("<span class='danger'><i>[user] grabs a weapon!</i></span>")
		*/



//This is for the object breaking and repair system. These procs are top level and individual items below it can have their methods of being repaired.
/obj/item/proc/can_be_repaired()
	return FALSE

/obj/item/proc/repair_item()
	return