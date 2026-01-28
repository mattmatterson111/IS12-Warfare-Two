# Extensions Module Refactor - Design

## Architecture Overview

### Module Structure
```
code/modules/extensions/
├── _common/
│   ├── shared_procs.dm
│   └── constants.dm
├── war_lore/
│   ├── lore_data.dm
│   └── name_generator.dm
├── ert/
│   ├── squad_base.dm
│   ├── squad_templates.dm
│   ├── squad_members.dm
│   ├── squad_commands.dm
│   ├── squad_waypoints.dm
│   ├── squad_statistics.dm
│   ├── squad_loadouts.dm
│   └── transport/
│       ├── submarine_transport.dm
│       ├── submarine_props.dm
│       ├── teleport_turfs.dm
│       └── admin_controls.dm
├── ai_overhaul/
│   ├── npc_ai_base.dm
│   ├── npc_ai_combat.dm
│   ├── npc_ai_pathfinding.dm
│   ├── npc_ai_commands.dm
│   ├── npc_path_nodes.dm
│   └── npc_admin_panel.dm
├── cargo/
│   ├── cargo_crates.dm
│   ├── cargo_train.dm
│   └── cargo_train_carriage.dm
├── medical/
│   └── medical_expansion.dm
├── artillery/
│   └── artillery_on_demand.dm
├── screen_alerts/
│   └── screen_alerts.dm
├── atom_hud/
│   └── atom_hud_text.dm
├── location/
│   └── location.dm
├── endings/
│   └── more_endings.dm
├── README.md
└── _load.dm (includes all files)
```

## Component Design

### 1. War Lore System

#### lore_data.dm
- Centralized storage for all lore generation data
- Lists: prefixes, suffixes, city_suffixes, structures
- Easily extensible for new lore types

#### name_generator.dm
- `/datum/war_lore` - Main lore generation datum
- Procs:
  - `generate_place_name()` - Generate location names
  - `generate_city_name()` - Generate city names
  - `generate_name()` - Generate full lore entries
  - `generate_custom(template)` - Generate from custom templates

### 2. ERT System

#### squad_base.dm
- `/datum/ert_squad` - Base squad datum
- Core properties: name, benefactor, warfare_faction, members, SL (squad leader)
- Procs:
  - `spawn_squad(spawnpoints, locker_spawns, amount)` - Spawn squad members
  - `spawn_leader(client)` - Spawn squad leader
  - `spawn_adminleader(client)` - Spawn admin leader
  - `set_directive(directive, visible_text)` - Update squad objective

#### squad_templates.dm
- `/datum/ert_squad/red` - Red team squad
- `/datum/ert_squad/blue` - Blue team squad
- `/datum/ert_squad/test` - Test squad
- Extensible for custom squad types

#### squad_members.dm
- `/datum/squadmember` - Individual squad member template
- Properties: name_override, force_gender, outfit, spawn_inside_of, closet_type, mob_type
- Procs:
  - `spawn_mob(turf, locker_spawns, leader, client)` - Spawn individual member
  - `post_spawn(mob, locker_spawns)` - Configure spawned mob
  - `introduce_player(mob)` - Display intro message

#### squad_commands.dm
- Admin commands for squad management:
  - `spawn_squad()` - Create new squad
  - `change_squad_directive()` - Update objectives
  - `spawn_squadleader()` - Assign squad leader
  - `spawn_adminleader()` - Admin takes leader role
  - `promote_to_squadleader()` - Promote member to leader
  - `demote_squadleader()` - Remove leader status

#### squad_waypoints.dm
- `/proc/create_squad_waypoint()` - Create waypoint for squad
- `/proc/clear_squad_waypoints()` - Clear all waypoints
- Waypoint types: Evac/Exfil, Clear Area, Armed Hostiles, Group Up, Breach Stack, Breach Explosives, Priority, Terminate, Exfil Asset, Objective
- Admin-only: Priority, Terminate, Exfil Asset, Objective

#### squad_statistics.dm
- `/datum/squad_statistics` - Track squad performance
- Properties: kills, deaths, objectives_completed, accuracy, survival_rate
- Procs:
  - `record_kill()` - Log kill
  - `record_death()` - Log death
  - `record_objective()` - Log objective completion
  - `get_stats()` - Return formatted stats

#### squad_loadouts.dm
- `/datum/squad_loadout` - Define equipment loadouts
- Properties: outfit, weapons, equipment, skills
- Procs:
  - `apply_to_mob(mob)` - Apply loadout to squad member
  - `get_loadout_by_type(type)` - Retrieve loadout

#### transport/submarine_transport.dm
- `/obj/machinery/button/transport_controller` - Main transport control
- Procs:
  - `sound_dive(inside)` - Dive sound
  - `sound_surface(inside)` - Surface sound
  - `sound_transit()` - Transit sound
  - `transport_name()` - Return transport name

