//  Every entity that needs to receive signals must have a unique
//    'targetname'. This is how other entities find and communicate with it
//
//  Entities fire outputs that trigger inputs on target entities
//    Format: "OutputName:TargetName:InputName:Delay"
//    Example: "OnTrigger:my_door:Open:0"
//
//  Entities with the same 'name' placed adjacent to each
//    other will auto-connect, (brushes only)
//
//  Use the macros in mapping_helpers.dm to quickly define
//    subtypes


MAPPING_TRIGGER(alarm_zone, "alarm_trigger", list("OnTrigger:alarm_relay:Trigger"))

MAPPING_RELAY(alarm_relay, "alarm_relay", list("OnTrigger:alarm_sound:PlaySound"))


MAPPING_TRIGGER(puzzle_button_1, "puzzle_trg_1", list("OnTrigger:puzzle_counter:Add"))
MAPPING_TRIGGER(puzzle_button_2, "puzzle_trg_2", list("OnTrigger:puzzle_counter:Add"))
MAPPING_TRIGGER(puzzle_button_3, "puzzle_trg_3", list("OnTrigger:puzzle_counter:Add"))

MAPPING_COUNTER(puzzle_counter, "puzzle_counter", 3, list("OnThreshold:puzzle_reward:Trigger"))

MAPPING_RELAY(puzzle_reward, "puzzle_reward", list("OnTrigger:puzzle_announcement:Announce"))

MAPPING_ANNOUNCEMENT(puzzle_announcement, "puzzle_announcement", "Congrats", "notice", null)


/obj/effect/map_entity/trigger/faction/red/red_zone
	name = "red_zone"
	connections = list("OnTrigger:red_announcement:Announce")

/obj/effect/map_entity/trigger/faction/blue/blue_zone
	name = "blue_zone"
	connections = list("OnTrigger:blue_announcement:Announce")

MAPPING_ANNOUNCEMENT(red_announcement, "red_announcement", "RED forces have entered the zone!", "danger", RED_TEAM)
MAPPING_ANNOUNCEMENT(blue_announcement, "blue_announcement", "BLUE forces have entered the zone!", "danger", BLUE_TEAM)


MAPPING_TIMER(periodic_event, "event_timer", 30 SECONDS, list("OnTimer:periodic_announcement:Announce"))

/obj/effect/map_entity/logic_timer/periodic_event
	start_on_spawn = TRUE

MAPPING_ANNOUNCEMENT(periodic_announcement, "periodic_announcement", "Test", "warning", null)

MAPPING_SUN(sun_controller, "sun_controller", 2, 1, "#545484")

/obj/effect/map_entity/round_events/example/round_start_events
	connections = list(
		"OnRoundStart:start_scenario:Start",
		"OnRoundStart:global_siren:Play"
	)

MAPPING_AMBIENT_SOUND(global_siren, "global_siren", 'sound/effects/siren.ogg', 0, 100)

MAPPING_CHOREO(start_scenario, "start_scenario", list(
	CHOREO_EVENT(0,  "red_highcom", "SetOn",     null),
))

MAPPING_EXPLOSION(intro_explosion, "intro_explosion", 0, 1, 3, 7)

MAPPING_LOUDSPEAKER(red, "red", /decl/speakercast_template/red, RED_TEAM)
MAPPING_LOUDSPEAKER(red_highcom, "red_highcom", /decl/speakercast_template/red/highcom, RED_TEAM)
MAPPING_LOUDSPEAKER(blue, "blue", /decl/speakercast_template/blue, BLUE_TEAM)
MAPPING_LOUDSPEAKER(blue_highcom, "blue_highcom", /decl/speakercast_template/blue/highcom, BLUE_TEAM)


MAPPING_AUTO_DAY_LIGHT(obj/machinery/light/streetlamp/floodlamp)
MAPPING_AUTO_DAY_LIGHT(obj/machinery/light/streetlamp/floodlamp/short)
MAPPING_AUTO_DAY_LIGHT(obj/machinery/light)
MAPPING_AUTO_DAY_LIGHT(obj/machinery/light/small/bunker)
MAPPING_AUTO_DAY_LIGHT(obj/machinery/light/caged)

MAPPING_SOUNDSCAPE_DECL(example_soundscape, "warfare.example_soundscape", 1, 2.0, \
	list( \
		SC_LOOP('sound/ambience/distant_warfare.ogg', 0.6, 100) \
	), \
	list( \
		SC_RANDOM(5, 15, 0.2, 0.5, list('sound/ambience/ambigen1.ogg', 'sound/ambience/ambigen2.ogg')) \
	) \
)



// scrapped feature, dw

MAPPING_CHOREO(redbase_burn, "choreo_redburn", list(
	CHOREO_EVENT(0,  "red_burnlight", "SetOn",     null),
	CHOREO_EVENT(5,  "red_burnspeaker", "playSound",     null),
	CHOREO_EVENT(45,  "red_burnlight", "SetOff",     null),
))

MAPPING_CHOREO(bluebase_burn, "choreo_blueburn", list(
	CHOREO_EVENT(0,  "blue_burnlight", "SetOn",     null),
	CHOREO_EVENT(5,  "blue_burnspeaker", "playSound",     null),
	CHOREO_EVENT(45,  "blue_burnlight", "SetOff",     null),
))

MAPPING_AMBIENT_SOUND(red_burn, "red_burnspeaker", 'sound/effects/keypad/correct.ogg', 9, 80)

MAPPING_AMBIENT_SOUND(blue_burn, "blue_burnspeaker", 'sound/effects/keypad/correct.ogg', 9, 80)

/obj/effect/map_entity/fire_pit/redcoats
	faction_id = RED_TEAM
	connections = list(
		"onBurn:choreo_redburn:Start"
	)

/obj/effect/map_entity/fire_pit/bluecoats
	faction_id = BLUE_TEAM
	connections = list(
		"onBurn:choreo_blueburn:Start"
	)
	

MAPPING_CHOREO(get_the_fuck_back_soldier, "goback", list(
	CHOREO_EVENT(0,  "red_highcom", "SetOn",     null),
	CHOREO_EVENT(20, "red_highcom", "Announce", "Get the fuck back into the fight, soldier!"),
	CHOREO_EVENT(40, "red_highcom", "SetOff",     null),
))