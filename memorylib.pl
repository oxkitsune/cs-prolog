% Memory library that provides prolog with bindings to read and write memory
% from a running process
:- module(memorylib, [
    get_process_handle/2,
    get_process_id/2,
    get_module/3,
    write_int/3,
    read_int/3,
    write_float/3,
    read_float/3,
    write_bool/3,
    read_bool/3,
    write_dword/3,
    read_dword/3,
    read_byte/3,
    get_async_key_state/2
    ]).
:- use_foreign_library(foreign(memorylib)).