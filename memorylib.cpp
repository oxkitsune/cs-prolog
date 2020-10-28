#define PROLOG_MODULE "memorylib"
#include "SWI-cpp.h"
#include <iostream>
#include <windows.h>
#include <TlHelp32.h>
#include <tchar.h>

using namespace std;

/**
 * Predicate used to get the handle to a process
 */ 
PREDICATE (get_process_handle, 2) {

    // Get the proccess name from prolog
    const char * proc = A1;

    // Get the process id handle
    HANDLE hProcessId = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);

    // Create handle
    HANDLE handle;
	DWORD process;

    // Process entry
	PROCESSENTRY32 pEntry;

    // Set the size to the size
	pEntry.dwSize = sizeof(pEntry);

	do
	{
        // Compare the name of the exe to the process name given by prolog
		if (!strcmp(pEntry.szExeFile, proc))
		{

            // Set the process id
			process = pEntry.th32ProcessID;

            // Close the handle we opened earlier
			CloseHandle(hProcessId);

            // Set the handle
			handle = OpenProcess(PROCESS_ALL_ACCESS, false, process);
		}
	} while (Process32Next(hProcessId, &pEntry)); // Loop through all processes

    // Return the handle to prolog
    return A2 = handle;
}

/**
 * Predicate used to get the id of a process
 */ 
PREDICATE (get_process_id, 2) {

    // Get the proccess name from prolog
    const char * proc = A1;

    // Get the process id handle
    HANDLE hProcessId = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);

    // Create process id
	DWORD process;

    // Process entry
	PROCESSENTRY32 pEntry;

    // Set the size to the size
	pEntry.dwSize = sizeof(pEntry);

	do
	{
        // Compare the name of the exe to the process name given by prolog
		if (!strcmp(pEntry.szExeFile, proc))
		{
            // Close the handle we opened earlier
			CloseHandle(hProcessId);

            // Set the process id
			process = pEntry.th32ProcessID;

            return A2 = (int) process;
		} 
	} while (Process32Next(hProcessId, &pEntry)); // Loop through all processes

    // Return the process id to prolog
    return A2 = (int) process;
}

/**
 * Predicate used to get the address of a module in a process
 */ 
PREDICATE (get_module, 3) {

    const char* modName = (const char *) A1;
    DWORD procId = (DWORD) (int) A2;

    // Get the module handle for the process id
    HANDLE hModule = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, procId);

    // Create module entry and set the size
	MODULEENTRY32 mEntry;
	mEntry.dwSize = sizeof(mEntry);

	do
	{
        // Compare the module name to the given name by prolog
		if (!strcmp(mEntry.szModule, modName))
		{
            // Close the module handle
			CloseHandle(hModule);

            // Return the module address to prolog
			return A3 = (int) (DWORD) mEntry.hModule;
		}
	} while (Module32Next(hModule, &mEntry)); // Loop through all modules in the process

    // Didn't find a matching module, return 0
	return A3 = 0;
}

template <class value>
value readMemoryValue (HANDLE handle, DWORD dwAddr) {

    // Create the value
    value val;

    // Read the memory into the value
    ReadProcessMemory(handle, (LPBYTE*)dwAddr, &val, sizeof(val), NULL);

    // Return the value
    return val;
}

PREDICATE (read_byte, 3) {

    // Get the process handle from prolog
    HANDLE handle = A1;
    
    // Get the address of the memory we want to overwrite
    DWORD dwAddr = (DWORD) (int) A2;

    // Read the memory
    BYTE value = readMemoryValue<BYTE>(handle, dwAddr);

    // Return the memory to prolog
    return A3 = value;
}

PREDICATE (read_int, 3) {

    // Get the process handle from prolog
    HANDLE handle = A1;
    
    // Get the address of the memory we want to overwrite
    DWORD dwAddr = (DWORD) (int) A2;

    // Read the memory
    int value = readMemoryValue<int>(handle, dwAddr);

    // Return the memory to prolog
    return A3 = value;
}

PREDICATE (write_int, 3) {

    // Get the process handle from prolog
    HANDLE handle = A1;
    
    // Get the address of the memory we want to overwrite
    DWORD dwAddr = (DWORD) (int) A2;
    
    int value = (int) A3;

    // Write the process memory
    WriteProcessMemory(handle, (LPBYTE*)dwAddr, &value, sizeof(value), NULL);

    // Return true
    return TRUE;
}


PREDICATE (read_float, 3) {

    // Get the process handle from prolog
    HANDLE handle = A1;
    
    // Get the address of the memory we want to overwrite
    DWORD dwAddr = (DWORD) (int) A2;

    // Read the memory
    float value = readMemoryValue<float>(handle, dwAddr);

    // Return the memory to prolog
    return A3 = (double) value;
}

PREDICATE (write_float, 3) {

    // Get the process handle from prolog
    HANDLE handle = A1;
    
    // Get the address of the memory we want to overwrite
    DWORD dwAddr = (DWORD) (int) A2;
    
    float value = (double) A3;

    // Write the process memory
    WriteProcessMemory(handle, (LPBYTE*)dwAddr, &value, sizeof(value), NULL);

    // Return true
    return TRUE;
}

PREDICATE (read_bool, 3) {

    // Get the process handle from prolog
    HANDLE handle = A1;
    
    // Get the address of the memory we want to overwrite
    DWORD dwAddr = (DWORD) (int) A2;

    // Read the memory
    bool value = readMemoryValue<bool>(handle, dwAddr);

    if(value) {
        return A3 = 1;
    }

    return A3 = 0;
}

PREDICATE (write_bool, 3) {

    // Get the process handle from prolog
    HANDLE handle = A1;
    
    // Get the address of the memory we want to overwrite
    DWORD dwAddr = (DWORD) (int) A2;
    
    bool value;

    if((int) A3 == 1) {
        value = true;
    }
    else {
        value = false;
    }

    // Write the process memory
    WriteProcessMemory(handle, (LPBYTE*)dwAddr, &value, sizeof(value), NULL);

    // Return true
    return TRUE;
}

PREDICATE (read_dword, 3) {

    // Get the process handle from prolog
    HANDLE handle = A1;
    
    // Get the address of the memory we want to overwrite
    DWORD dwAddr = (DWORD) (int) A2;

    // Read the memory
    DWORD value = readMemoryValue<DWORD>(handle, dwAddr);

    // Return the memory to prolog
    return A3 = (int) value;
}

PREDICATE (write_dword, 3) {

    // Get the process handle from prolog
    HANDLE handle = A1;
    
    // Get the address of the memory we want to overwrite
    DWORD dwAddr = (DWORD) (int) A2;
    
    DWORD value = (DWORD) (int) A3;

    // Write the process memory
    WriteProcessMemory(handle, (LPBYTE*)dwAddr, &value, sizeof(value), NULL);

    // Return true
    return TRUE;
}

// This shouldn't be in a "memory lib", but I cba to create another DLL
// Just to get keyboard input
PREDICATE(get_async_key_state, 2) {

    if(GetAsyncKeyState((int)A1)){
        return A2 = 1;
    }
    
    return A2 = 0;
}