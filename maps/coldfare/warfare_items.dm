/obj/item/clothing/head/helmet/hard_had
	name = "Mining Helmet"
	desc = "Protects you head from rocks and other hazards."
	icon_state = "hardhat"


/obj/item/clothing/head/helmet/sentryhelm
	name = "Sentry Helmet"
	desc = "Used for taking blows to the noggin without getting hurt."
	armor = list(melee = 75, bullet = 75, laser = 55, energy = 40, bomb = 50, bio = 10, rad = 0)//proteck ya neck
	str_requirement = 18


/obj/item/clothing/suit/armor/sentry
	name = "Sentry Armor"
	desc = "Protects you very well from getting smacked, and decently well from getting shot."
	armor = list(melee = 75, bullet = 75, laser = 55, energy = 40, bomb = 50, bio = 10, rad = 0)//Beefy boys.
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	str_requirement = 18
	footstep = 1

/obj/item/clothing/suit/armor/sentry/handle_movement(var/turf/walking, var/running)
	if(footstep >= 1)
		footstep = 0
		playsound(get_turf(src), "sentry_step", 45, 0) // this will get annoying very fast.
	else
		footstep++


/obj/item/clothing/suit/armor/sentry/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 4


/obj/item/clothing/suit/child_coat
	name = "child coat"
	desc = "Small enough for a child to wear it."
	icon_state = "child_redcoat"
	can_be_worn_by_child = TRUE
	child_exclusive = TRUE


/obj/item/clothing/suit/child_coat/red
	icon_state = "redcoatnew_child"
	warfare_team = RED_TEAM

/obj/item/clothing/suit/child_coat/blue
	icon_state = "bluecoatnew_child"
	warfare_team = BLUE_TEAM

/obj/item/clothing/suit/armor/sniper
	name = "black cloak"
	desc = "Boom! Headshot!"
	icon_state = "sniper"
	item_state = "sniper"
	worldicons = list("sniperworld1","sniperworld2")
	sprite_sheets = list(SPECIES_CHILD = 'icons/mob/species/child/suit.dmi')
	var/obj/item/clothing/head/sniper/hood = /obj/item/clothing/head/sniper
	var/hood_on = FALSE

/obj/item/clothing/suit/armor/sniper/Initialize()
	. = ..()
	hood = new hood(src)

/obj/item/clothing/suit/armor/sniper/RightClick(mob/user)
	. = ..()
	if(CanPhysicallyInteract(user))
		toggle_hood(user)

/obj/item/clothing/head/sniper
	name = "hood"
	icon_state = "hood"
	item_state = "hood"
	flags_inv = BLOCKHAIR|HIDEEARS
	canremove = FALSE

/obj/item/clothing/suit/armor/sniper/proc/put_on_hood(mob/user)
	if(hood.loc == src)
		//icon_state = "sniper_hood"
		user.equip_to_slot_or_del(hood, slot_head)
		update_clothing_icon()

/obj/item/clothing/suit/armor/sniper/proc/remove_hood(mob/user)
	if(hood.loc != src)
		//icon_state = "sniper"
		user.remove_from_mob(hood)
		hood.forceMove(src)
		update_clothing_icon()


/obj/item/clothing/suit/armor/sniper/proc/toggle_hood(mob/user)
	if(isworld(loc))
		return
	if(!hood)
		hood = new hood(src) // failsafe
		hood.forceMove(src)
	if(!user.get_equipped_item(slot_head) == hood)
		if(!hood.mob_can_equip(user, slot_head, 1))
			return
	if(!user.isEquipped(hood))
		put_on_hood(user)
	else
		remove_hood(user)
	playsound(get_turf(src), "cloth_step", 75, 1)

/obj/item/clothing/suit/armor/sniper/unequipped(mob/user)
	//icon_state = "sniper" // ugh..
	if(user.isEquipped(hood))
		remove_hood(user)

/obj/item/clothing/head/helmet/redhelmet/sniper
	icon_state = "redsniperhelmet"
	item_state = "redsniperhelmet"

/obj/item/clothing/suit/armor/bluecoat/sniper
	icon_state = "bluecoat_sniper"
	item_state = "bluecoat_sniper"

/obj/item/clothing/head/helmet/bluehelmet/sniper
	icon_state = "bluesniperhelmet"
	item_state = "bluesniperhelmet"


/obj/item/clothing/head/helmet/redhelmet/fire
	icon_state = "redfirehelmet"

/obj/item/clothing/head/helmet/bluehelmet/fire
	icon_state = "bluefirehelmet"


/obj/item/clothing/under/child_jumpsuit/warfare
	name = "scavengers's clothing"
	desc = "A proper uniform worn by child scavengers."
	icon_state = "urchin"
	child_exclusive = TRUE
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS//So they don't freeze to death with their clothes on.
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/under/child_jumpsuit/warfare/red
	warfare_team = RED_TEAM
	icon_state = "redgrunt_child"
	worldicons = list("reduniworld1","reduniworld2","reduniworld3")
	child_exclusive = TRUE
	canremove = FALSE

/obj/item/clothing/under/child_jumpsuit/warfare/blue
	warfare_team = BLUE_TEAM
	icon_state = "bluegrunt_child"
	worldicons = list("blueuniworld1","blueuniworld2","blueuniworld3")
	child_exclusive = TRUE
	canremove = FALSE

//Red shit
/obj/item/clothing/suit/armor/redcoat
	name = "Red Team's jacket"
	desc = "The proud jacket of the Red Baron!"
	icon_state = "redcoatnew"
	warfare_team = RED_TEAM
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	worldicons = list("redcoatworld1","redcoatworld2","redcoatworld3")
	sprite_sheets = list(SPECIES_CHILD = 'icons/mob/species/child/suit.dmi')

	item_state_slots = list(
		slot_l_hand_str = "cloth",
		slot_r_hand_str = "cloth",
	)

/obj/item/clothing/suit/armor/redcoat/New()
	..()
	name = "[RED_TEAM]'s jacket"
	desc = "The proud jacket of the [RED_TEAM]."

/obj/item/clothing/suit/armor/redcoat/sl
	icon_state = "redsl"
	item_state = "redsl"

/obj/item/clothing/suit/armor/sentry/red
	name = "Red Sentry Armor"
	icon_state = "sentry_r"
	worldicons = "sentry_r_world"
	warfare_team = RED_TEAM
	species_restricted = (SPECIES_CHILD)

/obj/item/clothing/head/helmet/sentryhelm/red
	name = "Red Sentry Helmet"
	icon_state = "sentry_r"
	worldicons = "sentry_r_world"
	item_state = "sentry_r"
	warfare_team = RED_TEAM

