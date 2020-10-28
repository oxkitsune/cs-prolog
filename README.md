# cs-prolog
A csgo "multi-hack" written in prolog using RPM/WPM bindings written in c++

# Building memorylib
To build memorylib (for use in swi-prolog) [SWI-Prolog](https://www.swi-prolog.org/) and [g++](https://gcc.gnu.org/) (use [MinGW](http://www.mingw.org/) on windows) need to be installed.

MAKE SURE %SWI_HOME_DIR% POINTS TO YOUR SWI-PROLOG INSTALLATION

memorylib can be compiled using the following g++ commands:

```bash
g++.exe -c -D_REENTRANT -D__WINDOWS__ -D_WINDOWS -D__SWI_PROLOG__ -I "%SWI_HOME_DIR%include" -o memorylib.obj memorylib.cpp

g++.exe -o memorylib.dll -shared memorylib.obj -L "%SWI_HOME_DIR%\bin" -lswipl
```

# Running the cheat
1. Start csgo and get into a game.

2. Start swi-prolog and consult `cs-prolog.pl` 
    ```bash
    swipl cs-prolog.pl
    ```
3. Once SWI-Prolog loads all the modules/DLLs hook into CSGO using the `hook/0 `predicate, it should say "Hooked into csgo!"
    ```
    ?- hook.
    Hooked into csgo!
    true.
    ```
4. Start the `glowhack/0` or `bhop/0` predicate to use the cheat
    ```
    ?- glowhack.

    ```

To stop using either of the hacks, simply press `CTRL + C` to stop the Prolog execution.
