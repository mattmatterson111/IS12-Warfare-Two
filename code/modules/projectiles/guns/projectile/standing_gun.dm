/obj/item/gun/proc/is_standing_mounted(mob/user)
	return standing_mount && standing_mount.buckled_mob == user && loc == user

/obj/item/gun/proc/can_pick_up_big(mob/user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/external/left_hand = H.organs_by_name[BP_L_HAND]
	var/obj/item/organ/external/right_hand = H.organs_by_name[BP_R_HAND]
	if(!left_hand || !left_hand.is_usable() || !right_hand || !right_hand.is_usable())
		to_chat(user, "<span class='warning'>You need both usable hands to handle [src].</span>")
		return FALSE
	if(H.l_hand || H.r_hand)
		to_chat(user, "<span class='warning'>You need both hands empty to handle [src].</span>")
		return FALSE
	return TRUE

/obj/item/gun/mob_can_equip(mob/user, slot, disable_warning = 0, force = 0)
	if(big && (slot == slot_l_hand || slot == slot_r_hand))
		if(slot == slot_l_hand)
			return FALSE
		if(!can_pick_up_big(user) && user.r_hand != src)
			return FALSE
	return ..()

/obj/item/gun/attempt_wield(mob/user)
	if(big)
		return
	return ..()

/obj/item/gun/unwield(mob/user, hidden = FALSE)
	if(big && !hidden)
		return
	return ..()

/obj/item/gun/proc/standing_mount_check(mob/user)
	if(!requires_standing_mount || is_standing_mounted(user))
		return TRUE

	to_chat(user, "<span class='danger'>[src] must be mounted before it can fire.</span>")
	return FALSE

/obj/item/gun/proc/standing_fire_delay()
	return is_standing_mounted(ismob(loc) ? loc : null) ? 0 : unmounted_fire_delay

/obj/structure/standing_gun
	name = "emplacement"
	desc = "A fixed weapon."
	icon = 'icons/obj/weapons/imported_guns/cvs_emplacement.dmi'
	icon_state = "emplacement4_gun"
	var/base_state = "emplacement4_"
	anchored = TRUE
	density = TRUE
	can_buckle = TRUE
	buckle_dir = 0
	var/weapon_type = /obj/item/gun
	var/obj/item/gun/weapon
	var/allow_weapon_removal = FALSE
	var/can_pack_up = TRUE
	var/mount_pixel_x = 0
	var/mount_pixel_y = 0
	var/packing = FALSE

/obj/structure/standing_gun/proc/get_mount_pixel_shift()
	return

/obj/structure/standing_gun/Initialize(mapload, obj/item/gun/weapon_to_mount = null)
	. = ..()
	for(var/obj/structure/standing_gun/other in loc)
		if(other != src)
			return INITIALIZE_HINT_QDEL
	if(weapon_to_mount)
		weapon = weapon_to_mount
	else
		weapon = new weapon_type(src)
	weapon.forceMove(src)
	weapon.standing_mount = src
	update_icon()

/obj/structure/standing_gun/update_icon()
	icon_state = weapon ? "[base_state]gun" : base_state

/obj/structure/standing_gun/attackby(obj/item/W, mob/living/user)
	if(!allow_weapon_removal || weapon || buckled_mob || packing || !istype(W, weapon_type))
		return ..()
	if(!CanPhysicallyInteract(user))
		return
	if(istype(W, /obj/item/gun))
		var/obj/item/gun/G = W
		if(G.big && !G.can_pick_up_big(user))
			return
	user.remove_from_mob(W)
	weapon = W
	weapon.forceMove(src)
	weapon.standing_mount = src
	update_icon()

/obj/structure/standing_gun/Destroy()
	if(buckled_mob)
		unbuckle_mob()
	if(weapon)
		weapon.standing_mount = null
		weapon.forceMove(get_turf(src))
	..()

/obj/structure/standing_gun/attack_hand(mob/living/user)
	if(buckled_mob == user)
		user_unbuckle_mob(user)
		return
	if(buckled_mob)
		to_chat(user, "<span class='warning'>Someone is already using [src].</span>")
		return
	mount_user(user)

/obj/structure/standing_gun/proc/remove_weapon(mob/living/user)
	if(!allow_weapon_removal || !weapon || buckled_mob || packing)
		return FALSE
	if(!CanPhysicallyInteract(user))
		return FALSE
	if(!user.put_in_hands(weapon))
		to_chat(user, "<span class='warning'>You need a free hand to remove [weapon].</span>")
		return FALSE
	weapon.standing_mount = null
	weapon.has_stand = FALSE
	weapon = null
	update_icon()
	return TRUE

/obj/structure/standing_gun/RightClick(mob/living/user)
	if(!CanPhysicallyInteract(user))
		return
	if(!can_pack_up)
		return
	if(buckled_mob && buckled_mob != user)
		return
	pack_up(user)

/mob/living/carbon/human/MouseDrop_T(atom/movable/O, mob/user)
	if(user == src && istype(O, /obj/structure/standing_gun))
		var/obj/structure/standing_gun/emplacement = O
		emplacement.remove_weapon(user)
		return
	return ..()

/obj/structure/standing_gun/proc/mount_user(mob/living/user)
	if(!user || buckled_mob || !weapon || packing)
		return FALSE
	if(!user.put_in_hands(weapon))
		to_chat(user, "<span class='warning'>You need a free hand to use [src].</span>")
		return FALSE
	var/turf/old_turf = get_turf(user)
	user.forceMove(src.loc)
	if(!user_buckle_mob(user, user))
		user.forceMove(old_turf)
		weapon.forceMove(src)
		return FALSE
	weapon.standing_mount = src
	if(!weapon.wielded)
		weapon.wield(user, TRUE)
	get_mount_pixel_shift()
	animate(user, pixel_x = user.default_pixel_x + mount_pixel_x, pixel_y = user.default_pixel_y + mount_pixel_y, time = 4, easing = LINEAR_EASING)
	return TRUE

/obj/structure/standing_gun/proc/weapon_dropped(obj/item/gun/dropped_weapon)
	if(dropped_weapon != weapon)
		return
	dismount_weapon()
	if(buckled_mob)
		user_unbuckle_mob(buckled_mob)

/obj/structure/standing_gun/proc/dismount_weapon()
	if(!weapon)
		return
	if(weapon.loc != src)
		weapon.forceMove(src)
	weapon.standing_mount = src

/obj/structure/standing_gun/unbuckle_mob()
	var/mob/living/old_occupant = buckled_mob
	if(old_occupant && weapon && weapon.wielded)
		weapon.unwield(old_occupant, TRUE)
	. = ..()
	if(old_occupant)
		animate(old_occupant, pixel_x = old_occupant.default_pixel_x, pixel_y = old_occupant.default_pixel_y, time = 4, easing = LINEAR_EASING)
		dismount_weapon()

/obj/structure/standing_gun/proc/pack_up(mob/living/user)
	if(packing || !can_pack_up || buckled_mob)
		return
	packing = TRUE
	if(user && !do_after(user, 30, src))
		packing = FALSE
		return
	if(buckled_mob)
		packing = FALSE
		return
	if(user && weapon && weapon.wielded)
		weapon.unwield(user, TRUE)
	if(weapon)
		var/obj/item/gun/packed_weapon = weapon
		weapon = null
		packed_weapon.standing_mount = null
		packed_weapon.has_stand = TRUE
		if(!user || !user.put_in_hands(packed_weapon))
			packed_weapon.forceMove(get_turf(src))
	qdel(src)

/obj/item/gun/projectile/automatic/mg08
	name = "LMG Harbinger"
	desc = "Named for the death it brings."
	icon_state = "hmg"
	item_state = "hmg"
	str_requirement = 18
	w_class = ITEM_SIZE_HUGE
	force = 10
	slot_flags = SLOT_BACK|SLOT_S_STORE
	max_shells = 50
	caliber = "a556"
	origin_tech = list(TECH_COMBAT = 6, TECH_MATERIAL = 1, TECH_ILLEGAL = 2)
	ammo_type = /obj/item/ammo_casing/a556
	load_method = MAGAZINE
	magazine_type = /obj/item/ammo_magazine/box/a556/mg08
	allowed_magazines = /obj/item/ammo_magazine/box/a556/mg08
	one_hand_penalty = 50
	wielded_item_state = "hmg-wielded"
	fire_sound = 'sound/weapons/gunshot/harbinger.ogg'
	fire_volume = 55
	unload_sound = 'sound/weapons/guns/interact/ltrifle_magout.ogg'
	reload_sound = 'sound/weapons/guns/interact/ltrifle_magin.ogg'
	cock_sound = 'sound/weapons/guns/interact/ltrifle_cock.ogg'
	loaded_icon = "hmg"
	unwielded_loaded_icon = "hmg"
	wielded_loaded_icon = "hmg-wielded"
	unloaded_icon = "hmg-e"
	unwielded_unloaded_icon = "hmg-e"
	wielded_unloaded_icon = "hmg-wielded-e"
	fire_delay = 2
	burst = 1
	move_delay = 12
	automatic = 2
	firemodes = list()
	gun_type = GUN_LMG
	condition = 300
	big = FALSE
	has_stand = TRUE
	//requires_standing_mount = TRUE
	aimed_dispersion_mult = 0.9
	unmounted_accuracy_penalty = 2
	unmounted_fire_delay = 1.5
	var/standing_gun_type = /obj/structure/standing_gun/harbinger

/obj/item/gun/projectile/automatic/mg08/attack_self(mob/user)
	. = ..()
	if(length(GLOB.payloads))
		return
	if(standing_mount)
		standing_mount.pack_up(user)
		return
	deploy_mg(user)

/obj/item/gun/projectile/automatic/mg08/special_check(mob/user)
	if(misfire)
		return 1
	return ..()

/obj/item/gun/projectile/automatic/mg08/perforator
	name = "HMG Perforator"
	icon = 'icons/obj/weapons/imported_guns/cvs_big.dmi'
	condition_icon = 'icons/obj/gun32x64.dmi'
	icon_state = "hmg_alt_e"
	item_state = "hmg_alt"
	wielded_item_state = "hmg_alt"
	loaded_icon = "hmg_alt"
	fire_sound = "dp47_fire"
	unwielded_loaded_icon = "hmg_alt"
	wielded_loaded_icon = "hmg_alt"
	unloaded_icon = "hmg_alt_e"
	unwielded_unloaded_icon = "hmg_alt_e"
	wielded_unloaded_icon = "hmg_alt_e"
	big = TRUE
	damage_multiplier = 1.5
	fire_delay = 4.5
	requires_standing_mount = FALSE
	unmounted_fire_delay = 3
	standing_gun_type = /obj/structure/standing_gun/harbinger/perforator
	magazine_type = /obj/item/ammo_magazine/box/a556/mg08/perforator
	allowed_magazines = /obj/item/ammo_magazine/box/a556/mg08/perforator
	can_jam = FALSE
	gun_type = GUN_BOLTIE // just so soldiers can fire it properly
	aimed_dispersion_mult = 0.85

/obj/item/gun/projectile/automatic/mg08/proc/deploy_mg(mob/living/user)
	if(user.doing_something || standing_mount || !has_stand)
		if(!has_stand)
			to_chat(user, "<span class='warning'>The stand is still attached to the emplacement.</span>")
		return
	if(locate(/obj/structure/standing_gun) in get_turf(user))
		to_chat(user, "<span class='warning'>There is already a gun emplacement here.</span>")
		return
	user.visible_message("[user] starts to deploy the [src]")
	user.doing_something = TRUE
	if(!do_after(user, 30))
		user.doing_something = FALSE
		return
	user.doing_something = FALSE
	if(big && wielded)
		unwield(user, TRUE)
	user.remove_from_mob(src)
	var/obj/structure/standing_gun/emplacement = new standing_gun_type(get_turf(user), src)
	emplacement.dir = user.dir
	if(!emplacement.mount_user(user))
		qdel(emplacement)
		return
	playsound(src, 'sound/weapons/mortar_deploy.ogg', 100, FALSE)
	update_icon()

/obj/structure/standing_gun/harbinger
	name = "Deployed LMG Harbinger"
	icon_state = "emplacement4_gun"
	base_state = "emplacement4_"
	weapon_type = /obj/item/gun/projectile/automatic/mg08
	allow_weapon_removal = FALSE

/obj/structure/standing_gun/harbinger/get_mount_pixel_shift()
	mount_pixel_x = 0
	mount_pixel_y = 0
	switch(dir)
		if(EAST)
			mount_pixel_x = -5
		if(WEST)
			mount_pixel_x = 5
		if(NORTH)
			mount_pixel_y = -5
		if(SOUTH)
			mount_pixel_y = 5

/obj/structure/standing_gun/harbinger/perforator
	name = "Deployed HMG Perforator"
	desc = "Maybe the lieutenant might have a spare mag.."
	weapon_type = /obj/item/gun/projectile/automatic/mg08/perforator
	allow_weapon_removal = TRUE
	can_pack_up = FALSE
