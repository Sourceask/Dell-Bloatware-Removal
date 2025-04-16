# Dell Bloatware Removal Tool

This PowerShell script is designed to **silently uninstall Dell-branded software** from Windows systems. It targets known **MSI and EXE-based bloatware**, scans for additional installed Dell software via the registry, and cleans up Dell-related services and scheduled tasks.

---

## 🔧 Features

- ✅ Uninstalls known Dell apps via **MSI GUIDs**
- ✅ Executes silent uninstalls of **EXE-based Dell apps**
- ✅ Dynamically finds and removes **additional Dell entries** via registry
- ✅ Removes **Dell services** and **scheduled tasks**
- ✅ Logs all actions and errors to `C:\Temp\DellBloatwareRemoval.log`

---

## ⚠️ Warning

This tool is **aggressive**. It will remove a wide range of Dell software including:

- Dell Update
- Dell SupportAssist
- Dell Digital Delivery
- Dell Power Manager
- Dell Optimizer
- Dell Peripheral/Display Manager
- Foundation/Core/Watchdog services

**Use in production environments with caution.**

---

## 📂 Installation

1. Save the script as `RemoveDellBloatware.ps1`.

2. Open **PowerShell as Administrator**.

3. Optional: Bypass script execution policy for the session:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force

   .\RemoveDellBloatware.ps1
  ```
