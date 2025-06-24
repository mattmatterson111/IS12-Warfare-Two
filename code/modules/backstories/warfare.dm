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

/datum/backstory/beakless
	name = "The Outcast"
	description = "You are a practitioner who has been shunned by your peers for your radical methods and controversial practices. You have no beak by your own choice, and you are proud of it. You believe that the traditional ways of healing are outdated and that true progress comes from experimentation and innovation. You may not be well-liked by your peers, but you are determined to prove your worth in this unforgiving environment."
	chance = 5 // Removes your beak, actually makes you better at surgery, higher int but you're going to be fucking hated

/datum/backstory/beakless/apply(mob/living/carbon/human/user)
	. = ..()
	user.SKILL_LEVEL(surgery) = user.STAT_LEVEL(int)+1
	user.SKILL_LEVEL(medical) = user.STAT_LEVEL(int)+1
	user.STAT_LEVEL(dex) = user.STAT_LEVEL(int)+1
	user.STAT_LEVEL(int) = user.STAT_LEVEL(int)+1
	qdel(user.get_equipped_item(slot_wear_mask))
	user.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/prac_mask/broken(), slot_wear_mask)