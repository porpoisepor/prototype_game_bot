;MEMORY TESTS ===========================================================================

    ;printMana()
    printMana(){
        debugClear("")
        programName := "Tibia"
        ;programName := "Tibia.exe"
        baseAddress := 0x000000
        ;baseAddress := 0x0001654
        ;baseAddress := 0x9460301
        ;baseAddress := 0x00de0000
        mana := ReadMemory8byte(0x57048C, programName)
        maxMana := ReadMemory8byte(0x57045C, programName)
        xorValue := ReadMemory8byte(0x570458, programName)
        level := ReadMemory8byte(0x570470, programName)

        ;SetFormat, Integer, hex
        ;mana += 0
        ;maxMana += 0
        ;xorValue += 0
        ;level += 0

        ;mana := ReadMemory4byte(baseAddress + 0x0135048c, programName)
        ;maxMana := ReadMemory4byte(baseAddress + 0x0135045c, programName)
        ;xorValue := ReadMemory4byte(baseAddress + 0x01350458, programName)
        ;level := ReadMemory4byte(baseAddress + 0x01350470, programName)

        ;SetFormat, Integer, d

        xoredMana := mana ^ xorValue
        xoredMaxMana := maxMana ^ xorValue
        xoredLevel := level ^ xorValue
        debugPrint("mana: " mana)
        debugPrint("maxMana: " maxMana)
        debugPrint("xorValue: " xorValue)
        debugPrint("level: " level)

        debugPrint("xoredMana: " xoredMana)
        debugPrint("xoredMaxMana: " xoredMaxMana)
        debugPrint("xoredLevel: " xoredLevel)
        ;xorTest := 0x1243357944 ^ 0x1243358457
        ;xorTest := 1243360680 ^ 1243358457
        ;xorTest := "1243360680" ^ "1243358457"
        xorTest := "0x1243360680" ^ "0x1243358457"
        xorA := "1243360680"
        xorB := "1243358457"
        xorC := xorA ^ xorB
        debugPrint("xorTest: " xorTest)
        debugPrint("xorC: " xorC)
    }

    WriteMemory(WVALUE,MADDRESS,PROGRAM){
        winget, pid, PID, %PROGRAM%
        ProcessHandle := DllCall("OpenProcess", "int", 2035711, "char", 0, "UInt", PID, "UInt")
        DllCall("WriteProcessMemory", "UInt", ProcessHandle, "UInt", MADDRESS, "float*", WVALUE, "Uint", 8, "Uint *", 0)
        DllCall("CloseHandle", "int", ProcessHandle)
        return
    }
    ReadMemory(MADDRESS,PROGRAM){
        winget, pid, PID, %PROGRAM%
        VarSetCapacity(MVALUE,4,0)
        ProcessHandle := DllCall("OpenProcess", "Int", 24, "Char", 0, "UInt", pid, "UInt")
        DllCall("ReadProcessMemory","UInt",ProcessHandle,"UInt",MADDRESS,"Float*",float,"UInt",8,"UInt *",0)
        DllCall("CloseHandle", "int", ProcessHandle)
        return, float
    }
    ReadMemory4byte(MADDRESS,PROGRAM){
        winget, pid, PID, %PROGRAM%
        VarSetCapacity(MVALUE,4,0)
        ProcessHandle := DllCall("OpenProcess", "Int", 24, "Char", 0, "UInt", pid, "UInt")
        DllCall("ReadProcessMemory","UInt",ProcessHandle,"UInt",MADDRESS,"Str",MVALUE,"UInt",4,"UInt *",0)
        DllCall("CloseHandle", "int", ProcessHandle)
        Loop 4
            ;debugPrint(MVALUE)
            result += *(&MVALUE + A_Index-1) << 8*(A_Index-1)
            ;debugPrint("result:" result)
        return, result 
    }
    ReadMemory8byte(MADDRESS,PROGRAM){
        winget, pid, PID, %PROGRAM%
        VarSetCapacity(MVALUE,4,0)
        ProcessHandle := DllCall("OpenProcess", "Int", 24, "Char", 0, "UInt", pid, "UInt")
        DllCall("ReadProcessMemory","UInt",ProcessHandle,"UInt",MADDRESS,"Str",MVALUE,"UInt",8,"UInt *",0)
        DllCall("CloseHandle", "int", ProcessHandle)
        Loop 4
            result += *(&MVALUE + A_Index-1) << 8*(A_Index-1)
        return, result 
    }
    ReadMemoryString(MADDRESS,PROGRAM) { 
        winget, pid, PID, %PROGRAM% 
        ProcessHandle := DllCall("OpenProcess", "Int", 24, "Char", 0, "UInt", pid, "Uint")
        teststr =
        Loop 32  {
           Output := "x"  ; Put exactly one character in as a placeholder. used to break loop on null
           tempVar := DllCall("ReadProcessMemory", "UInt", ProcessHandle, "UInt", MADDRESS, "str", Output, "Uint", 1, "Uint *", 0)
           if (ErrorLevel or !tempVar)  {
              DllCall("CloseHandle", "int", ProcessHandle)
              return teststr
           }
          ; if Output =
          ;  break
           teststr = %teststr%%Output%
           MADDRESS++
        }
        DllCall("CloseHandle", "int", ProcessHandle)
        return, teststr  
    }
    GetDllBase(DllName, PID = 0){
        TH32CS_SNAPMODULE := 0x00000008
        INVALID_HANDLE_VALUE = -1
        VarSetCapacity(me32, 548, 0)
        NumPut(548, me32)
        snapMod := DllCall("CreateToolhelp32Snapshot", "Uint", TH32CS_SNAPMODULE
                                                     , "Uint", PID)
        If (snapMod = INVALID_HANDLE_VALUE) {
            Return 0
        }
        If (DllCall("Module32First", "Uint", snapMod, "Uint", &me32)){
            while(DllCall("Module32Next", "Uint", snapMod, "UInt", &me32)) {
                If !DllCall("lstrcmpi", "Str", DllName, "UInt", &me32 + 32) {
                    DllCall("CloseHandle", "UInt", snapMod)
                    Return NumGet(&me32 + 20)
                }
            }
        }
        DllCall("CloseHandle", "Uint", snapMod)
        Return 0
    }
    ReadMemoryOld(MADDRESS,PROGRAM){
        winget, pid, PID, %PROGRAM%
        VarSetCapacity(MVALUE,4,0)
        ProcessHandle := DllCall("OpenProcess", "Int", 24, "Char", 0, "UInt", pid, "UInt")
        DllCall("ReadProcessMemory","UInt",ProcessHandle,"UInt",MADDRESS,"Str",MVALUE,"UInt",4,"UInt *",0)
        Loop 4
            result += *(&MVALUE + A_Index-1) << 8*(A_Index-1)
        return, result  
    }

;========================================================================================