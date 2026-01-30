// =============================================================================
//                           MAP ENTITY SETUP GUIDE
// =============================================================================
//
// This file contains example entity configurations and serves as a guide
// for setting up map entities in your maps.
//
// -----------------------------------------------------------------------------
// BASIC CONCEPTS
// -----------------------------------------------------------------------------
//
// 1. TARGETNAME: Every entity that needs to receive signals must have a unique
//    'targetname'. This is how other entities find and communicate with it.
//
// 2. CONNECTIONS: Entities fire outputs that trigger inputs on target entities.
//    Format: "OutputName:TargetName:InputName:Delay"
//    Example: "OnTrigger:my_door:Open:0"
//
// 3. BRUSH ENTITIES: Entities with the same 'name' placed adjacent to each
//    other will auto-connect, forming walls/areas.
//
// -----------------------------------------------------------------------------
// SETUP STEPS
// -----------------------------------------------------------------------------
//
// Step 1: Place your trigger/source entity
//     - Give it a targetname (optional, only if other entities need to target it)
//     - Add connections to wire its outputs to targets
//
// Step 2: Place your target entity
//     - Give it a targetname matching the one in connections
//
// Step 3: Configure entity-specific options
//     - filter_faction, damage, cooldown, etc.
//
// -----------------------------------------------------------------------------
// AVAILABLE OUTPUTS & INPUTS
// -----------------------------------------------------------------------------
//
// ALL ENTITIES:
//   Inputs:  Enable, Disable, Toggle, Kill
//   Outputs: OnSpawn
//
// TRIGGERS:
//   Outputs: OnTrigger, OnTriggerEnd
//   Inputs:  Trigger
//
// LOGIC_RELAY:
//   Outputs: OnTrigger
//   Inputs:  Trigger
//
// LOGIC_COUNTER:
//   Outputs: OnCount, OnThreshold, OnReset
//   Inputs:  Add, Subtract, Reset, SetValue (param: value)
//
// LOGIC_TIMER:
//   Outputs: OnTimer
//   Inputs:  Start, Stop, Toggle, FireNow
//
// AMBIENT_SOUND:
//   Outputs: OnPlay, OnStop
//   Inputs:  Play, Stop, SetVolume (param: value)
//
// ANNOUNCEMENT:
//   Outputs: OnAnnounce
//   Inputs:  Announce, SetMessage (param: value)
//
// -----------------------------------------------------------------------------
// NON-MAP ENTITY I/O
// -----------------------------------------------------------------------------
//
// Any /obj can participate in the IO system:
//
// 1. Set 'io_targetname' to register for signals:
//      io_targetname = "my_door"
//
// 2. Override IO_receive_input to handle signals:
//      /obj/machinery/door/IO_receive_input(input_name, activator, caller)
//          switch(lowertext(input_name))
//              if("open")
//                  open()
//                  IO_fire_output("OnOpen", activator)
//              if("close")
//                  close()
//                  IO_fire_output("OnClose", activator)
//          return TRUE
//
// 3. Set 'io_connections' to wire outputs:
//      io_connections = list("OnOpen:alarm_relay:Trigger:0")
//
// 4. Use global IO_output() from anywhere:
//      IO_output("puzzle_counter:Add", usr, src)
//      IO_output("door:Open", usr, src)
//
// =============================================================================

// -----------------------------------------------------------------------------
// EXAMPLE: Trigger -> Relay -> Sound (with source_atom)
// -----------------------------------------------------------------------------
// Place trigger tiles adjacent to form a trigger wall.
// When a player crosses, the relay fires, playing the alarm sound.
// The sound plays FROM the alarm_speaker position, not the sound entity itself.

/obj/effect/map_entity/trigger/example/alarm_zone
	name = "alarm_zone"
	targetname = "alarm_trigger"
	connections = list("OnTrigger:alarm_relay:Trigger:0")
	trigger_once = FALSE
	cooldown = 5 SECONDS

/obj/effect/map_entity/logic_relay/example/alarm_relay
	targetname = "alarm_relay"
	connections = list("OnTrigger:alarm_sound:PlaySound:0")