/obj/item/clothing/under/red_uniform
	name = "Red's uniform"
	desc = "It's not the best. But it's not the worst."
	icon_state = "redgrunt"
	//worn_state = "redgrunt_m"
	warfare_team = RED_TEAM
	can_be_worn_by_child = FALSE
	worldicons = list("reduniworld1","reduniworld2","reduniworld3")
	//sprite_sheets = list(SPECIES_CHILD = 'icons/mob/species/child/mask.dmi')
	canremove = FALSE

/obj/item/clothing/under/red_uniform/equipped(mob/user)
	var/mob/living/carbon/human/weirdo = user
	if(weirdo.gender == MALE)
		worn_state = "[initial(icon_state)]_m"
	else
		worn_state = "[initial(icon_state)]_f"
	if(weirdo.isChild())
		worn_state = "[initial(icon_state)]_child"
	item_state_slots[slot_w_uniform_str] = worn_state
	update_clothing_icon()
	update_icon()
	. = ..()

/obj/item/clothing/suit/armor/redcoat/leader
	icon_state = "captaincoat"
	//item_state = "captaincoat"
	worldicons = list("captaincoatworld1","captaincoatworld2","captaincoatworld3")
	sprite_sheets = list(SPECIES_CHILD = 'icons/mob/species/child/suit.dmi')

/obj/item/clothing/suit/armor/redcoat/medic
	icon_state = "redcoat_medic"
	item_state = "redcoat_medic"

/obj/item/clothing/head/warfare_officer/redofficer
	name = "Red Officer\'s Cap"
	desc = "Fit for an officer of just your ranking. And nothing more."
	icon_state = "redcaptain"
	item_state = "redcaptain"
	worldicons = list("captainhatworld1","captainhatworld2")
	warfare_team = RED_TEAM

/obj/item/clothing/head/helmet/redhelmet
	name = "Red's Helmet"
	desc = "Sometimes protects your head from bullets and blows."
	icon_state = "redhelmet"
	warfare_team = RED_TEAM
	worldicons = "redhelmet_world"
	can_be_damaged = TRUE
	damaged_worldicons = "redhelmet_world_dam"

/obj/item/clothing/head/helmet/redhelmet/medic
	icon_state = "redhelmet_medic"
	flags_inv = HIDEEARS|BLOCKHAIR

/obj/item/clothing/head/helmet/redhelmet/leader
	icon_state = "bluehelmet_leader"

/obj/item/clothing/mask/gas/sniper
	icon_state = "sniper"
	item_state = "sniper"
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	body_parts_covered = FACE|EYES
	helmet_vision = TRUE
	worldicons = "sniperworld"

/obj/item/clothing/mask/gas/sniper/penal1
	icon_state = "penal1"
	item_state = "penal1"
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	body_parts_covered = FACE|EYES
	helmet_vision = TRUE
	worldicons = "penal1_onworld"
	sprite_sheets = list(SPECIES_CHILD = 'icons/mob/species/child/mask.dmi')

/obj/item/clothing/mask/gas/sniper/penal2
	icon_state = "penal2"
	item_state = "penal2"
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	body_parts_covered = FACE|EYES
	helmet_vision = TRUE
	worldicons = "penal1_onworld"
	sprite_sheets = list(SPECIES_CHILD = 'icons/mob/species/child/mask.dmi')

/obj/item/clothing/mask/gas/sniper/penal3
	icon_state = "penal3"
	item_state = "penal3"
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	body_parts_covered = FACE|EYES
	helmet_vision = TRUE
	worldicons = "penal3_onworld"
	sprite_sheets = list(SPECIES_CHILD = 'icons/mob/species/child/mask.dmi')

/obj/item/clothing/mask/gas/blue
	icon_state = "bluemask"
	item_state = "bluemask"
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	body_parts_covered = FACE|EYES
	helmet_vision = TRUE
	worldicons = "bluemaskworld"


/obj/item/clothing/mask/gas/red
	icon_state = "redmask"
	item_state = "redmask"
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	body_parts_covered = FACE|EYES
	helmet_vision = TRUE
	worldicons = "redmaskworld"

//Nam shit
/obj/item/clothing/suit/armor/redcoat/nam
	icon_state = "redsuit"

/obj/item/clothing/suit/armor/redcoat/leader/nam
	icon_state = "redsuit_leader"

/obj/item/clothing/suit/armor/redcoat/medic/nam
	icon_state = "redsuit_medic"

/obj/item/clothing/head/helmet/redhelmet/nam
	desc = "Sometimes protects your head from bullets and blows."
	icon_state = "redhelmnam"

/obj/item/clothing/head/helmet/redhelmet/leader/nam
	icon_state = "redhelmnam_leader"

/obj/item/clothing/head/helmet/redhelmet/medic/nam
	icon_state = "redhelmnam_medic"

/obj/item/clothing/gloves/thick/swat/combat/nam
	icon_state = "namgloves"
	item_state = "namgloves"

/obj/item/clothing/gloves/thick/swat/combat/warfare
	icon_state = "redgloves"
	item_state = "redgloves"
	equipsound = 'sound/effects/wear_gloves.ogg'
	worldicons = "redglovesworld"
	sprite_sheets = list(SPECIES_CHILD = 'icons/mob/species/child/hands.dmi')

/obj/item/clothing/gloves/thick/swat/combat/warfare/red
	icon_state = "redgloves"
	item_state = "redgloves"
	warfare_team = RED_TEAM

//Blue shit
/obj/item/clothing/suit/armor/bluecoat
	name = "Blue Team's jacket"
	desc = "The proud jacket of the Bluecoats!"
	icon_state = "bluecoatnew"
	warfare_team = BLUE_TEAM
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	worldicons = list("bluecoatworld1","bluecoatworld2","bluecoatworld3")
	sprite_sheets = list(SPECIES_CHILD = 'icons/mob/species/child/suit.dmi')

	item_state_slots = list(
		slot_l_hand_str = "cloth",
		slot_r_hand_str = "cloth",
	)

/obj/item/clothing/suit/armor/bluecoat/New()
	..()
	name = "The [BLUE_TEAM]'s jacket"
	desc = "The proud jacket of the [BLUE_TEAM]."

/obj/item/clothing/suit/armor/bluecoat/sl
	item_state = "blue_prac"
	icon_state = "blue_prac"

/obj/item/clothing/head/warfare_officer/sl
	name = "Blue Seargeant\'s Cap"
	desc = "Fit for an officer of just your ranking. And nothing more."
	icon_state = "captain_hat"
	item_state = "captain_hat"
	warfare_team = BLUE_TEAM

/obj/item/clothing/suit/armor/sentry/blue
	warfare_team = BLUE_TEAM
	name = "Blue Sentry Armor"
	icon_state = "sentry_b"
	worldicons = "sentry_b_world"

