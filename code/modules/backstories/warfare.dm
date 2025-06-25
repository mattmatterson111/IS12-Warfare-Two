/datum/backstory/nepotismcaptain
	name = "The product of Nepotism"
	description = "You are the child of a high-ranking officer, and you have always been given special treatment. You have never had to work hard for anything, and you have always been able to rely on your family's connections to get what you want. You are used to being in charge, and you expect others to follow your orders without question. However, you have never had to fight for anything, and you are not prepared for the harsh realities of war."
	chance = 5 // Rarity

/datum/backstory/nepotismcaptain/apply(mob/living/carbon/human/user)
	. = ..()
	user.SKILL_LEVEL(melee) = user.SKILL_LEVEL(melee)-2
	user.SKILL_LEVEL(auto_rifle) = user.SKILL_LEVEL(auto_rifle)-2
	user.SKILL_LEVEL(semi_rifle) = user.SKILL_LEVEL(semi_rifle)-2
	user.SKILL_LEVEL(sniper) = user.SKILL_LEVEL(sniper)-2
	user.SKILL_LEVEL(shotgun) = user.SKILL_LEVEL(shotgun)-2
	user.SKILL_LEVEL(lmg) = user.SKILL_LEVEL(lmg)-2
	user.SKILL_LEVEL(smg) = user.SKILL_LEVEL(smg)-2
	user.SKILL_LEVEL(boltie) = user.SKILL_LEVEL(boltie)-2
	user.equip_to_slot_or_del(new /obj/item/spacecash/bundle/c50(), slot_r_hand)
	user.equip_to_slot_or_del(new /obj/item/spacecash/bundle/c50(), slot_l_hand)

/datum/backstory/childcaptain
	name = "Too young for war"
	description = "You are a captain- Wait, you're just a child! You have no idea what you're doing, but you have a shiny uniform and a big hat. The last captain was killed in action, and you were the only one left to take command. You are determined to show them that you can lead just as well as any adult."
	chance = 5 // Rarity

/datum/backstory/childcaptain/apply(mob/living/carbon/human/user)
	. = ..()
	user.set_species(SPECIES_CHILD)//Actually makes them a child.
	user.unlock_achievement(new/datum/achievement/kid())
	var/r_pocket = user.get_equipped_item(slot_r_store)
	var/l_pocket = user.get_equipped_item(slot_l_store)
	var/belt = user.get_equipped_item(slot_belt)
	qdel(user.get_equipped_item(slot_w_uniform))
	var/to_equip = /obj/item/clothing/under/child_jumpsuit/warfare/red
	var/suit = user.get_equipped_item(slot_wear_suit)
	user.drop_from_inventory(suit)
	if(user.warfare_faction == BLUE_TEAM)
		to_equip = /obj/item/clothing/under/child_jumpsuit/warfare/blue
	// This is stupid. Cannot equip the uniform unless we take off the suit.
	// Removing the uniform drops the items in the pockets and the belt
	// so I have to grab those, remove the uniform, drop the jacket, equip the uniform, equip the jacket, and then re-equip the pockets and belt
	// THIS SUCKS
	user.equip_to_slot_or_del(new to_equip, slot_w_uniform)
	user.equip_to_slot_or_del(suit, slot_wear_suit)
	user.equip_to_slot_or_del(r_pocket, slot_r_store)
	user.equip_to_slot_or_del(l_pocket, slot_l_store)
	user.equip_to_slot_or_del(belt, slot_belt)
	user.STAT_LEVEL(dex) = rand(2, 7)
	user.STAT_LEVEL(int) = rand(2, 7)
	user.STAT_LEVEL(str) = rand(2, 7)
	user.STAT_LEVEL(end) = rand(2, 7)
	user.set_hud_stats(5)

/datum/backstory/beakless
	name = "The Defiant Doctor"
	description = "You are a practitioner who sneers at your peers for their methods and close minded practices. You have no beak by your own choice, having severed your ties to their ways, and you are proud of it. You believe that the traditional ways of healing are outdated and that true progress comes from experimentation and innovation. You may not be well-liked by your peers, but you are determined to prove your worth in this unforgiving environment."
	chance = 5 // Removes your beak, actually makes you better at surgery, higher int but you're going to be fucking hated

/datum/backstory/beakless/apply(mob/living/carbon/human/user)
	. = ..()
	user.SKILL_LEVEL(surgery) = user.SKILL_LEVEL(surgery)+1
	user.SKILL_LEVEL(medical) = user.SKILL_LEVEL(medical)+1
	user.STAT_LEVEL(dex) = user.STAT_LEVEL(dex)+1
	user.STAT_LEVEL(int) = user.STAT_LEVEL(int)+1
	qdel(user.get_equipped_item(slot_wear_mask))
	user.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/prac_mask/broken(), slot_wear_mask)
	user.set_hud_stats(5)

/datum/backstory/translator
	name = "The Translator"
	description = "You studied the enemy team's language and culture in secret, and you are now able to communicate with them fluently."
	chance = 5 // Rarity

/datum/backstory/translator/apply(mob/living/carbon/human/user)
	. = ..()
	if(user.warfare_faction == RED_TEAM)
		user.add_language(LANGUAGE_BLUE)
	else
		user.add_language(LANGUAGE_RED)