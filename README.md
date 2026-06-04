## MyTaskbar

**Taskbar personalizzata per macOS** costruita con SwiftUI + AppKit.

### Requisiti
- macOS 14.0 Sonoma o superiore
- Xcode 16 o superiore

### Come compilare (metodo consigliato - XcodeGen)

1. Clona la repository:
   ```bash
   git clone https://github.com/Vale717171/MyTaskbar.git
   cd MyTaskbar
   ```

2. Installa XcodeGen (una sola volta):
   ```bash
   brew install xcodegen
   ```

3. Genera il progetto Xcode:
   ```bash
   xcodegen generate
   ```

4. Apri il progetto generato:
   ```bash
   open MyTaskbar.xcodeproj
   ```

5. Compila e avvia (`Cmd + R`)

### Struttura del progetto
```
MyTaskbar/
├── MyTaskbar.xcodeproj/     # Generato da XcodeGen
├── MyTaskbar/               # Codice sorgente
│   ├── MyTaskbarApp.swift
│   ├── AppDelegate.swift
│   ├── TaskbarView.swift
│   ├── TaskbarViewModel.swift
│   ├── StartMenuView.swift
│   └── Info.plist
├── project.yml              # Configurazione XcodeGen
├── README.md
└── .gitignore
```

### Funzionalità MVP implementate
- Finestra borderless sempre in basso
- Elenco delle app in esecuzione (aggiornato ogni secondo)
- Click su icona → porta l'app in primo piano
- Pulsante "Start" che apre un pannello con ricerca app
- Lancio di app da /Applications e ~/Applications

### Note
- Il progetto usa `NSWindow` + `NSHostingView` per il controllo preciso della finestra (non possibile solo con SwiftUI).
- Per lo sviluppo futuro: multi-monitor, drag & drop, miniature, impostazioni.