/obj/item/clothing/head/helmet/sentryhelm/blue
	warfare_team = BLUE_TEAM
	name = "Blue Sentry Helmet"
	icon_state = "sentry_b"
	worldicons = "sentry_b_world"
	item_state = "sentry_b"

/obj/item/clothing/suit/armor/bluecoat/leader
	icon_state = "captaincoat"
	//item_state = "captaincoat"
	worldicons = list("captaincoatworld1","captaincoatworld2","captaincoatworld3")

	item_state_slots = list(
		slot_l_hand_str = "cloth",
		slot_r_hand_str = "cloth",
	)


/obj/item/clothing/suit/armor/bluecoat/medic
	icon_state = "bluecoat_medic"
	item_state = "bluecoat_medic"

//Uniform.
/obj/item/clothing/under/blue_uniform
	name = "Blue's uniform"
	desc = "It's not the best. But it's not the worst."
	icon_state = "bluegrunt"
	worn_state = "bluegrunt_m"
	warfare_team = BLUE_TEAM
	can_be_worn_by_child = FALSE
	worldicons = list("blueuniworld1","blueuniworld2","blueuniworld3")
	//sprite_sheets = list(SPECIES_CHILD = 'icons/mob/species/child/mask.dmi')
	canremove = FALSE

/obj/item/clothing/under/blue_uniform/equipped(mob/user) // This is stupid. But it works.
	. = ..()
	var/mob/living/carbon/human/weirdo = user
	if(weirdo.isChild())
		worn_state = "[initial(worn_state)]_child"
		update_clothing_icon()
		update_icon()
		return
	if(weirdo.gender == MALE)
		worn_state = "[initial(worn_state)]_m"
	else
		worn_state = "[initial(worn_state)]_f"
	update_clothing_icon()
	update_icon()



//Hats
/obj/item/clothing/head/warfare_officer/blueofficer
	name = "Blue Officer\'s Cap"
	desc = "Fit for an officer of just your ranking. And nothing more."
	icon_state = "redcaptain"
	item_state = "redcaptain"
	worldicons = list("captainhatworld1","captainhatworld2")
	warfare_team = BLUE_TEAM

//Helmets
/obj/item/clothing/head/helmet/redhelmet
	name = "Red's Helmet"
	desc = "Sometimes protects your head from bullets and blows."
	icon_state = "redhelmet"
	warfare_team = RED_TEAM
	worldicons = "redhelmet_world"
	can_be_damaged = TRUE
	damaged_worldicons = "redhelmet_world_dam"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand.dmi',
	)

/obj/item/clothing/head/helmet/bluehelmet
	name = "Blue's Helmet"
	desc = "Sometimes protects your head from bullets and blows."
	icon_state = "bluehelmet"
	warfare_team = BLUE_TEAM
	worldicons = "bluehelmet_world"
	can_be_damaged = TRUE
	damaged_worldicons = "bluehelmet_world_dam"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/onmob/items/lefthand.dmi',
		slot_r_hand_str = 'icons/mob/onmob/items/righthand.dmi',
	)

/obj/item/clothing/head/helmet/bluehelmet/medic
	icon_state = "bluehelmet_medic"

/obj/item/clothing/gloves/thick/swat/combat/warfare/blue
	icon_state = "redgloves"
	item_state = "redgloves"
	warfare_team = BLUE_TEAM

/obj/item/clothing/mask/gas
	icon_state = "gasmask"
	item_state = "gasask"
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHEADHAIR
	body_parts_covered = FACE|EYES
	helmet_vision = TRUE
	sprite_sheets = list(SPECIES_CHILD = 'icons/mob/species/child/mask.dmi')

	item_state_slots = list(
		slot_l_hand_str = "gasmask",
		slot_r_hand_str = "gasmask",
	)

/obj/item/clothing/head/helmet/bluehelmet/leader
	icon_state = "bluehelmet_leader"

/obj/item/card/id/dog_tag
	var/warfare_faction = null
	var/halfed
	icon_state = "dogtag"
	desc = "A metal dog tag. Functions like an ID."
	grab_sound = 'sound/effects/dogtag_handle.ogg'

/obj/item/card/id/dog_tag/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(warfare_faction == H.warfare_faction)
		return
	. = ..()

/obj/item/card/id/dog_tag/proc/split(mob/user)
	return FALSE
/*
	if(!warfare_faction || halfed)
		return
	var/obj/item/card/id/dog_tag/tag = DuplicateObject(src, 1, 1)
	icon_state = "[icon_state]_half"
	halfed = TRUE
	playsound(get_turf(src),'sound/effects/tag_snap.ogg', 70, 0)
	tag.icon_state = "halftag"
	tag.canremove = TRUE
	user.put_in_active_hand(tag)
*/

/obj/item/card/id/dog_tag/red
	warfare_faction = RED_TEAM
	icon_state = "tagred"

/obj/item/card/id/dog_tag/blue
	warfare_faction = BLUE_TEAM
	icon_state = "tagblue"

/obj/item/card/id/dog_tag/update_name()
	var/final_name = "[registered_name]'s Dog Tag"
	if(military_rank && military_rank.name_short)
		final_name = military_rank.name_short + " " + final_name
	if(assignment)
		final_name = final_name + " ([assignment])"
	SetName(final_name)


/obj/item/device/radio/headset/red_team
	name = "Red Headset"
	origin_tech = list(TECH_ILLEGAL = 3)
	syndie = 1
	ks1type = /obj/item/device/encryptionkey/red
	sprite_sheets = list(SPECIES_CHILD = 'icons/mob/species/child/ears.dmi')

/obj/item/device/radio/headset/red_team/Initialize()
	. = ..()
	set_frequency(RED_FREQ)

/obj/item/device/radio/headset/red_team/sl_alpha
	ks1type = /obj/item/device/encryptionkey/redsl_alpha

/obj/item/device/radio/headset/red_team/sl_bravo
	ks1type = /obj/item/device/encryptionkey/redsl_bravo

/obj/item/device/radio/headset/red_team/sl_charlie
	ks1type = /obj/item/device/encryptionkey/redsl_charlie

/obj/item/device/radio/headset/red_team/sl_delta
	ks1type = /obj/item/device/encryptionkey/redsl_delta

/obj/item/device/radio/headset/red_team/all
	ks1type = /obj/item/device/encryptionkey/red_all

/obj/item/device/radio/headset/red_team/alpha
	ks1type = /obj/item/device/encryptionkey/red_alpha

	Initialize()
		. = ..()
		set_frequency(RED_ALPHA)

