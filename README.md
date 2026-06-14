# GhostVault 👻

**Your files. Invisible. Encrypted. Yours only.**

GhostVault is a portable Windows vault tool that hides and encrypts your private files. No installation needed. When locked, your files completely vanish — no folder, no trace, nothing.

---

## What it does

You get a folder called `Private`. Put your files in it. Run the bat file to lock everything — the folder disappears and your files are encrypted. Run it again to unlock. Simple as that.

Nobody can access your files without your password. Not even if they have physical access to your PC.

---

## Requirements

- Windows 10 or 11
- [7-Zip](https://www.7-zip.org) — free, install at default path

---

## Getting started

1. Install 7-Zip
2. Right-click `GhostVault.bat` → Run as Administrator
3. You'll see a fake error screen — press `2`
4. Follow the setup wizard
5. Put your files in the `Private` folder
6. Run the bat again to lock

---

## How to unlock

Run the bat → press `2` on the error screen → enter your password → done. Your files are back in the `Private` folder.

---

## Settings ⚙️

When the vault is unlocked, run the bat and press `S` instead of `Y`.

From there you can:
- Rename the vault file
- Change your password
- Permanently delete all vault data
- View recovery instructions

---

## Forgot your password? 🔑

Enter the wrong password 3 times. Recovery mode kicks in automatically. Enter the recovery key you saved during setup to reset your password.

> Keep your recovery key written on paper, stored somewhere safe and offline. If you lose both your password and recovery key, your files are gone for good. No exceptions.

---

## After reinstalling Windows

Your vault data survives reinstalls as long as your Windows user folder wasn't wiped. Just drop a fresh copy of `GhostVault.bat` on your PC and run it — it'll find your data automatically.

---

## Things to keep in mind

- Always run as Administrator
- Don't rename the bat file manually — use Settings → Rename instead
- Close any open files from the Private folder before locking
- The recovery key is shown only once during setup — write it down

---

## Compatibility

| | |
|---|---|
| Windows 11 | ✅ |
| Windows 10 | ✅ |
| macOS / Linux | ❌ |

---

project by **jenishexe**
