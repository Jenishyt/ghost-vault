@ECHO OFF
cd /d "%~dp0"
setlocal EnableDelayedExpansion

:: ============================================================
::  SECURE VAULT v4.1 by jenishexe
:: ============================================================

set "APPDATA_DIR=%APPDATA%\Microsoft\Windows\Themes\jenishexe"
set "VAULT_DIR=%APPDATA_DIR%\store"
set "PASS_FILE=%VAULT_DIR%\sys_cache.dat"
set "RK_FILE=%VAULT_DIR%\sys_rk.dat"
set "LOCK_FILE=%VAULT_DIR%\sys_lock.dat"
set "ATTEMPT_FILE=%VAULT_DIR%\sys_att.tmp"
set "NAME_FILE=%VAULT_DIR%\sys_name.dat"
set "LOC_FILE=%VAULT_DIR%\sys_loc.dat"
set "SEVENZIP=C:\Program Files\7-Zip\7z.exe"

if not exist "%SEVENZIP%" set "SEVENZIP=C:\Program Files (x86)\7-Zip\7z.exe"
if not exist "%SEVENZIP%" (
    call :FAKE_ERROR
    goto END
)

:: Verify bat file has not been renamed
if exist "%NAME_FILE%" (
    set /p "EXPECTED_NAME=" < "%NAME_FILE%"
    set "CURRENT_NAME=%~nx0"
    if not "!CURRENT_NAME!"=="!EXPECTED_NAME!" (
        call :FAKE_ERROR
        goto END
    )
)

:: Set vault location
if exist "%LOC_FILE%" (
    set /p "VAULT_LOC=" < "%LOC_FILE%"
) else (
    set "VAULT_LOC=%~dp0"
)
set "TEMP_DIR=!VAULT_LOC!Private"

:: Route to correct flow
if not exist "%VAULT_DIR%" goto SETUP
if not exist "%PASS_FILE%" goto SETUP
if not exist "%RK_FILE%" goto SETUP
if exist "%TEMP_DIR%" goto LOCK_FLOW
goto FAKE_ERROR

:: ============================================================
:FAKE_ERROR
:: ============================================================
cls
echo.
echo.
echo   ================================================================
echo.
echo      This file seems corrupted and cannot be opened.
echo.
echo      Windows was unable to read the file or access the
echo      required system resources to complete this operation.
echo.
echo      Error Code: 0x80070570 - FILE_CORRUPT
echo.
echo   ================================================================
echo.
echo   [1] Close
echo   [2] Try Anyway
echo.
set /p "fchoice=>  "
if "!fchoice!"=="1" goto END
if "!fchoice!"=="2" goto REAL_AUTH
goto END

:REAL_AUTH
cls
echo.
echo   Verifying system integrity...
echo.
timeout /t 1 /nobreak >nul
if not exist "%VAULT_DIR%" goto SETUP
if not exist "%PASS_FILE%" goto SETUP
if exist "%TEMP_DIR%" goto LOCK_FLOW
goto UNLOCK_FLOW

:: ============================================================
:HASH_PASSWORD
:: ============================================================
set "HASH_TMP=%TEMP%\svhash.tmp"
> "!HASH_TMP!" echo !PLAIN_PASS!
set "HASHED="
for /f "skip=1 tokens=1" %%H in ('certutil -hashfile "!HASH_TMP!" SHA256 2^>nul') do (
    if not defined HASHED set "HASHED=%%H"
)
del /f /q "!HASH_TMP!" 2>nul
goto :EOF

:: ============================================================
:SETUP
:: ============================================================
cls
echo.
echo   ================================================================
echo.
echo         Welcome to Secure Vault
echo         Developed by jenishexe
echo.
echo   ================================================================
echo.
echo   Thank you for using Secure Vault!
echo   This app lets you lock and hide your private files so that
echo   nobody else can see or open them — not even on your own PC.
echo.
echo   Here is how it works:
echo.
echo   1. After setup, a folder called "Private" will be created.
echo   2. Put any files you want to hide inside that folder.
echo   3. Run this file again to lock everything with your password.
echo   4. When locked, the Private folder completely disappears.
echo   5. Run this file again and enter your password to get it back.
echo.
echo   ----------------------------------------------------------------
echo.
echo   IMPORTANT THINGS TO REMEMBER:
echo.
echo   - You will create a PASSWORD to lock and unlock your files.
echo   - You will also get a RECOVERY KEY — this is a backup code
echo     in case you ever forget your password.
echo   - Write the recovery key on paper and keep it somewhere safe.
echo   - If you lose BOTH your password AND recovery key,
echo     your files cannot be recovered by anyone — including us.
echo   - Do NOT rename this file manually or it will stop working.
echo.
echo   ----------------------------------------------------------------
echo.
echo   SETTINGS TIP:
echo   When your vault is UNLOCKED, run this file and press S
echo   at the lock screen to access Settings.
echo.
echo   ================================================================
echo.
echo   Press any key to begin setup...
pause >nul