#### transport/submarine_props.dm
- `/obj/effect/sub_marker` - Submarine marker
- `/obj/effect/doorblocker` - Door blocker for transport

#### transport/teleport_turfs.dm
- `/area/vehicle` - Vehicle area base
- `/area/vehicle/submarine` - Submarine areas
- Teleport turf definitions

#### transport/admin_controls.dm
- Admin-only submarine control commands
- Procs for manual transport control

### 3. AI Overhaul System

#### npc_ai_base.dm
- `/datum/npc_ai_controller` - Main AI controller for NPCs
- Properties: target_mob, current_health, max_health, is_wounded, current_task
- Procs:
  - `process_ai()` - Main AI loop
  - `evaluate_threats()` - Scan for enemies
  - `update_health_status()` - Check if wounded
  - `retreat_when_wounded()` - Flee when health < 30%

#### npc_ai_combat.dm
- `/datum/npc_combat_ai` - Combat behavior system
- Properties: current_weapon, ammo_count, reload_threshold
- Procs:
  - `engage_target(mob/target)` - Attack enemy
  - `shoot_at_target(mob/target)` - Fire weapon
  - `reload_weapon()` - Reload gun when ammo low
  - `calculate_accuracy()` - Determine hit chance
  - `switch_weapon()` - Change to different weapon

#### npc_ai_pathfinding.dm
- `/datum/npc_pathfinding_ai` - Movement and pathfinding
- Properties: current_path, destination, path_nodes
- Procs:
  - `move_to_location(turf/target)` - Navigate to location
  - `follow_path_nodes(list/nodes)` - Follow predefined path
  - `retreat_to_safety()` - Find safe location and move there
  - `calculate_path(turf/start, turf/end)` - Compute path

#### npc_path_nodes.dm
- `/obj/effect/npc_path_node` - Waypoint for NPC navigation
- Properties: node_id, next_node, node_type (patrol, retreat, objective)
- Procs:
  - `get_next_node()` - Return next waypoint in path
  - `link_nodes(node1, node2)` - Connect path nodes

#### npc_ai_commands.dm
- `/datum/npc_command_queue` - Queue system for admin commands
- Properties: command_list, current_command, target_location
- Procs:
  - `queue_command(command_type, target)` - Add command to queue
  - `execute_command()` - Process next command
  - `clear_queue()` - Remove all pending commands

#### npc_admin_panel.dm
- `/datum/npc_admin_interface` - Admin control panel
- Procs:
  - `open_npc_panel()` - Display admin UI
  - `send_npc_to_location(npc, turf)` - Direct NPC to move
  - `command_npc_interact(npc, atom/target)` - Order NPC to interact with object
  - `view_npc_status(npc)` - Display NPC stats and state

### 4. Cargo Train System

#### cargo_crates.dm
- `/obj/structure/closet/crate/wooden` - Wooden crate base
- `/obj/structure/closet/crate/wooden/large` - Large wooden crate
- Specialized crates: pickaxes, hardhats, club, grenade, meatball
- Procs:
  - `attackby(item, user)` - Handle crowbar interaction
  - `attack_hand(user)` - Open crate

#### cargo_train.dm
- `/datum/cargo_train_manager` - Manages cargo train scheduling
- Properties: active_cargo_train, last_cargo_time, time_between_cargo
- Procs:
  - `schedule_cargo_train()` - Schedule next cargo train
  - `send_cargo_train()` - Trigger cargo train arrival
  - `generate_cargo_load()` - Create random crate selection
  - `clear_cargo_load()` - Remove all crates

#### cargo_train_carriage.dm
- `/obj/structure/vehicle/train/cargo_carriage` - Cargo train carriage
- Properties: crates_list, max_crates, is_empty
- Procs:
  - `attack_hand(user)` - Extract crate
  - `extract_crate()` - Remove one crate and place below user
  - `update_appearance()` - Update visual state based on contents
  - `clear_contents()` - Remove all crates

### 5. Subsystem Integration

#### SUBSYSTEM_DEF(squads)
- Manages squad templates and active squads
- Properties: squad_templates, active_squads, used_maps
- Procs:
  - `populate_templates()` - Load all squad types
  - `get_squad(name)` - Retrieve active squad

#### SUBSYSTEM_DEF(npc_ai)
- Manages all NPC AI controllers
- Properties: active_npcs, ai_controllers, path_nodes
- Procs:
  - `register_npc(mob)` - Add NPC to AI system
  - `unregister_npc(mob)` - Remove NPC from AI system
  - `process_all_ai()` - Update all NPC behaviors

#### Respawn System Integration
- Hook into respawn wave system
- Cargo train arrives between waves (every 2 waves)
- Timing: After passenger train leaves, before next wave

## Data Flow

### Squad Spawning Flow
1. Admin calls `spawn_squad()`
2. Select squad template
3. Enter squad designation
4. Select number of members
5. Squad template creates squad datum
6. Squad spawns members at spawnpoints
7. Members are configured with stats, skills, loadouts
8. Squad leader is assigned
9. Squad receives initial directive