/obj/item/device/radio/headset/red_team/bravo
	ks1type = /obj/item/device/encryptionkey/red_bravo

	Initialize()
		. = ..()
		set_frequency(RED_BRAVO)

/obj/item/device/radio/headset/red_team/charlie
	ks1type = /obj/item/device/encryptionkey/red_charlie

	Initialize()
		. = ..()
		set_frequency(RED_CHARLIE)

/obj/item/device/radio/headset/red_team/delta
	ks1type = /obj/item/device/encryptionkey/red_delta

	Initialize()
		. = ..()
		set_frequency(RED_DELTA)

/obj/item/device/radio/headset/blue_team
	name = "Blue Headset"
	origin_tech = list(TECH_ILLEGAL = 2)
	syndie = 1
	ks1type = /obj/item/device/encryptionkey/blue

/obj/item/device/radio/headset/blue_team/Initialize()
	. = ..()
	set_frequency(BLUE_FREQ)


/obj/item/device/radio/headset/blue_team/sl_alpha
	ks1type = /obj/item/device/encryptionkey/bluesl_alpha

/obj/item/device/radio/headset/blue_team/sl_bravo
	ks1type = /obj/item/device/encryptionkey/bluesl_bravo

/obj/item/device/radio/headset/blue_team/sl_charlie
	ks1type = /obj/item/device/encryptionkey/bluesl_charlie

/obj/item/device/radio/headset/blue_team/sl_delta
	ks1type = /obj/item/device/encryptionkey/bluesl_delta

/obj/item/device/radio/headset/blue_team/all
	ks1type = /obj/item/device/encryptionkey/blue_all

/obj/item/device/radio/headset/blue_team/alpha
	ks1type = /obj/item/device/encryptionkey/blue_alpha

	Initialize()
		. = ..()
		set_frequency(BLUE_ALPHA)

/obj/item/device/radio/headset/blue_team/bravo
	ks1type = /obj/item/device/encryptionkey/blue_bravo

	Initialize()
		. = ..()
		set_frequency(BLUE_BRAVO)

/obj/item/device/radio/headset/blue_team/charlie
	ks1type = /obj/item/device/encryptionkey/blue_charlie

	Initialize()
		. = ..()
		set_frequency(BLUE_CHARLIE)

/obj/item/device/radio/headset/blue_team/delta
	ks1type = /obj/item/device/encryptionkey/blue_delta

	Initialize()
		. = ..()
		set_frequency(BLUE_DELTA)


/obj/item/melee/trench_axe
	name = "trench axe"
	desc = "Used mainly for murdering those on the enemy side."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "trenchaxe"
	item_state = "trenchaxe"
	wielded_icon = "trenchaxe-w"
	slot_flags = SLOT_BELT|SLOT_BACK|SLOT_S_STORE
	force = 20
	block_chance = 20
	sharp = TRUE
	edge = TRUE
	hitsound = "slash_sound"
	drop_sound = 'sound/items/handle/axe_drop.ogg'
	equipsound = 'sound/items/equip/axe_equip.ogg'
	grab_sound = 'sound/items/handle/axe_grab.ogg'
	grab_sound_is_loud = TRUE


/obj/item/clothing/under/prac_under
	name = "practicioner undergarments"
	desc = "Warm."
	icon_state = "prac_under"
	item_state = "prac_under"
	canremove = FALSE

/obj/item/clothing/suit/prac_arpon
	name = "practioner robes"
	desc = "Fit for you."
	icon_state = "prac_robes"
	item_state = "prac_robes"
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	canremove = FALSE

/obj/item/clothing/suit/prac_arpon/handle_movement(var/turf/walking, var/running)
	if(footstep >= 1)
		footstep = 0
		playsound(get_turf(src), "cloth_step", 60, 0) // this will get annoying very fast.
	else
		footstep++

/obj/item/clothing/mask/gas/prac_mask
	name = "practioner mask"
	desc = "Keeps all that blood off your face."
	icon_state = "prac_mask"
	item_state = "prac_mask"
	item_flags = ITEM_FLAG_FLEXIBLEMATERIAL|ITEM_FLAG_AIRTIGHT|ITEM_FLAG_BLOCK_GAS_SMOKE_EFFECT
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	body_parts_covered = FACE|EYES|HEAD
	helmet_vision = FALSE
	canremove = FALSE

/obj/item/clothing/mask/gas/prac_mask/broken
	name = "broken mask"
	icon_state = "prac_mask_broken"
	item_state = "prac_mask_broken"

/obj/item/clothing/head/that/prac
	name = "beaked hat"
	icon_state = "dapper_hat"
	item_state = "dapper_hat"
	worldicons = "dapper_hat_world"

/obj/item/clothing/shoes/prac_boots
	name = "practioner footwraps"
	desc = "Squish."
	icon_state = "prac_boots"
	item_state = "prac_boots"
	canremove = FALSE

/obj/item/clothing/gloves/prac_gloves
	name = "practioner gloves"
	desc = "Now you can grope the dead without worrying about what you're contracting."
	icon_state = "prac_gloves"
	item_state = "prac_gloves"
	canremove = FALSE

/obj/item/clothing/head/prac_cap
	name = "practioner cap"
	desc = "Wouldn't want your hair to get messy now would we."
	icon_state = "prac_cap"
	item_state = "prac_cap"
	flags_inv = BLOCKHEADHAIR


/obj/item/clothing/accessory/red_outline
	icon_state = "red_outline"
	high_visibility = FALSE

/obj/item/clothing/accessory/blue_outline
	icon_state = "blue_outline"
	high_visibility = FALSE

/obj/item/clothing/accessory/armband/alpha
	icon_state = "alpha_patch"
	high_visibility = FALSE

/obj/item/clothing/accessory/armband/bravo
	icon_state = "bravo_patch"
	high_visibility = FALSE

/obj/item/clothing/accessory/armband/charlie
	icon_state = "charlie_patch"
	high_visibility = FALSE

/obj/item/clothing/accessory/medal/medical
	name = "medical patch"
	icon_state = "medic_patch"
	overlay_state = "medic_patch"
	high_visibility = FALSE

/obj/item/clothing/accessory/helm_patch
	slot = ACCESSORY_SLOT_HELM_C

/obj/item/clothing/accessory/helm_patch/medic
	icon_state = "medical_helmet_patch"
	overlay_state = "medical_helmet_patch"

/obj/item/clothing/accessory/helm_patch/leader
	icon_state = "leader_patch_helm"
	overlay_state = "leader_patch_helm"


