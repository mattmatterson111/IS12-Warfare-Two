/obj/item/reagent_containers/glass/bottle/antique
	icon = 'icons/obj/chembottles.dmi'
	icon_state = "large"
	fill_state = "tall" /// Controls both the cork icon state and the reagentfillings.dmi icon state

	lid_on = "You put the cork into"
	lid_off = "You take the cork out of"

	lid_on_sound = 'sound/effects/cork_insert.ogg'
	lid_off_sound = 'sound/effects/large_corkopen.ogg'

	table_sound = 'sound/effects/glassclink_shelf.ogg'
	table_pickup_sound = 'sound/effects/table_scrape.ogg'

	var/start_uncorked = FALSE

	var/has_label = "large" /// Generic white label
	var/special_label = FALSE /// Whether there is a special label to be examined
	var/special_label_text = null /// text in chat when you examine the label

	var/special_label_image = null /// The image for HTML to display when examining it closer, meant to be "name.png" without a path
	var/label_width = 200
	var/label_height = 200

/obj/item/reagent_containers/glass/bottle/antique/New()
	. = ..()
	if(!start_uncorked)
		atom_flags ^= ATOM_FLAG_OPEN_CONTAINER
	update_icon()

/obj/item/reagent_containers/glass/bottle/antique/update_icon()
	. = ..()
	if(has_label)
		var/image/label = image('icons/obj/labels.dmi', src, has_label)
		overlays += label

/obj/item/reagent_containers/glass/bottle/antique/examine(mob/user)
	. = ..()
	if(!special_label || !has_label)
		return
	var/turf/T = get_turf(src)
	if(!T.Adjacent(user))
		return
	to_chat(user, "<a href='?src=\ref[src];examine_label=1'>There's a label on \the [src].</a>")

/obj/item/reagent_containers/glass/bottle/antique/Topic(href, href_list, datum/topic_state/state)
	. = ..()
	if(href_list["examine_label"])
		if(!special_label || !has_label)
			return
		var/turf/T = get_turf(src)
		if(!T.Adjacent(usr))
			return
		if(special_label_text)
			to_chat(usr, special_label_text)
		if(special_label_image)
			var/datum/asset/stuff = get_asset_datum(/datum/asset/simple/labels)
			stuff.send(usr)
			usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY bgcolor='black' style='background-image:url([special_label_image])';></body></html>", "window=[name];can_close=1;can_resize=1;border=1;titlebar=1;size=[label_width]x[label_height]")

/datum/asset/simple/labels
	assets = list(
		"lorrieson_basic.png" = 'icons/labels/lorrie_basic.png',
	)

/obj/item/reagent_containers/glass/bottle/antique/tall
	icon_state = "tall"
	has_label = "tall"
	fill_state = "tall"

/obj/item/reagent_containers/glass/bottle/antique/wide
	icon_state = "wide"
	has_label = "wide"
	fill_state = "wide"
	lid_off_sound = 'sound/effects/small_corkopen.ogg'
	volume = 35

/obj/item/reagent_containers/glass/bottle/antique/slim
	icon_state = "slim"
	has_label = "slim"
	fill_state = "slim"
	lid_off_sound = 'sound/effects/small_corkopen.ogg'
	volume = 35

/obj/item/reagent_containers/glass/bottle/antique/tall/lorrieson
	icon_state = "tall_gr"
	has_label = "lorrieson"
	special_label = TRUE
	special_label_text = "<span class='yel'>A Lorrieson Tinctures brand label!</span>"
	special_label_image = "lorrieson_basic.png"
	label_width = 530
	label_height = 228

/obj/item/reagent_containers/glass/bottle/antique/tall/metal
	icon_state = "tall_mtl"
	has_label = "tall_long"

/obj/item/reagent_containers/glass/bottle/antique/slim/chloroform
	has_label = "slim_formaldehyde"
	special_label = TRUE
	special_label_text = "<span class='yel'>A label that reads:\n\"<center><font size=4>Chloroform</font>\n<font size=2>POISON!</font>\nAntidote -- Horizontal position, cold water to the head and stimulants of diluted alcohol or aromatic spirits of ammonia, a teaspoonful of water. Emetic of mustard.\n\nThe location of origin is not listed.\n<font size=2>Recommended dosage: two to five units.\"</font></span>"
	amount_per_transfer_from_this = 5

/obj/item/reagent_containers/glass/bottle/antique/slim/chloroform/New()
	..()
	reagents.add_reagent(/datum/reagent/chloroform, 35)
	update_icon()

// Not a bottle but still

/obj/item/reagent_containers/rag
	name = "\improper rag"
	desc = "Meant to apply chloroform to your patients."
	icon = 'icons/obj/chembottles.dmi'
	icon_state = "rag"
	worldicons = "rag_world"
	volume = 15

/obj/item/reagent_containers/rag/is_open_container()
	return TRUE

/obj/item/reagent_containers/rag/attackby(obj/item/W, mob/user)
/*
	if(!reagents.get_free_space())
		to_chat(user, "<span class='notice'>[src] is full.</span>")
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(!H.get_inactive_hand() == src)
		to_chat(H, "I need to hold it in my hand..")
		return
	if(istype(W, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/RG = W
		to_chat(H, "I pour roughly [RG.amount_per_transfer_from_this] units into \the [src].")
		RG.reagents.trans_to_obj(src, RG.amount_per_transfer_from_this)
*/
	//. = ..()
	return

/obj/item/reagent_containers/rag/AltClick(mob/user)
	return

/obj/item/reagent_containers/rag/attack(mob/living/M, mob/living/user, target_zone, special = FALSE)
	if(M.get_equipped_item(slot_wear_mask) && !istype(M.get_equipped_item(slot_wear_mask), /obj/item/clothing/mask/gas/prac_mask) && !istype(M.get_equipped_item(slot_wear_mask), /obj/item/clothing/mask/smokable))
		return
	if(target_zone == BP_MOUTH)
		user.doing_something = TRUE
		user.visible_message("<span class='warning'>[user.name] brings \the [src] close to [M]'s mouth.</span>", \
					"<span class='notice'>You bring \the [src] close to [M]'s mouth.</span>")
		if(do_after(user, 70, M))
			user.doing_something = FALSE
			reagents.trans_to_obj(M, reagents.total_volume, CHEM_INGEST)
		else
			user.doing_something = FALSE

/obj/item/reagent_containers/rag/examine(mob/user, distance)
	. = ..()
	if(Adjacent(user))
		to_chat(user, SPAN_YELLOW("It is [reagents.total_volume ? "wet" : "dry"]."))

/obj/item/reagent_containers/rag/attack_self(mob/user)
	//. = ..()
	if(reagents.total_volume)
		to_chat(user, "You wring out \the [src].")
		reagents.clear_reagents()
	return

/obj/structure/table/woodentable/shelf
	name = "shelf"
	icon = 'icons/obj/chembottles.dmi'
	icon_state = "shelf"
	color = COLOR_WHITE

/obj/structure/table/woodentable/can_climb(mob/living/user, post_climb_check)
	return FALSE