// This is where the sound logically originates
/obj/effect/map_entity/ambient_sound/example/alarm_sound
	targetname = "alarm_sound"
	sound_file = 'sound/effects/siren.ogg'
	volume = 80
	range = 15
	sound_source = "alarm_speaker"  // Sound plays from this entity using sound.atom

// Place this wherever the alarm speaker should be (can be anywhere)
/obj/effect/map_entity/example/alarm_speaker
	name = "alarm_speaker"
	targetname = "alarm_speaker"


// -----------------------------------------------------------------------------
// EXAMPLE: 3-Button Puzzle with Counter
// -----------------------------------------------------------------------------
// Three buttons, each increments a counter. When all pressed, reward triggers.

/obj/effect/map_entity/trigger/example/puzzle_button_1
	name = "puzzle_button_1"
	targetname = "puzzle_btn_1"
	connections = list("OnTrigger:puzzle_counter:Add:0")
	trigger_once = TRUE

/obj/effect/map_entity/trigger/example/puzzle_button_2
	name = "puzzle_button_2"
	targetname = "puzzle_btn_2"
	connections = list("OnTrigger:puzzle_counter:Add:0")
	trigger_once = TRUE

/obj/effect/map_entity/trigger/example/puzzle_button_3
	name = "puzzle_button_3"
	targetname = "puzzle_btn_3"
	connections = list("OnTrigger:puzzle_counter:Add:0")
	trigger_once = TRUE

/obj/effect/map_entity/logic_counter/example/puzzle_counter
	targetname = "puzzle_counter"
	threshold = 3
	reset_on_threshold = FALSE
	connections = list("OnThreshold:puzzle_reward:Trigger:0")

/obj/effect/map_entity/logic_relay/example/puzzle_reward
	targetname = "puzzle_reward"
	connections = list("OnTrigger:puzzle_announcement:Announce:0")

/obj/effect/map_entity/announcement/example/puzzle_announcement
	targetname = "puzzle_announcement"
	message = "The ancient mechanism clicks into place..."
	message_class = "notice"

// -----------------------------------------------------------------------------
// EXAMPLE: Faction-Specific Triggers
// -----------------------------------------------------------------------------

/obj/effect/map_entity/trigger/faction/red/example/red_zone
	name = "red_zone"
	targetname = "red_zone_trigger"
	connections = list("OnTrigger:red_announcement:Announce:0")
	cooldown = 10 SECONDS

/obj/effect/map_entity/trigger/faction/blue/example/blue_zone
	name = "blue_zone"
	targetname = "blue_zone_trigger"
	connections = list("OnTrigger:blue_announcement:Announce:0")
	cooldown = 10 SECONDS

/obj/effect/map_entity/announcement/example/red_announcement
	targetname = "red_announcement"
	message = "RED forces have entered the zone!"
	message_class = "danger"
	filter_faction = RED_TEAM

/obj/effect/map_entity/announcement/example/blue_announcement
	targetname = "blue_announcement"
	message = "BLUE forces have entered the zone!"
	message_class = "danger"
	filter_faction = BLUE_TEAM

// -----------------------------------------------------------------------------
// EXAMPLE: Ghost Clip Wall
// -----------------------------------------------------------------------------
// Place multiple adjacent. Staff can bypass.

/obj/effect/map_entity/clip/ghost/example/ghost_wall
	name = "ghost_wall"

// -----------------------------------------------------------------------------
// EXAMPLE: Bullet Blocker Arena
// -----------------------------------------------------------------------------

/obj/effect/map_entity/clip/bullet/example/arena_barrier
	name = "arena_barrier"

// -----------------------------------------------------------------------------
// EXAMPLE: Timed Event
// -----------------------------------------------------------------------------

/obj/effect/map_entity/logic_timer/example/periodic_event
	targetname = "event_timer"
	interval = 30 SECONDS
	start_on_spawn = TRUE
	connections = list("OnTimer:periodic_announcement:Announce:0")