/obj/item/storage/belt/warfare
	name = "ammo belt"
	desc = "Great for holding ammo! This one starts with smg ammo."
	icon_state = "warfare_belt"
	item_state = "warfare_belt"
	can_hold = list(
		/obj/item/ammo_magazine,
		)

	New()
		..()
		new /obj/item/ammo_magazine/mc9mmt/machinepistol(src)
		new /obj/item/ammo_magazine/mc9mmt/machinepistol(src)
		new /obj/item/ammo_magazine/mc9mmt/machinepistol(src)
		new /obj/item/ammo_magazine/mc9mmt/machinepistol(src)


/obj/item/storage/belt/autoshotty
	name = "ammo belt"
	desc = "Great for holding ammo! This one starts with Warcrime magazines."
	icon_state = "warfare_belt"
	item_state = "warfare_belt"
	can_hold = list(
		/obj/item/ammo_magazine,
		)
	New()
		..()
		new /obj/item/ammo_magazine/autoshotty(src)
		new /obj/item/ammo_magazine/autoshotty(src)
		new /obj/item/ammo_magazine/autoshotty(src)
		new /obj/item/ammo_magazine/autoshotty(src)
		new /obj/item/ammo_magazine/autoshotty(src)

/obj/item/storage/belt/armageddon
	name = "ammo belt"
	desc = "Great for holding ammo! This one starts with Armageddon magazines."
	icon_state = "warfare_belt"
	item_state = "warfare_belt"
	can_hold = list(
		/obj/item/ammo_magazine,
		)

	New()
		..()
		new /obj/item/ammo_magazine/a762/rsc(src)
		new /obj/item/ammo_magazine/a762/rsc(src)
		new /obj/item/ammo_magazine/a762/rsc(src)
		new /obj/item/ammo_magazine/a762/rsc(src)

/obj/item/storage/box/ifak
	name = "IFAK"
	desc = "An Individual First Aid Kit, used to keep you alive until a medic can patch you up properly."
	icon_state = "ifak"
	startswith = list(/obj/item/bandage_pack, /obj/item/tourniquet, /obj/item/reagent_containers/hypospray/autoinjector/morphine,/obj/item/reagent_containers/hypospray/autoinjector/warfare/trooper)
	w_class = ITEM_SIZE_SMALL
	worldicons = "ifakworld"
	max_storage_space = 8
	use_sound = "military_rustle_light"
	close_sound = "military_rustle_light_close"
	drop_sound = 'sound/effects/ifak_drop.ogg'
	cant_hold = list(/obj/item/storage/box/ifak)

/obj/item/storage/box/ifak/attack_hand(var/mob/living/carbon/human/user)
	if(!istype(user))
		..()
		return
	if((src != user.r_store) && (src != user.l_store) && (src != user.belt) && (src != user.get_inactive_hand()))
		..()//If it's not in any of these slots then just return normally.
		return
	open(user)//If it's in your pocket then open it.

/obj/item/storage/box/ifak/attack_self(mob/user)
	return


/obj/item/bandage_pack
	name = "Bandage Pack"
	desc = "Holds a bandage. One time use. You can't put the bandage back, don't try."
	icon = 'icons/obj/storage.dmi'
	icon_state = "bandage_pack1"
	w_class = ITEM_SIZE_SMALL
	var/used = FALSE

/obj/item/bandage_pack/attack_self(mob/user)
	. = ..()
	if(used)
		to_chat(user, "<span class='warning'>This one is used up already.</span>")
		return

	var/obj/item/stack/medical/bruise_pack/BP = new(get_turf(src))
	playsound(src, pick('sound/effects/bandage_unpack.ogg','sound/effects/bandage_unpack_2.ogg'), 100)
	user.put_in_inactive_hand(BP)
	used = TRUE
	icon_state = "bandage_pack0"//Yes this could go in update icon, but this is the only time this icon is ever going to change.


/obj/item/tourniquet
	name = "Tourniquet"
	desc = "Use this to stop arteries from bleeding. One time use only."
	icon = 'icons/obj/items.dmi'//TODO: MOVE THIS INTO ANOTHER DMI!
	icon_state = "tourniquet"
	w_class = ITEM_SIZE_SMALL

/obj/item/tourniquet/attack(mob/living/carbon/human/H as mob, mob/living/userr, var/target_zone)//All of this is snowflake and copied and pasted from sutures.
	//Checks if they're human, have a limb, and have the skill to fix it.
	if(!ishuman(H))
		return ..()
	if(!ishuman(userr))
		return ..()

	var/mob/living/carbon/human/user = userr
	var/obj/item/organ/external/affected = H.get_organ(target_zone)

	if(!affected)
		return ..()


	if(!(affected.status & ORGAN_ARTERY_CUT))//There is nothing to fix don't fix anything.
		return

	//Ok all the checks are over let's do the quick fix.

	if(affected.status & ORGAN_ARTERY_CUT)//Fix arteries.
		user.visible_message("<span class='notice'>[user] to apply the tourniquet to their [affected.name].")
		if(do_mob(user, H, (backwards_skill_scale(user.SKILL_LEVEL(medical)) * 5)))
			user.visible_message("<span class='notice'>[user] has patched the [affected.artery_name] in [H]'s [affected.name] with \the [src.name].</span>", \
			"<span class='notice'>You have patched the [affected.artery_name] in [H]'s [affected.name] with \the [src.name].</span>")
			affected.status &= ~ORGAN_ARTERY_CUT
			playsound(src, 'sound/items/tourniquet.ogg', 70, FALSE)
			qdel(src)

		affected.update_damages()



//RED STORAGE ITEMS

/obj/item/storage/backpack/satchel/warfare/prac
	icon_state = "firstaidsatchel"

/obj/item/storage/backpack/satchel/warfare/prac/blue
	icon_state = "firstaidsatchel_blue"

/obj/item/storage/backpack/satchel/warfare/red
	icon_state = "redsatchel"

/obj/item/storage/backpack/satchel/warfare/red/New()
	..()
	icon_state = pick("redsatchel", "redsatchelalt")

/obj/item/storage/backpack/warfare/red
	icon_state = "redpack"

/obj/item/storage/backpack/satchel/warfare/chestrig/red
	icon_state = "chestrig"

/obj/item/storage/backpack/satchel/warfare/chestrig/red/medic
	New()
		..()
		for(var/x, x<4, x++)
			new /obj/item/ammo_magazine/a762/sks(src)

/obj/item/storage/backpack/satchel/warfare/chestrig/red/soldier
	New()
		..()
		for(var/x, x<4, x++)
			new /obj/item/ammo_magazine/c45rifle/akarabiner(src)

/obj/item/storage/backpack/satchel/warfare/chestrig/red/sl
	New()
		..()
		for(var/x, x<4, x++)
			new /obj/item/ammo_magazine/a762/m14(src)

