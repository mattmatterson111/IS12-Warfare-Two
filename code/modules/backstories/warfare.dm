/datum/backstory/nepotismcaptain
	name = "The product of Nepotism"
	description = "<i>You</i> come from a high-end family within your country of origin, you know practically nothing about war, weaponry, or the like. All you really know is that your family is rich, and that you have supreme authority over all, and that noone should question it. Oh- and that you have some spare dosh to use to purchase gear with. That's about it. You're a nepo baby. Get over it."
	chance = 5 // rare, extra dosh and

/datum/backstory/nepotismcaptain/apply(mob/living/carbon/human/user)
	. = ..() // fuck you?? you're a nepo baby, you don't know how to FIGHT
	user.SKILL_LEVEL(melee) = rand(3,6)
	user.SKILL_LEVEL(auto_rifle) = rand(3,6)
	user.SKILL_LEVEL(semi_rifle) = rand(3,6)
	user.SKILL_LEVEL(sniper) = rand(3,6)
	user.SKILL_LEVEL(shotgun) = rand(3,6)
	user.SKILL_LEVEL(lmg) = rand(3,6)
	user.SKILL_LEVEL(smg) = rand(3,6)
	user.SKILL_LEVEL(boltie) = rand(3,6)
	user.equip_to_slot_or_del(new /obj/item/spacecash/bundle/c100(), slot_r_hand)
	user.equip_to_slot_or_del(new /obj/item/spacecash/bundle/c100(), slot_l_hand)
// pracs
/*
/datum/backstory/disgruntledprac
	name = "The product of Spite"
	description = "<b>You.</b> Yes, <i>you.</i> <i>You</i> are a practicioner and- <b><i>THIS?</b> This</i> is no place for you to be.. You wanted to serve in a clinic, but <i>nnoooo..</i> they just had to send you HERE, wanting you to be both NEUTRAL and- to only aid the team that hired you..? It just doesn't make sense! Alas, you still have to do your duties.. <i>But..</i> Noone said you had to do it with a smile."
	chance = 5

/datum/backstory/scholar
	name = "The Product of Intelligence"
	description = "<b>You.</b> Yes, <i>you.</i> <i>You</i> are a practitioner of talent, molded by rigorous study and honed in the halls of a clinic. You were an apprentice once, yet even then, you showed rare insight and a quick mastery over complex practices, adept as any seasoned practitioner. And <b><i>THIS?</b> This</i> is where they send you? To play impartial to a team and ignore the greater good? <i>Unbelievable.</i> Still, you will serve, but you won't let anyone forget that you should be somewhere better.."
	chance = 5

/datum/backstory/idealistic
	name = "The Idealist"
	description = "<b>You.</b> Yes, <i>you.</i> <i>You</i> are a practitioner with purpose, driven by a vision to heal and uplift others. While others may have come here grudgingly, <i>you</i> volunteered. You believe in aiding those who need it most, and you’re ready to face any challenge. Every patient is a new opportunity, every duty a calling. This place may not be the clinic of your dreams, but to you, it’s a canvas for compassion."
	chance = 5

/datum/backstory/frontier_medic
	name = "The Frontier Beak"
	description = "<b>You.</b> Yes, <i>you.</i> <i>You</i> are a practitioner seasoned by the harsh conditions of remote outposts and colonies. This isn’t your first time on the frontier, and you’re used to working with limited supplies and improvising when things get tough. The frontline feels almost <i>luxurious</i> by comparison, and you thrive on the challenge. If anyone here knows how to survive, it’s you."
	chance = 5
*/

/datum/backstory/beakless
	name = "The Outcast"
	description = "Having found yourself cast out of the league, now beakless and without a place to call home, you are a practitioner who has chosen to act outside of the drawn lines, boundaries set by your peers. You’ve been through the wringer, and you know how to handle yourself in tough situations. You may not have the beak, but you have the skills and the grit to make it through anything. This place is just another challenge, and you’re ready to face it head-on."
	chance = 5 // Removes your beak, actually makes you better at surgery, higher int but you're going to be fucking hated

/datum/backstory/beakless/apply(mob/living/carbon/human/user)
	. = ..()
	user.SKILL_LEVEL(surgery) = user.STAT_LEVEL(int)+2
	user.SKILL_LEVEL(medical) = user.STAT_LEVEL(int)+2
	user.STAT_LEVEL(dex) = user.STAT_LEVEL(int)+2
	user.STAT_LEVEL(int) = user.STAT_LEVEL(int)+2
	// You know how to do surgery, and due to your experimentation- you can do it slightly better than the others, you just don't have the beak to do it
	qdel(user.get_equipped_item(slot_wear_mask))
	user.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/prac_mask/broken(), slot_wear_mask)