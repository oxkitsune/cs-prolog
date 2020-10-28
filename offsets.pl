:- module(offsets, [
    offset_local_player/1,
    offset_flags/1,
    offset_force_jump/1,
    offset_entity_list/1,
    offset_glow_object_manager/1,
    offset_glow_index/1,
    offset_team_num/1
    ]).

% Define all used memory offsets here
% These are generated using hazedumper (https://github.com/frk1/hazedumper)
offset_local_player(0xD3DD14).
offset_flags(0x104).
offset_force_jump(0x51FBFA8).
offset_entity_list(0x4D5239C).
offset_glow_object_manager(0x529A1D0).
offset_glow_index(0xA438).
offset_team_num(0xF4).