/obj/item/storage/backpack/satchel/warfare/chestrig/red/engineer
	New()
		..()
		for(var/x, x<4, x++)
			new /obj/item/ammo_magazine/mc9mmt/machinepistol(src)

/obj/item/storage/backpack/satchel/warfare/chestrig/red/autoshotty
	New()
		..()
		for(var/x, x<4, x++)
			new /obj/item/ammo_magazine/autoshotty(src)

/obj/item/storage/backpack/satchel/warfare/chestrig/red/oldlmg
	New()
		..()
		for(var/x, x<4, x++)
			new /obj/item/ammo_magazine/c45rifle/flat(src)


//BLUE STORAGE ITEMS
/obj/item/storage/backpack/satchel/warfare/blue
	icon_state = "blue_satchel"

/obj/item/storage/backpack/satchel/warfare/blue/soldier
	New()
		..()
		for(var/x, x<4, x++)
			new /obj/item/ammo_magazine/c45rifle/akarabiner(src)

/obj/item/storage/backpack/satchel/warfare/blue/medical
	icon_state = "medic_satchel_blue"

/obj/item/storage/backpack/warfare/blue
	icon_state = "blue_backpack"

/obj/item/storage/backpack/satchel/warfare/chestrig/blue
	icon_state = "chestrig"

/obj/item/storage/backpack/satchel/warfare/chestrig/blue/soldier
	New()
		..()
		for(var/x, x<4, x++)
			new /obj/item/ammo_magazine/c45rifle/akarabiner(src)

/obj/item/storage/backpack/satchel/warfare/chestrig/blue/medical
	icon_state = "chestrig"

	New()
		..()
		for(var/x, x<4, x++)
			new /obj/item/ammo_magazine/a762/allrounder(src)


/obj/item/storage/backpack/satchel/warfare/chestrig/blue/sl
	New()
		..()
		for(var/x, x<4, x++)
			new /obj/item/ammo_magazine/a762/m14/battlerifle_mag(src)

/obj/item/storage/backpack/satchel/warfare/chestrig/blue/engineer
	New()
		..()
		for(var/x, x<4, x++)
			new /obj/item/ammo_magazine/mc9mmt/machinepistol(src)

/obj/item/storage/backpack/satchel/warfare/chestrig/blue/autoshotty
	New()
		..()
		for(var/x, x<4, x++)
			new /obj/item/ammo_magazine/autoshotty(src)

obj/item/storage/backpack/satchel/warfare/chestrig/blue/oldlmg
	New()
		..()
		for(var/x, x<4, x++)
			new /obj/item/ammo_magazine/c45rifle/flat(src)


/obj/item/clothing/shoes/jackboots/warfare/red
	icon_state = "redboots"
	item_state = "redboots"
	warfare_team = RED_TEAM
	sprite_sheets = list(SPECIES_CHILD = 'icons/mob/species/child/feet.dmi')

/obj/item/clothing/shoes/jackboots/warfare/blue
	icon_state = "redboots"
	item_state = "redboots"
	warfare_team = BLUE_TEAM
	sprite_sheets = list(SPECIES_CHILD = 'icons/mob/species/child/feet.dmi')

/obj/item/grenade_dud
	name = "Dud"
	desc = "This grenade doesn't look like it'll function properly. Might make a decent club?"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "stick0"
	force = 10

//IFAK Autoinjector
/obj/item/reagent_containers/hypospray/autoinjector/warfare/trooper
	name = "Bland Corp. 'Second Wind' Injectable"
	desc = "An injectable syrette issued to frontline troops. It allows them to quickly revive their comrades for a brief window of time."
	starts_with = list(/datum/reagent/tramadol/morphine = 5, /datum/reagent/atepoine = 10)
	volume = 50
	amount_per_transfer_from_this = 50
	icon_state = "syrette_closedalt"
	inject_sound = 'sound/items/syrette_inject.ogg'

/obj/item/reagent_containers/hypospray/autoinjector/warfare/trooper/update_icon()
	if(reagents.total_volume > 0)
		icon_state = "syrette_closedalt"
	else
		icon_state = "syrette_openalt"

/obj/item/reagent_containers/hypospray/autoinjector/warfare/trooper/New()
	..()
	reagents.add_reagent(/datum/reagent/blood, 30, list("donor" = null, "blood_DNA" = null, "blood_type" = "O-", "trace_chem" = null, "virus2" = list(), "antibodies" = list()))

/obj/item/reagent_containers/hypospray/autoinjector/warfare/trooper/examine(mob/user)
	. = ..()
	if(get_dist(user, src) > 1)
		return
	to_chat(user,SPAN_BOLD("You notice a set of instructions on the label:"))
	to_chat(user,SPAN_WARNING("USE TO QUICKLY STABILISE YOUR FELLOW TROOPER. AFTER INJECTION, URGE THEM TO PERFORM SELF SURGERY, OR REQUEST A PRACTITIONER. THEY WILL ONLY HAVE 30 SECONDS TO ACT."))
	to_chat(user,SPAN_WARNING("<u>YOU ONLY HAVE ONE. USE IT WITH GREAT CONSIDERATION AND THE AIM TO MINIMIZE FRIENDLY CASUALTIES. DO NOT USE IT ON YOURSELF UNLESS THE SITUATION IS DIRE.</u>"))
	to_chat(user,SPAN_BOLD("<small>Bland Corp. does not bear any responsibility in the case of any deaths or harm caused by our products. All products have been approved by the Powers That Be. Any attempt at a civil suit will be null and void.</b>"))






//MORALE OFFICER ITEMS
/obj/item/clothing/suit/armor/officer
	name = "morale officer's uniform"
	desc = "Fit for <b>ONLY</b> you."
	icon_state = "prac_robes"
	item_state = "prac_robes"
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS
	body_parts_covered = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	canremove = FALSE
	armor = list(melee = 9999, bullet = 9999, laser = 9999, energy = 9999, bomb = 9999, bio = 9999, rad = 9999)

/obj/item/clothing/mask/gas/sniper/officer
	icon_state = "sniper"
	item_state = "sniper"
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHEADHAIR
	body_parts_covered = FACE|EYES
	helmet_vision = FALSE
	worldicons = "sniperworld"
	canremove = FALSE

/obj/item/clothing/head/moraleofficer
	name = "Morale Officer\'s Cap"
	desc = "Fit for you."
	icon_state = "redcaptain"
	item_state = "redcaptain"
	worldicons = list("captainhatworld1","captainhatworld2")
	canremove = FALSE

/obj/item/clothing/under/moraleofficer
	name = "Morale Officer's Suit"
	desc = "A serious uniform. Ignore the piss stains and brown skid marks on the back."
	icon_state = "redgrunt"
	worn_state = "redgrunt"
	item_state = "redgrunt"
	canremove = FALSE

