% Load the memory library that contains cpp bindings for RPM/WPM
:- use_module(memorylib).

% Load the offsets module
:- use_module(offsets).

% Define a few dynamic predicates to store csgo's handle/module and the local
% player
:- dynamic cs_handle/1.

set_cs_handle(Handle):-
    retractall(cs_handle(_)),
    assert(cs_handle(Handle)).

:- dynamic cs_process/1.

set_cs_process(Process):-
    retractall(cs_process(_)),
    assert(cs_process(Process)).

:- dynamic cs_module/1.

set_cs_module(Module):-
    retractall(cs_module(_)),
    assert(cs_module(Module)).

:- dynamic local_player/1.

set_local_player(LocalPlayer):-
    retractall(local_player(_)),
    assert(local_player(LocalPlayer)).


% Hook into csgo
hook:-
    hook_csgo,
    hook_local_player,
    writeln("Hooked into csgo!").

% Used to hook into the csgo game itself
hook_csgo:-

    % Get the handle to csgo process
    get_process_handle("csgo.exe", Handle),

    % Get the id of the csgo process
    get_process_id("csgo.exe", Process),
    
    % Get the csgo client module
    get_module("client.dll", Process, Module),

    % Store all these variables using the dynamic predicates
    set_cs_handle(Handle),
    set_cs_process(Process),
    set_cs_module(Module).

% Used to hook into the local player object
hook_local_player:-

    % Get the csgo module and handle
    cs_module(Module),
    cs_handle(Handle),

    % Get the local player offset and calculate the local player address
    offset_local_player(LocalPlayerOffset),
    LocalPlayerAddress is Module + LocalPlayerOffset,

    % Get the reference to the local player from memory
    read_dword(Handle, LocalPlayerAddress, LocalPlayer),

    % Make sure it's not null and then set it using the global predicate
    LocalPlayer \= 0,
    set_local_player(LocalPlayer).

% Helper predicate to make sure we're hooked into csgo
hooked:-

    % Get the csgo handle, module and local player
    cs_handle(Handle),
    cs_module(Module),
    local_player(LocalPlayer),

    % Make sure all of the variables are valid
    Handle \= 0,
    Module \= 0,
    LocalPlayer \= 0.

% Bhop hack
bhop:-

    % Make sure we're hooked into csgo
    hooked,

    % Check whether the user is pressing the spacebar at the moment
    get_async_key_state(32, State),
    State = 1,

    % Get the flag from the game's memory
    % The flag is basically the player's current state
    get_flag(Flag),

    % We need to make sure we can let the player force jump
    % We do this using a bitwise AND operator to make sure we can jump
    CanJump is Flag /\ (1 << 0),
    CanJump = 1,

    % Get the csgo module and handle
    cs_module(Module),
    cs_handle(Handle),

    % Get the force jump offset and calculate the force jump address
    offset_force_jump(ForceJumpOffset),
    JumpAddress is Module + ForceJumpOffset,

    % Write a dword value of 6 to the force jump address, this will make the 
    % player jump
    write_dword(Handle, JumpAddress, 6),
    
    % Sleep the thread for 1 ms to make sure we're not constantly reading/
    % writing memory from and to the game.
    sleep(0.001),

    % Call the bhop predicate again
    bhop.
