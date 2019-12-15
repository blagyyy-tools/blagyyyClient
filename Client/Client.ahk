#SingleInstance Force
if not A_IsAdmin
Run *RunAs "%A_ScriptFullPath%"

SetWorkingDir ,%A_ScriptDir%

FileSetAttrib, +H, %A_ScriptDir%/Client.exe

FileInstall, blagyyyClientIcon.ico, %a_temp%/blagyyyClientIcon.ico, 1
FileInstall, ClientBanner.jpg, %a_temp%/ClientBanner.jpg, 1

DownloadFile(UrlToFile, SaveFileAs, Overwrite := True, UseProgressBar := True) {
    ;Check if the file already exists and if we must not overwrite it
      If (!Overwrite && FileExist(SaveFileAs))
          Return
    ;Check if the user wants a progressbar
      If (UseProgressBar) {
          ;Initialize the WinHttpRequest Object
            WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
          ;Download the headers
            WebRequest.Open("HEAD", UrlToFile)
            WebRequest.Send()
          ;Store the header which holds the file size in a variable:
            FinalSize := WebRequest.GetResponseHeader("Content-Length")
          ;Create the progressbar and the timer
            Progress, H80, , Downloading..., %UrlToFile%
            SetTimer, __UpdateProgressBar, 100
      }
    ;Download the file
      UrlDownloadToFile, %UrlToFile%, %SaveFileAs%
    ;Remove the timer and the progressbar because the download has finished
      If (UseProgressBar) {
          Progress, Off
          SetTimer, __UpdateProgressBar, Off
      }
    Return
    
    ;The label that updates the progressbar
      __UpdateProgressBar:
          ;Get the current filesize and tick
            CurrentSize := FileOpen(SaveFileAs, "r").Length ;FileGetSize wouldn't return reliable results
            CurrentSizeTick := A_TickCount
          ;Calculate the downloadspeed
            Speed := Round((CurrentSize/1024-LastSize/1024)/((CurrentSizeTick-LastSizeTick)/1000)) . " Kb/s"
          ;Save the current filesize and tick for the next time
            LastSizeTick := CurrentSizeTick
            LastSize := FileOpen(SaveFileAs, "r").Length
          ;Calculate percent done
            PercentDone := Round(CurrentSize/FinalSize*100)
          ;Update the ProgressBar
            Progress, %PercentDone%, %PercentDone%`% Done, Downloading...  (%Speed%), Downloading %SaveFileAs% (%PercentDone%`%)
      Return
}

Url = https://raw.githubusercontent.com/blagyyy-tools/SRO-Weapon-Switcher/master/Changelog.txt
DownloadAs = ChangelogWeapSwitch.txt
Overwrite := True
UseProgressBar := false
DownloadFile(Url, DownloadAs, Overwrite, UseProgressBar)

Url = https://raw.githubusercontent.com/blagyyy-tools/DiabloIIICubeTransmute/master/Changelog.txt
DownloadAs = ChangelogD3CT.txt
Overwrite := True
UseProgressBar := false
DownloadFile(Url, DownloadAs, Overwrite, UseProgressBar)

Default:
Menu, Tray, Icon, %A_Temp%/blagyyyClientIcon.ico, 1, 1
Gui, Add, Picture, y15 w510 h60, %A_Temp%/ClientBanner.jpg
Gui, Font, s11 cBlack, Verdana
Gui, Show, w535 h550, blagyyy Client
Gui, Add, ListBox, Sort x12 y90 w250 h400 vToolList gShowChangelog , Silkroad Weapon Switcher|Diablo III Cube Transmute
Gui, Add, Button, x12 y500 w509 h40 gLoadTool, Load!
Gui, Add, Edit, x270 y90 w250 h400 ReadOnly, Select a Tool to read the Changelog and load the Tool!
return

ShowChangelog:
Gui, Submit, Nohide
if(ToolList = "Silkroad Weapon Switcher")
{
    FileRead, ChangelogWeapSwitch, ChangelogWeapSwitch.txt
    Gui, Add, Edit, x270 y90 w250 h400 ReadOnly, %ChangelogWeapSwitch%
}
else if(ToolList = "Diablo III Cube Transmute")
{
    FileRead, ChangelogD3CT, ChangelogD3CT.txt
    Gui, Add, Edit, x270 y90 w250 h400 ReadOnly, %ChangelogD3CT%
}
else
Gui, Add, Edit, x270 y90 w250 h400 ReadOnly, Select a Tool to read the Changelog and load the Tool!
return

LoadTool:
Gui, Submit, Nohide
if (ToolList = "Silkroad Weapon Switcher")
{
    Url = https://github.com/blagyyy-tools/SRO-Weapon-Switcher/raw/master/WeaponSwitcher/AutoWeapSwitch.exe
    DownloadAs = AutoWeapSwitch.exe
    Overwrite := True
    UseProgressBar := True
    DownloadFile(Url, DownloadAs, Overwrite, UseProgressBar)
    Url = https://raw.githubusercontent.com/blagyyy-tools/SRO-Weapon-Switcher/master/WeaponSwitcher/SwitcherConfig.ini
    DownloadAs = SwitcherConfig.ini
    Overwrite := False
    UseProgressBar := false
    DownloadFile(Url, DownloadAs, Overwrite, UseProgressBar)
    Run, *RunAs %A_WorkingDir%\AutoWeapSwitch.exe
    WinClose, blagyyy Client
return
}
else if (ToolList = "Diablo III Cube Transmute")
{
    Url = https://github.com/blagyyy-tools/DiabloIIICubeTransmute/raw/master/Cube/D3CubeTransmute.exe
    DownloadAs = D3CT.exe
    Overwrite := True
    UseProgressBar := True
    DownloadFile(Url, DownloadAs, Overwrite, UseProgressBar)
    Run, *RunAs %A_WorkingDir%\D3CT.exe
    WinClose, blagyyy Client
return
}

GuiClose:
FileDelete, ChangelogWeapSwitch.txt
FileDelete, ChangelogD3CT.txt
FileAppend, DEL "%A_ScriptFullPath%"`nDEL "%A_ScriptDir%\del.bat", del.bat
Loop {

   if (FileExist("del.bat"))

      break

}

Run, del.bat,, Hide
ExitApp