/obj/item/clothing/shoes/moraleofficer
	name = "Morale Officer's Boots"
	icon_state = "prac_boots"
	item_state = "prac_boots"
	canremove = FALSE

/obj/item/clothing/gloves/moraleofficer
	name = "Morale Officer's Gloves"
	desc = "They're gloves. You need gloves in the cold. Unfortunately the Powers That Be gave you these fake ones."
	icon_state = "prac_gloves"
	item_state = "prac_gloves"
	canremove = FALSE
	armor = list(melee = 9999, bullet = 9999, laser = 9999, energy = 9999, bomb = 9999, bio = 9999, rad = 9999)

/obj/item/device/radio/headset/moraleofficer
	name = "PTB-CMMD '23 headset"
	desc = "For those who shall hear all."
	origin_tech = list(TECH_ILLEGAL = 2)
	syndie = 1
	ks1type = /obj/item/device/encryptionkey/moraleofficer

/obj/item/device/encryptionkey/moraleofficer
	name = "EVIL encryption key"
	desc = "Encyrption key but <span class = 'phobia'>EVIL!!!!</span>"
	icon_state = "morale_cypherkey" //Who even has a screwdriver in warfare? Exactly, nobody.
	channels = list("Blue" = 1, "Blue Alpha" = 1, "Blue Bravo" = 1, "Blue Charlie" = 1, "Blue Delta" = 1,"Red" = 1, "Red Alpha" = 1, "Red Bravo" = 1, "Red Charlie" = 1, "Red Delta" = 1)
	origin_tech = list(TECH_ILLEGAL = 3)
	syndie = 1


/decl/hierarchy/outfit/moraleofficer
	gloves = /obj/item/clothing/gloves/moraleofficer
	glasses = /obj/item/clothing/glasses/sunglasses
	suit = /obj/item/clothing/suit/armor/officer
	head = /obj/item/clothing/head/moraleofficer
	mask = /obj/item/clothing/mask/gas/sniper/officer
	shoes = /obj/item/clothing/shoes/moraleofficer
	l_ear = /obj/item/device/radio/headset/moraleofficer
	r_ear = /obj/item/pen
	r_pocket = /obj/item/device/binoculars
	l_pocket = /obj/item/black_book
	back = /obj/item/storage/backpack/satchel
	chest_holster = null
	uniform = /obj/item/clothing/under/moraleofficer


//MORALE OFFICER'S BLACK BOOK
/obj/item/black_book
	name = "Little Black Book"
	desc = "A sweet little black book. The names within have a bright future ahead of them."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "blackbook"
	item_state = "blackbook"
	w_class = ITEM_SIZE_TINY

//Examining for names
/obj/item/black_book/examine(mob/user) //NOTE - WHEN I ADD THE OFFICER, MAKE THIS EXCLUSIVE TO THE OFFICER
	. = ..()
	to_chat(user,SPAN_WARNING("There are [GLOB.bright_futures.len] names in the book."))
	if(LAZYLEN(GLOB.bright_futures))
		to_chat(user,SPAN_DANGER("To be specific:"))
		for(var/mob/living/M in GLOB.bright_futures)
			to_chat(user, SPAN_WARNING("- <i>[M.real_name]</i>"))

//Adding names to the book
/obj/item/black_book/proc/add_name(mob/target as mob, mob/user as mob) //Adding people to the book
	GLOB.bright_futures.Add(target)
	to_chat(user,SPAN_NOTICE("You add [target.name] to the lists of the book."))
	user.visible_message(SPAN_WARNING("[user.name] writes down something in their little black book..."))

//Checking for duplicates - causes a whole heap of shitcode issues if done outside of a proc
/obj/item/black_book/proc/check_for_duplicate(mob/target as mob, mob/user as mob)
	if(target in GLOB.bright_futures)
		to_chat(user,SPAN_WARNING("They're already destined for a bright future. To add them again would be pointless."))
		return 1
	return 0

//Checking for a pen. Putting this here to stop the click code from getting any more cluttered
/obj/item/black_book/proc/check_for_the_pen(mob/user as mob)
	var/obj/item/i = user.get_inactive_hand()
	if(istype(i,/obj/item/pen))
		return 1
	to_chat(user,SPAN_WARNING("You'll need a pen in your other hand."))
	return 0

//Interaction with a pen
/obj/item/black_book/attackby(obj/item/P as obj, mob/user as mob)
	if(istype(P,/obj/item/pen))
		user.visible_message(SPAN_WARNING("[user.name] begins to open and flip through the pages of the [name]"))
		var/luckcyFella = input(user,"Who would you like to write down in the book?","Political Morale Duties") as null|text
		if(!luckcyFella)
			return
		else
			for(var/mob/fella in SSmobs.mob_list)
				if(fella.name == luckcyFella) //if they're in the mob list
					if(check_for_duplicate(fella,user)) //tiny bit shitcody, however if it's outside the above if statement, it'll loop endlessly and break
						break
					else
						add_name(fella,user)
						playsound(get_turf(src), "sound/effects/paper/sign[rand(1,4)].ogg", 75, 0.25)
						break


//CLicking on peopple from a distance to add to the book
/obj/item/black_book/afterattack(mob/living/carbon/human/target, mob/user)
	if(!ishuman(user))
		return
	if(user.a_intent == I_HURT && user.Adjacent(target) && user.zone_sel.selecting == BP_HEAD)
		playsound(get_turf(src), 'sound/effects/slap.ogg', 100, 1)
		target.ear_deaf += 15
		target.ear_damage += 5
		target.apply_damage(10, BRUTE, BP_HEAD, target.run_armor_check(BP_HEAD, "melee"))
		target.flash_pain()
		user.visible_message(SPAN_WARNING("[user.name] slams the [name] shut, aiming for [target.name]'s head and delivering a swift smack to the side of it."))
		return
	if((istype(target,/mob/living/carbon/human)) && !check_for_duplicate(target,user) && check_for_the_pen(user))
		user.visible_message(SPAN_WARNING("[user.name] begins to open and flip through the pages of the [name]"))
		var/confirmation = alert("Are you sure [target.name] should be added to the book?", "Political Morale Duties", "Yes", "No")
		if(confirmation == "Yes")
			target.add_event("booked",/datum/happiness_event/booked)
			add_name(target,user)
			playsound(get_turf(src), "sound/effects/paper/sign[rand(1,4)].ogg", 75, 0.25)
		else
			user.visible_message(SPAN_WARNING("[user.name] slams the [name] shut, their gaze shooting towards [target.name] for a split second."))


//BLACK BOOK END