bhop:-

    % Used to keep the bhop predicate running for when we shouldn't jump
    % (while they're in the air for example)
    hooked,
    sleep(0.001),
    bhop.

% Helper predicate for the bhop predicate
get_flag(Flag):-

    % Get the csgo handle and local player
    cs_handle(Handle),
    local_player(LocalPlayer),

    % Get the flag offset and calculate the flag address
    offset_flags(FlagOffset),
    FlagAddress is LocalPlayer + FlagOffset,

    % Read the flag byte from the flag address and instantiate the flag variable
    % using the result
    read_byte(Handle, FlagAddress, Flag).


% Predicate used to enable the glow on enemies
glowhack:-

    % Make sure we're hooked into csgo
    hooked,

    % Get the csgo module, handle and local player
    cs_module(Module),
    cs_handle(Handle),
    local_player(LocalPlayer),

    % Get the team num offset and calculate the team address
    offset_team_num(TeamOffset),
    TeamAddress is LocalPlayer + TeamOffset,

    % Read the player's team from memory using the team address
    read_int(Handle, TeamAddress, Team),

    % Get the glow object manager offset and calculate the glow object manager address
    offset_glow_object_manager(GlowObjectManagerOffset),
    GlowObjectManagerAddress is Module + GlowObjectManagerOffset,

    % Read the memory address reference from the memory
    read_int(Handle, GlowObjectManagerAddress, GlowObject),

    % Write the changed glow to the entities
    write_glow(Module, Handle, GlowObject, Team, 0),

    % Sleep prolog for 1ms because we want to be able to ctrl + c out of this
    sleep(0.001),

    % Call this again so we keep the "hack" active
    glowhack.

% This predicate is called whenever something goes wrong in the previous
% predicate and is simply used to restart the glow hack
glowhack:-
    sleep(0.001),
    glowhack.

% Write the information to memory to make the enemies glow
% This predicate is run for every entity from id 0-63
write_glow(Module, Handle, GlowObject, Team, Index):-

    % Make sure the id is still in the range [0,63]
    Index < 64,

    % Get the entity list offset and calculate the address for the entity
    % with the specified id
    offset_entity_list(EntityListOffset),
    EntityAddress is Module + EntityListOffset + (Index * 16),

    % Read the address of the entity and make sure it's not 0 (which means the)
    % entity isn't valid
    read_int(Handle, EntityAddress, Entity),
    Entity \= 0,

    % Get the glow index offset and calculate the glow index address
    offset_glow_index(GlowIndexOffset),
    GlowIndexAddress is Entity + GlowIndexOffset,

    % Read the glow index address
    read_int(Handle, GlowIndexAddress, GlowIndex),

    % Get the team offset and calculate the address to the entity's team
    offset_team_num(TeamNumOffset),
    EntityTeamAddress is Entity + TeamNumOffset,

    % Read the entity's team
    read_int(Handle, EntityTeamAddress, EntityTeam),

    % Make sure the entity's team is not equal to the player's team
    % We do this to prevent the player's teammates from "glowing" as well
    % There's a cut here to prevent prolog from backtracking to this this entity
    EntityTeam \= Team, !,

    % Calculate the memory addresses for the RGB and opacity components of the 
    % glow, these are stored as floats so there's a 4 bit offset every time
    RAddress is GlowObject + ((GlowIndex * 56) + 4),
    GAddress is GlowObject + ((GlowIndex * 56) + 8),
    BAddress is GlowObject + ((GlowIndex * 56) + 12),
    OpacityAddress is GlowObject + ((GlowIndex * 56) + 16),

    % Calculate the memory addresses for the glow toggle booleans in the entity's 
    % class these can then be set to true/false to enable the glow in game
    ToggleAddress is GlowObject + ((GlowIndex * 56) + 36),
    ToggleAddress1 is GlowObject + ((GlowIndex * 56) + 37),

    % Write the RGB and opacity component changes to the game's memory
    write_float(Handle, RAddress, 2),
    write_float(Handle, GAddress, 0),
    write_float(Handle, BAddress, 0),
    write_float(Handle, OpacityAddress, 1.7),
    
    % Write to the glow toggle boolean's in memory
    write_bool(Handle, ToggleAddress, 1),
    write_bool(Handle, ToggleAddress1, 0),

    % Increment the index and call the write_glow predicate with this new index
    Index1 is Index + 1,
    write_glow(Module, Handle, GlowObject, Team, Index1).

% We use this predicate to continue the "loop" when we encounter an entity
% that's not an enemy
write_glow(Module, Handle, GlowObject, Team, Index):-
    Index < 64,
    Index1 is Index + 1,
    write_glow(Module, Handle, GlowObject, Team, Index1).