/obj/effect/map_entity/announcement/example/periodic_announcement
	targetname = "periodic_announcement"
	message = "The ground trembles ominously..."
	message_class = "warning"

// -----------------------------------------------------------------------------
// EXAMPLE: Soundscapes (Valve-style)
// -----------------------------------------------------------------------------

/obj/effect/map_entity/env_soundscape/example/trench_area
	name = "trench_soundscape"
	soundscape = "warfare.trench"
	radius = 12
	position_0 = "trench_speaker_1"
	position_1 = "trench_speaker_2"

/obj/effect/map_entity/example/trench_speaker_1
	name = "trench_speaker_1"
	targetname = "trench_speaker_1"


/obj/effect/map_entity/example/trench_speaker_2
	name = "trench_speaker_2"
	targetname = "trench_speaker_2"


/obj/effect/map_entity/env_soundscape_trigger/example/bunker_entrance
	name = "bunker_trigger"
	soundscape = "warfare.bunker"

// -----------------------------------------------------------------------------
// EXAMPLE: Hazard and Heal Zones
// -----------------------------------------------------------------------------

/obj/effect/map_entity/trigger/hurt/example/lava_zone
	name = "lava_zone"
	damage = 15
	damage_type = BURN
	cooldown = 1 SECOND

/obj/effect/map_entity/trigger/example/heal_zone
	name = "heal_zone"
	targetname = "heal_trigger"
	connections = list("OnTrigger:heal_announcement:Announce:0")
	cooldown = 5 SECONDS

/obj/effect/map_entity/announcement/example/heal_announcement
	targetname = "heal_announcement"
	message = "You feel a soothing warmth..."
	message_class = "notice"
	range = 3

// -----------------------------------------------------------------------------
// EXAMPLE: Round Events Entity
// -----------------------------------------------------------------------------
// Place one of these on your map. It will receive RoundStart/RoundEnd signals
// automatically from the warfare subsystem.

/obj/effect/map_entity/round_events/example/game_events
	connections = list(
		"OnRoundStart:spawn_shutters:Open:0"
	)

// -----------------------------------------------------------------------------
// EXAMPLE: Auto Door (trigger-based instant shutter)
// -----------------------------------------------------------------------------
// Use triggers to open/close doors. Instant shutters have no delay.

/obj/machinery/door/blast/shutters/instant/spawnshutter
	io_targetname = "spawn_shutters"

/obj/effect/map_entity/trigger/example/spawndoor
	name = "spawndoor"
	targetname = "spawndoor_trigger"
	connections = list("OnTrigger:spawn_room_door:Open:0","OnTriggerEnd:spawn_room_door:Close:0")
	trigger_once = FALSE
	cooldown = 0.5 SECONDS
	filter_living = TRUE
	stay_while_occupied = TRUE

/obj/machinery/door/blast/shutters/instant/spawnroom
	io_targetname = "spawn_room_door"

// -----------------------------------------------------------------------------
// EXAMPLE: Two-Way Teleporter
// -----------------------------------------------------------------------------
// Step on either teleporter to teleport to the other one.
// Cooldown prevents infinite loops.

/obj/effect/map_entity/teleporter/example/telepad_a
	targetname = "telepad_a"
	destination = "telepad_b"
	cooldown = 1 SECOND
	allowed_types = list(/mob/living)  // Only living mobs

/obj/effect/map_entity/teleporter/example/telepad_b
	targetname = "telepad_b"
	destination = "telepad_a"
	cooldown = 1 SECOND
	allowed_types = list(/mob/living)

// -----------------------------------------------------------------------------
// EXAMPLE: One-Way Teleporter
// -----------------------------------------------------------------------------
// Only teleports from entrance to exit, not back.

/obj/effect/map_entity/teleporter/oneway/example/entrance
	targetname = "tele_entrance"
	destination = "tele_exit"
	cooldown = 0.5 SECONDS

/obj/effect/map_entity/example/tele_exit
	targetname = "tele_exit"
	name = "teleport destination"


// -----------------------------------------------------------------------------
// EXAMPLE: Trigger-Controlled Teleporter
// -----------------------------------------------------------------------------
// Teleporter that only activates via IO input, not by walking on it.