//Morale Officer Spawn
/obj/effect/landmark/start/morale_officer
	name = "Morale Officer"

/obj/item/device/megaphone/red
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon_state = "megaphone_red"
	worldicons = "megaphone_red_world"

	message_color = "#d33434"

/obj/item/device/megaphone/blue
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon_state = "megaphone_blue"
	worldicons = "megaphone_blue_world"

	message_color = "#3466d3"

/obj/item/device/flashlight/lamp/captain
	desc = "A classic gooseneck desk lamp."
	icon_state = "caplamp"
	item_state = "caplamp"
	plane = ABOVE_HUMAN_PLANE
	anchored = TRUE
	on = FALSE
	brightness_on = 8
	light_power = 5
	power_rang
	light_color = "#e6c2a1"
	var/examined
/*
/obj/item/device/flashlight/lamp/captain/examine(mob/user, distance)
	. = ..()
	if(!ishuman(user))
		return
	if(user.stats.cooldown_finished("hurt_eyes") && prob(15) && !examined && on)
		var/datum/roll_result/result = user.stat_roll(6, /datum/rpg_skill/handicraft)
		user.stats.set_cooldown("hurt_eyes", INFINITY) // only once
		examined = TRUE
		// never again, noone will believe you
		switch(result.outcome)
			if(FAILURE)
				sound_to(user, sound('sound/effects/skill/interface-diceroll-fail-02-01.ogg', volume = 100))
				sleep(10)
				to_chat(user, result.create_tooltip("You immediately closed your eyes, it is as if a laser struck your retinas and hit the nerves within your very brain. You recoil, your eyes searing in pain."))
			if(SUCCESS)
				sound_to(user, sound('sound/effects/skill/interface-diceroll-success-02-01.ogg', volume = 100))
				sleep(10)
				to_chat(user, result.create_tooltip("Ugh- that light is a bit too bright for you to look at, isn't it? You managed to look away- but your eyes still hurt.."))
			if(CRIT_SUCCESS)
				sound_to(user, sound('sound/effects/skill/interface-diceroll-success-02-01.ogg', volume = 100))
				sleep(10)
				to_chat(user, result.create_tooltip("You look away just in time, your eyes are saved from the wrath of a thousand suns."))
*/
/obj/item/device/flashlight/lamp/captain/attack_hand(mob/user)
	if(CanPhysicallyInteract(user))
		on = !on
		if(activation_sound)
			playsound(src.loc, activation_sound, 75, 1)
		update_icon()
		return
	// goodbye easteregg, one too many.
	/*
	if(!prob(15))
		return
	if(!ishuman(user))
		return
	if(user.stats.cooldown_finished("voice"))
		user.stats.set_cooldown("voice", INFINITY) // only once
		// never again, noone will believe you
		sound_to(user, sound('sound/effects/skill/interface-skill-passiveINT-04-01.ogg', volume = 100))
		to_chat(user, span_mindvoice("A wave of satisfaction washes over you- You feel proud of what you've accomplished."))
*/

// flamer

/obj/item/clothing/mask/gas/red/flamer
	icon_state = "flamer_red"
	item_state = "flamer_red"
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	body_parts_covered = FACE|EYES
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	helmet_vision = FALSE
	worldicons = "sniperworld"

/obj/item/clothing/mask/gas/blue/flamer
	icon_state = "flamer_blue"
	item_state = "flamer_blue"
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	body_parts_covered = FACE|EYES
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	helmet_vision = FALSE
	worldicons = "sniperworld"

/obj/item/clothing/shoes/jackboots/warfare/red/flamer
	item_state = "flamer_red"

/obj/item/clothing/shoes/jackboots/warfare/blue/flamer
	item_state = "flamer_blue"


/obj/item/clothing/gloves/thick/swat/combat/warfare/red/flamer
	icon_state = "flamer_red"
	item_state = "flamer_red"

/obj/item/clothing/gloves/thick/swat/combat/warfare/blue/flamer
	icon_state = "flamer_blue"
	item_state = "flamer_blue"

/obj/item/clothing/suit/fire
	var/last_sound = null
	var/list/footstep_sounds = list('sound/effects/footsteps/armor/flamer/foot1.ogg','sound/effects/footsteps/armor/flamer/foot2.ogg','sound/effects/footsteps/armor/flamer/foot3.ogg')
	armor = list(melee = 40, bullet = 40, laser = 40, energy = 40, bomb = 30, bio = 10, rad = 0)//Beefy boys.
	// Experimental armor values, more or less like half of the sentries
// hacky bs but its my bs <3

/obj/item/clothing/suit/fire/red
	name = "Redcoats Firesuit"
	icon_state = "flamer_red"
	warfare_team = RED_TEAM
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	flags_inv = null

/obj/item/clothing/suit/fire/blue
	name = "Bluecoats Firesuit"
	icon_state = "flamer_blue"
	warfare_team = BLUE_TEAM
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	flags_inv = null

/obj/item/clothing/suit/fire/handle_movement(var/turf/walking, var/running)
	last_sound = pick(footstep_sounds - last_sound)
	playsound(get_turf(src), last_sound, 25, FALSE) // this will get annoying very fast.
	/*
	if(footstep >= 1)
		footstep = 0
		playsound(get_turf(src), "flamer_step", 35, 0) // this will get annoying very fast.
	else
		footstep++
		*/

/obj/item/clothing/suit/fire/New()
	..()
	slowdown_per_slot[slot_wear_suit] = 2

// we really should make this into a bunch of files, instead of one large file..

/obj/item/clothing/mask/gas/prac_mask/newmask
	icon_state = "prac_new"
	item_state = "prac_new"

/obj/item/clothing/suit/prac_arpon/newapron
	icon_state = "pracnew"
	item_state = "pracnew"

/obj/item/clothing/gloves/prac_gloves/newgloves
	item_state = "pracnew"

/obj/item/clothing/accessory/prac_cloth
	name = "neckwarmer"
	desc = "Comfy."
	icon_state = "redprac"
	item_state = "redprac"
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_TIE
	warfare_team = RED_TEAM
	canremove = FALSE
	use_alt_layer = TRUE

/obj/item/clothing/accessory/prac_cloth/attack_hand(mob/user)
	if(ismob(loc))
		return . = ..()
	return FALSE

/obj/item/clothing/accessory/prac_cloth/bone
	icon_state = "redprac_bone"
	item_state = "redprac_bone"

/obj/item/clothing/accessory/prac_cloth/blue
	icon_state = "blueprac"
	item_state = "blueprac"
	warfare_team = BLUE_TEAM

/obj/item/clothing/accessory/prac_cloth/blue/bone
	icon_state = "blueprac_bone"
	item_state = "blueprac_bone"