cls
echo.
echo   ============================================================
echo    SETUP - Step 1 of 4 : Choose a name for this vault file
echo   ============================================================
echo.
echo   This will be the name of the file you see on your computer.
echo   Example: MyVault  or  PersonalFiles  or  Projects
echo   (Do not include .bat at the end — it will be added for you)
echo.
set /p "DNAME=>  Enter a name: "
if "!DNAME!"=="" set "DNAME=SecureVault"

cls
echo.
echo   ============================================================
echo    SETUP - Step 2 of 4 : Create your password
echo   ============================================================
echo.
echo   This password will be used every time you want to open
echo   your vault. Choose something you will remember.
echo.
echo   Tips for a strong password:
echo   - Use a mix of letters and numbers (example: Blue#Sky99)
echo   - Avoid simple passwords like 1234 or your name
echo   - Do NOT share this password with anyone
echo.
set /p "pass1=>  Enter new password: "
if "!pass1!"=="" (
    echo.
    echo   Password cannot be empty. Please try again.
    pause
    goto SETUP
)
set /p "pass2=>  Type the password again to confirm: "
if not "!pass1!"=="!pass2!" (
    echo.
    echo   The passwords you entered do not match. Please try again.
    pause
    goto SETUP
)

:: Hash the password
set "PLAIN_PASS=!pass1!"
call :HASH_PASSWORD
set "HASHED_PASS=!HASHED!"

cls
echo.
echo   ============================================================
echo    SETUP - Step 3 of 4 : Your Recovery Key
echo   ============================================================
echo.
echo   A Recovery Key is a special backup code that lets you
echo   reset your password if you ever forget it.
echo.
echo   On the next screen, your Recovery Key will be shown.
echo   You MUST write it down on paper right now.
echo.
echo   DO NOT save it on this computer — keep it offline.
echo   Example: write it in a notebook or on a piece of paper.
echo.
echo   This key will NEVER be shown again after this step.
echo.
echo   Press any key when you are ready to see your Recovery Key...
pause >nul

set "R1=%RANDOM%%RANDOM%"
set "R2=%RANDOM%%RANDOM%"
set "R3=%RANDOM%%RANDOM%"
set "RK=SVK-%R1%-%R2%-%R3%"

:: Hash the recovery key
set "PLAIN_PASS=!RK!"
call :HASH_PASSWORD
set "HASHED_RK=!HASHED!"

cls
echo.
echo   ============================================================
echo    YOUR RECOVERY KEY — WRITE THIS DOWN RIGHT NOW
echo   ============================================================
echo.
echo.
echo         !RK!
echo.
echo.
echo   ============================================================
echo.
echo   Write the above code on paper before pressing any key.
echo   It will disappear from this screen and never show again.
echo.
pause

cls
echo.
echo   ============================================================
echo    SETUP - Step 4 of 4 : Confirm your Recovery Key
echo   ============================================================
echo.
echo   Please type the Recovery Key you just wrote down.
echo   This confirms you have saved it correctly.
echo.
set /p "rkconfirm=>  Enter your Recovery Key: "
if not "!rkconfirm!"=="!RK!" (
    echo.
    echo   That does not match. Setup cancelled.
    echo   Please run this file again to restart setup.
    pause
    goto END
)

:: Save vault data to AppData
mkdir "%APPDATA_DIR%" 2>nul
mkdir "%VAULT_DIR%" 2>nul
attrib +h +s "%APPDATA_DIR%" 2>nul

> "%PASS_FILE%" echo !HASHED_PASS!
> "%RK_FILE%" echo !HASHED_RK!
> "%NAME_FILE%" echo !DNAME!.bat
> "%LOC_FILE%" echo %~dp0

attrib +h +s "%PASS_FILE%" 2>nul
attrib +h +s "%RK_FILE%" 2>nul
attrib +h +s "%NAME_FILE%" 2>nul
attrib +h +s "%LOC_FILE%" 2>nul

:: Rename bat file to chosen display name
set "NEW_BAT=%~dp0!DNAME!.bat"
if not "%~f0"=="!NEW_BAT!" (
    copy "%~f0" "!NEW_BAT!" >nul 2>&1
    if exist "!NEW_BAT!" (
        del /f /q "%~f0" >nul 2>&1
    )
)

:: Create Private folder
mkdir "%~dp0Private" 2>nul

cls
echo.
echo   ============================================================
echo    SETUP COMPLETE!
echo   ============================================================
echo.
echo   Your vault is ready. Here is what to do next:
echo.
echo   1. A folder called "Private" has been created for you.
echo   2. Open that folder and put your files inside it.
echo   3. Run !DNAME!.bat again when you want to lock your files.
echo   4. To open your files later, run !DNAME!.bat and
echo      enter your password.
echo.
echo   To access Settings: run the bat file when vault is
echo   unlocked and press S at the lock screen.
echo.
echo                   Developed by jenishexe
echo.
pause
goto END

:: ============================================================
:LOCK_FLOW
:: ============================================================
cls
echo.
echo   ============================================================
echo    SECURE VAULT — Your vault is currently UNLOCKED
echo   ============================================================
echo.
echo   [Y] Lock my files now (files will be hidden and encrypted)
echo   [S] Open Settings
echo   [N] Cancel
echo.
set /p "lcho=>  Your choice: "
if /i "!lcho!"=="S" goto SETTINGS
if /i "!lcho!"=="N" goto END
if /i not "!lcho!"=="Y" goto LOCK_FLOW

:: Close common apps that may lock files — no Explorer kill
echo.
echo   Closing apps that may have files open...
taskkill /f /im notepad.exe >nul 2>&1
taskkill /f /im notepad++.exe >nul 2>&1
taskkill /f /im WINWORD.EXE >nul 2>&1
taskkill /f /im EXCEL.EXE >nul 2>&1
taskkill /f /im POWERPNT.EXE >nul 2>&1
taskkill /f /im AcroRd32.exe >nul 2>&1
taskkill /f /im Acrobat.exe >nul 2>&1
taskkill /f /im mspaint.exe >nul 2>&1
taskkill /f /im vlc.exe >nul 2>&1
taskkill /f /im Photos.exe >nul 2>&1
taskkill /f /im dllhost.exe >nul 2>&1
timeout /t 1 /nobreak >nul

set /p "STORED_HASH=" < "%PASS_FILE%"

echo   Locking and encrypting your files...
echo.

"%SEVENZIP%" a -tzip -mem=AES256 -p"!STORED_HASH!" -r "%VAULT_DIR%\secure.7z" "!TEMP_DIR!\*" >nul 2>&1

if errorlevel 1 (
    echo.
    echo   Could not lock vault.
    echo   Make sure the Private folder has at least one file inside it.
    pause
    goto END
)

rd /s /q "!TEMP_DIR!" 2>nul
> "%LOCK_FILE%" echo LOCKED
attrib +h +s "%LOCK_FILE%" 2>nul

:: Bring CMD window back to focus without killing Explorer
powershell -command "(New-Object -ComObject Shell.Application).Windows() | Out-Null" >nul 2>&1

cls
echo.
echo   ============================================================
echo    Vault locked successfully!
echo   ============================================================
echo.
echo   Your files are now hidden and encrypted.
echo   Nobody can access them without your password.
echo   Run this file again when you want to unlock.
echo.
pause
goto END

:: ============================================================
:UNLOCK_FLOW
:: ============================================================
if not exist "%ATTEMPT_FILE%" > "%ATTEMPT_FILE%" echo 0
set /p "ATTEMPTS=" < "%ATTEMPT_FILE%"
if "!ATTEMPTS!"=="3" goto RECOVERY_PHASE

cls
echo.
echo   ============================================================
echo    SECURE VAULT — Enter your password to unlock
echo   ============================================================
echo.
echo   You have !ATTEMPTS! failed attempt(s) so far.
echo   After 3 wrong attempts, you will need your Recovery Key.
echo.
set /p "UPASS=>  Password: "

set "PLAIN_PASS=!UPASS!"
call :HASH_PASSWORD
set "ENTERED_HASH=!HASHED!"
set /p "STORED_HASH=" < "%PASS_FILE%"

if not "!ENTERED_HASH!"=="!STORED_HASH!" (
    set /a "ATTEMPTS+=1"
    > "%ATTEMPT_FILE%" echo !ATTEMPTS!
    cls
    echo.
    echo   Wrong password. Attempt !ATTEMPTS! of 3.
    echo.
    if "!ATTEMPTS!"=="3" (
        echo   Too many wrong attempts. Recovery Key required.
        pause
        goto RECOVERY_PHASE
    )
    pause
    goto UNLOCK_FLOW
)

cls
echo.
echo   Password correct! Unlocking your files...
echo.

mkdir "!TEMP_DIR!" 2>nul
"%SEVENZIP%" x "%VAULT_DIR%\secure.7z" -p"!STORED_HASH!" -o"!TEMP_DIR!" -r >nul 2>&1

if errorlevel 1 (
    rd /s /q "!TEMP_DIR!" 2>nul
    echo   Something went wrong while unlocking. Please try again.
    pause
    goto END
)

del /f /q "%LOCK_FILE%" 2>nul
del /f /q "%VAULT_DIR%\secure.7z" 2>nul
del /f /q "%ATTEMPT_FILE%" 2>nul

cls
echo.
echo   ============================================================
echo    Vault unlocked successfully!
echo   ============================================================
echo.
echo   Your files are in the "Private" folder.
echo   When you are done, run this file again to lock everything.
echo.
pause
goto END

:: ============================================================
:RECOVERY_PHASE
:: ============================================================
cls
echo.
echo   ============================================================
echo    RECOVERY MODE — Too many wrong password attempts
echo   ============================================================
echo.
echo   Enter the Recovery Key you wrote down during setup.
echo   It looks like this: SVK-XXXXX-XXXXX-XXXXX
echo.
set /p "RKINPUT=>  Recovery Key: "

set "PLAIN_PASS=!RKINPUT!"
call :HASH_PASSWORD
set "ENTERED_RK_HASH=!HASHED!"
set /p "STORED_RK_HASH=" < "%RK_FILE%"

if not "!ENTERED_RK_HASH!"=="!STORED_RK_HASH!" (
    cls
    echo.
    echo   That Recovery Key is incorrect. Access denied.
    echo   Make sure you typed it exactly as written.
    echo.
    pause
    goto END
)

cls
echo.
echo   Recovery Key accepted! Please set a new password.
echo   ============================================================
echo.
set /p "NEWPASS1=>  New password: "
set /p "NEWPASS2=>  Confirm new password: "

if not "!NEWPASS1!"=="!NEWPASS2!" (
    echo   Passwords do not match. Please try again.
    pause
    goto RECOVERY_PHASE
)

set "PLAIN_PASS=!NEWPASS1!"
call :HASH_PASSWORD
set "NEW_HASH=!HASHED!"

if exist "%VAULT_DIR%\secure.7z" (
    echo.
    echo   Re-encrypting your files with the new password...
    set /p "OLD_HASH=" < "%PASS_FILE%"
    mkdir "!VAULT_LOC!Private_rec" 2>nul
    "%SEVENZIP%" x "%VAULT_DIR%\secure.7z" -p"!OLD_HASH!" -o"!VAULT_LOC!Private_rec" -r >nul 2>&1
    del /f /q "%VAULT_DIR%\secure.7z" 2>nul
    "%SEVENZIP%" a -tzip -mem=AES256 -p"!NEW_HASH!" -r "%VAULT_DIR%\secure.7z" "!VAULT_LOC!Private_rec\*" >nul 2>&1
    rd /s /q "!VAULT_LOC!Private_rec" 2>nul
)

> "%PASS_FILE%" echo !NEW_HASH!
del /f /q "%ATTEMPT_FILE%" 2>nul

mkdir "!TEMP_DIR!" 2>nul
if exist "%VAULT_DIR%\secure.7z" (
    "%SEVENZIP%" x "%VAULT_DIR%\secure.7z" -p"!NEW_HASH!" -o"!TEMP_DIR!" -r >nul 2>&1
    del /f /q "%VAULT_DIR%\secure.7z" 2>nul
)
del /f /q "%LOCK_FILE%" 2>nul

cls
echo.
echo   Password reset successful! Vault is now unlocked.
echo   Your files are in the Private folder.
echo.
pause
goto END

:: ============================================================
:SETTINGS
:: ============================================================
cls
echo.
echo   ============================================================
echo    SECURE VAULT — SETTINGS
echo   ============================================================
echo.
echo   [1] Rename this vault file
echo   [2] Change password
echo   [3] How to recover data after reinstalling Windows
echo   [4] Permanently delete ALL vault data
echo   [5] Go back
echo.
set /p "schoice=>  Choose an option: "

if "!schoice!"=="1" goto SETTINGS_RENAME
if "!schoice!"=="2" goto SETTINGS_RESETPASS
if "!schoice!"=="3" goto SETTINGS_RECOVER
if "!schoice!"=="4" goto SETTINGS_DELETE
if "!schoice!"=="5" goto LOCK_FLOW
goto SETTINGS

:SETTINGS_RENAME
cls
echo.
echo   RENAME VAULT FILE
echo   ============================================================
echo.
set /p "CURRENT_DNAME=" < "%NAME_FILE%"
echo   Current name: !CURRENT_DNAME!
echo.
echo   Enter a new name (without .bat):
set /p "NEWNAME=>  New name: "
if "!NEWNAME!"=="" goto SETTINGS

echo.
set /p "VERIFY_PASS=>  Enter your password to confirm: "
set "PLAIN_PASS=!VERIFY_PASS!"
call :HASH_PASSWORD
set /p "STORED_HASH=" < "%PASS_FILE%"
if not "!HASHED!"=="!STORED_HASH!" (
    echo   Wrong password. Rename cancelled.
    pause
    goto SETTINGS
)

set "NEW_BAT=%~dp0!NEWNAME!.bat"
copy "%~f0" "!NEW_BAT!" >nul 2>&1
if exist "!NEW_BAT!" (
    > "%NAME_FILE%" echo !NEWNAME!.bat
    del /f /q "%~f0" >nul 2>&1
    cls
    echo.
    echo   Vault file renamed to !NEWNAME!.bat successfully.
    echo.
    pause
    goto END
) else (
    echo   Rename failed. Please try again.
    pause
    goto SETTINGS
)

:SETTINGS_RESETPASS
cls
echo.
echo   CHANGE PASSWORD
echo   ============================================================
echo.
set /p "VERIFY_PASS=>  Enter your current password: "
set "PLAIN_PASS=!VERIFY_PASS!"
call :HASH_PASSWORD
set /p "STORED_HASH=" < "%PASS_FILE%"
if not "!HASHED!"=="!STORED_HASH!" (
    echo   Wrong password.
    pause
    goto SETTINGS
)

set /p "NP1=>  New password: "
set /p "NP2=>  Confirm new password: "
if not "!NP1!"=="!NP2!" (
    echo   Passwords do not match.
    pause
    goto SETTINGS_RESETPASS
)

set "PLAIN_PASS=!NP1!"
call :HASH_PASSWORD
set "NEW_HASH=!HASHED!"

if exist "%VAULT_DIR%\secure.7z" (
    echo.
    echo   Re-encrypting files with new password...
    mkdir "!TEMP_DIR!_rst" 2>nul
    "%SEVENZIP%" x "%VAULT_DIR%\secure.7z" -p"!STORED_HASH!" -o"!TEMP_DIR!_rst" -r >nul 2>&1
    del /f /q "%VAULT_DIR%\secure.7z" 2>nul
    "%SEVENZIP%" a -tzip -mem=AES256 -p"!NEW_HASH!" -r "%VAULT_DIR%\secure.7z" "!TEMP_DIR!_rst\*" >nul 2>&1
    rd /s /q "!TEMP_DIR!_rst" 2>nul
)

> "%PASS_FILE%" echo !NEW_HASH!
echo.
echo   Password changed successfully!
pause
goto SETTINGS

:SETTINGS_RECOVER
cls
echo.
echo   HOW TO RECOVER YOUR DATA AFTER REINSTALLING WINDOWS
echo   ============================================================
echo.
echo   Your encrypted files are stored in a safe location that
echo   survives most Windows reinstalls, as long as your user
echo   folder (C:\Users\YourName\) was not deleted.
echo.
echo   Steps to recover:
echo.
echo   1. Download a fresh copy of SecureVault.bat
echo   2. Place it anywhere on your PC
echo   3. Run it as Administrator
echo   4. It will automatically find your existing vault data
echo   5. Enter your password to unlock your files
echo.
echo   If your entire C drive was wiped, files cannot be recovered
echo   unless you had a separate backup of your vault data.
echo.
pause
goto SETTINGS

:SETTINGS_DELETE
cls
echo.
echo   PERMANENTLY DELETE ALL VAULT DATA
echo   ============================================================
echo.
echo   WARNING: This will delete all your encrypted files FOREVER.
echo   There is NO way to undo this action.
echo.
set /p "confirm=>  Type DELETE to confirm (or anything else to cancel): "
if not "!confirm!"=="DELETE" goto SETTINGS

echo.
set /p "VERIFY_PASS=>  Enter your password to confirm: "
set "PLAIN_PASS=!VERIFY_PASS!"
call :HASH_PASSWORD
set /p "STORED_HASH=" < "%PASS_FILE%"
if not "!HASHED!"=="!STORED_HASH!" (
    echo   Wrong password. Deletion cancelled.
    pause
    goto SETTINGS
)

rd /s /q "%APPDATA_DIR%" 2>nul
rd /s /q "!TEMP_DIR!" 2>nul

cls
echo.
echo   All vault data has been permanently deleted.
echo.
pause
goto END

:END
endlocal
exit /b
