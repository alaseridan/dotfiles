#NoEnv
#SingleInstance Force
SendMode Input

; --- SETTINGS: UPDATE THIS PATH TO YOUR OBSIDIAN NOTE ---
VaultPath := "C:\Users\nhallahan\Vaults\CollectorsVault\rolling task.md"

; Press F9 from anywhere in Windows
#w::
    ; 1. Turn on Windows Voice Typing (Win + H)
    Send, #h
    
    ; 2. Pop up a small floating input box over your current window
    ; Syntax: InputBox, OutputVar, Title, Prompt, Hide, Width, Height
    InputBox, UserNote, Quick Obsidian Voice Note, Speak your note`, then press Enter to save:, , 400, 120
    
    ; 4. Check that you didn't press Cancel (ErrorLevel = 0) and that text was entered
    if (ErrorLevel = 0 && UserNote != "")
    {
        ; Format as a bullet point on a new line
        FormattedNote := "`n- [ ] " . UserNote
        
        ; Silently append the text directly to your Obsidian Markdown file in UTF-8
        FileAppend, %FormattedNote%, %VaultPath%, UTF-8
    }
return

#+w::
    ; If the viewer window is already open, close it
    IfWinExist, Quick Note Viewer
    {
        Gui, Viewer:Destroy
        return
    }

    ; Read the current text from your Obsidian file (UTF-8)
    FileEncoding, UTF-8
    FileRead, NoteContents, %VaultPath%
    
    ; Handle empty or missing file gracefully
    if (ErrorLevel || NoteContents = "")
        NoteContents := "(Your note is currently empty.)"

    ; Create a clean, always-on-top floating window
    Gui, Viewer:New, +AlwaysOnTop +ToolWindow, Quick Note Viewer
    Gui, Viewer:Font, s10, Segoe UI
    Gui, Viewer:Add, Edit, w450 h350 ReadOnly, %NoteContents%
    Gui, Viewer:Add, Button, Default w80 gCloseViewer, Close (Esc)
    Gui, Viewer:Show
return

; Close the viewer when pressing Escape or clicking the Close button
ViewerGuiEscape:
CloseViewer:
    Gui, Viewer:Destroy
return