/obj/effect/map_entity/teleporter/triggered/example/escape_pad
	targetname = "escape_teleporter"
	destination = "safe_zone"
	auto_trigger = FALSE
	connections = list("OnTeleport:escape_sound:Play:0")

/obj/effect/map_entity/trigger/example/escape_button
	name = "escape_button"
	targetname = "escape_button"
	connections = list("OnTrigger:escape_teleporter:TeleportAll:0")
	trigger_once = TRUE

// -----------------------------------------------------------------------------
// EXAMPLE: Cart Teleporter
// -----------------------------------------------------------------------------
// Teleports payload carts to a destination track.
// Best used with a trigger to fire the "Teleport" input on the cart_teleport entity.

/obj/effect/map_entity/cart_teleport/example/cart_sender
	targetname = "cart_sender"
	teleport_target = "cart_receiver" // Targetname of the destination
	auto_movement_distance = 1        // Move cart 1 tile after teleport (to prevent getting stuck)

/obj/effect/map_entity/cart_detector/example/cart_teleport_trigger
	name = "cart_teleport_trigger"
	connections = list("OnTrigger:cart_sender:Teleport:0") // Trigger tells the sender to teleport the cart


/obj/effect/map_entity/example/cart_receiver
	name = "cart_receiver_point"
	targetname = "cart_receiver"


// -----------------------------------------------------------------------------
// EXAMPLE: Round Start Loudspeaker Announcement
// -----------------------------------------------------------------------------
// Automatically broadcasts a message when the round starts.
// Uses logic_auto (game_events) to trigger loudspeaker_announcement.

/obj/effect/map_entity/round_events/example/round_start_announcer
	connections = list(
		"OnRoundStart:start_scenario:Start:0",
		"OnRoundStart:global_siren:Play:0"
	)

/obj/effect/map_entity/logic_choreographed_scene/example/start_scenario
	targetname = "start_scenario"

/obj/effect/map_entity/logic_choreographed_scene/example/start_scenario/get_script()
	return list(
		list(0,  "start_announcer", "SetOn",     null),
		list(25, "start_announcer", "Broadcast", pick("TO WAR!!", "TODAY, WE WILL BE VICTORIOUS!", "MARCH ONWARD!")),
		list(50, "start_announcer", "Broadcast", "Stand back from that wall!"),
		list(65, "intro_explosion", "Trigger",   null),
		list(80, "start_announcer", "SetOff",    null)
	)

/obj/effect/map_entity/global_sound/example/siren
	targetname = "global_siren"
	sound_file = 'sound/effects/siren.ogg'

/obj/effect/map_entity/loudspeaker_announcement/example/start_announcer
	targetname = "start_announcer"
	speakercast_decl = /decl/speakercast_template/red
	id = RED_TEAM

/obj/effect/map_entity/env_explosion/example/intro_explosion
	targetname = "intro_explosion"
	heavy_impact_range = 1
	light_impact_range = 3
	flash_range = 7

// -----------------------------------------------------------------------------
// EXAMPLE: Day/Night Cycle Control
// -----------------------------------------------------------------------------

/obj/effect/map_entity/env_sun/example/sun_controller
	targetname = "sun_controller"
	current_range = 2
	current_intensity = 1
	current_color = "#545484" // Default NightFare

/obj/effect/map_entity/trigger/example/day_button
	name = "day_button"
	connections = list(
		"OnTrigger:sun_controller:SetRange:0:8",        // Full daylight range
		"OnTrigger:sun_controller:SetIntensity:0:3",    // Bright sun
		"OnTrigger:sun_controller:SetColor:0:#FFFFAA"   // Warm sunlight
	)

/obj/effect/map_entity/trigger/example/night_button
	name = "night_button"
	connections = list(
		"OnTrigger:sun_controller:SetRange:0:2",        // Dim night range
		"OnTrigger:sun_controller:SetIntensity:0:1",    // Low intensity
		"OnTrigger:sun_controller:SetColor:0:#545484"   // Cool night blue
	)