### Cargo Train Flow
1. Respawn subsystem checks timing (every 2 waves)
2. Cargo train manager schedules arrival
3. Cargo train generates random crate load
4. Train arrives with sound effects
5. Players interact with carriage to extract crates
6. Carriage updates appearance as crates are removed
7. Train leaves when empty or when passenger train arrives
8. Remaining crates are cleared

### Waypoint Flow
1. Squad leader calls `place_squad_waypoint()`
2. Select waypoint type
3. Waypoint created at target location
4. All squad members receive notification
5. Waypoint tracked on HUD
6. Squad leader can clear waypoints

### NPC AI Flow
1. NPC spawned and registered with AI subsystem
2. AI controller assigned to NPC
3. Each tick: evaluate threats, check health, process commands
4. If wounded (health < 30%): retreat to safe location
5. If enemy detected: engage with weapon
6. If ammo low: reload weapon
7. If admin command queued: execute command (move, interact)
8. Update path nodes and continue patrol/objective

### NPC Interaction Flow
1. Admin commands NPC to interact with atom
2. NPC receives command with target atom
3. NPC pathfinds to target location
4. NPC calls `npc_interact(command_string)` on target atom
5. Atom's switch statement processes interaction type
6. NPC performs action (use machine, pick up item, etc.)

## Key Design Decisions

1. **Modular Organization**: Each system is self-contained in its own directory for easy maintenance and testing

2. **Extensibility**: Squad templates, loadouts, crate types, and NPC behaviors are easily extensible through inheritance

3. **Admin Control**: All squad and NPC management is admin-only with comprehensive logging

4. **Timing Integration**: Cargo train integrates with existing respawn wave system for seamless gameplay

5. **Visual Feedback**: Cargo carriage updates appearance based on contents; waypoints provide HUD feedback

6. **Error Handling**: All procs validate inputs and provide user feedback

7. **Performance**: Cargo train clears contents on departure to prevent memory leaks; NPC AI uses efficient pathfinding

8. **NPC Autonomy**: NPCs make intelligent decisions (retreat when wounded, reload, engage threats) while remaining admin-controllable

9. **Persistent Squad Data**: Optional feature (disabled by default), can be enabled in config to save squad performance to data/squad folder

## Integration Points

### With Respawn System
- Cargo train scheduled between respawn waves
- Timing: 2 waves between cargo arrivals
- Coordinates with passenger train schedule

### With Warfare System
- Squad faction determines equipment and abilities
- Squad statistics integrate with warfare metrics
- Waypoints visible to all squad members
- NPC AI respects faction relationships

### With Inventory System
- Crates use standard closet system
- Extracted crates are standard objects
- Equipment loadouts use standard items

### With Atom System
- New `/atom/proc/npc_interact(command_string)` for NPC interactions
- Atoms can define custom NPC interaction behaviors
- Switch statement processes interaction types

## Configuration

### Cargo Train Settings
- `time_between_cargo` - Ticks between cargo arrivals (default: 2 respawn waves)
- `max_crates_per_train` - Maximum crates per delivery (default: 8)
- `min_crates_per_train` - Minimum crates per delivery (default: 3)
- `whitelisted_crate_types` - List of allowed crate types

### ERT Settings
- `squad_member_count` - Default squad size (default: 8)
- `squad_leader_count` - Leaders per squad (default: 1)
- `waypoint_types` - Available waypoint callouts
- `default_loadout` - Default equipment loadout
- `persistent_squad_data_enabled` - Enable squad performance saving (default: FALSE)
- `squad_data_folder` - Path to squad data storage (default: data/squad)

### NPC AI Settings
- `npc_ai_enabled` - Enable NPC AI system (default: TRUE)
- `npc_retreat_threshold` - Health % to trigger retreat (default: 30)
- `npc_reload_threshold` - Ammo % to trigger reload (default: 25)
- `npc_threat_detection_range` - Distance to detect enemies (default: 10 tiles)
- `npc_pathfinding_algorithm` - A* or simple pathfinding (default: A*)

## Testing Strategy

### Unit Tests
- Squad spawning with various configurations
- Cargo crate extraction and placement
- Waypoint creation and tracking
- Lore name generation
- NPC pathfinding and threat detection
- NPC combat behavior (shoot, reload, retreat)

### Integration Tests
- Full squad lifecycle (spawn → directive → waypoint → despawn)
- Cargo train arrival and departure timing
- Respawn wave coordination
- NPC AI with multiple threats
- Admin commands for NPC control
- Persistent squad data saving/loading

### Manual Testing
- Admin command execution
- Squad member behavior
- Cargo train visual updates
- Waypoint HUD display
- NPC combat scenarios
- NPC admin panel functionality
- Path node navigation
