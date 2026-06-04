## MyTaskbar

**Taskbar personalizzata per macOS** costruita con SwiftUI + AppKit.

### Requisiti
- macOS 14.0 Sonoma o superiore
- Xcode 16 o superiore

### Come compilare (metodo consigliato)

1. Clona la repository:
   ```bash
   git clone https://github.com/Vale717171/MyTaskbar.git
   cd MyTaskbar
   ```

2. Installa XcodeGen (una sola volta):
   ```bash
   brew install xcodegen
   ```

3. Genera il progetto Xcode (questo crea `MyTaskbar.xcodeproj`):
   ```bash
   xcodegen generate
   ```

4. Apri il progetto:
   ```bash
   open MyTaskbar.xcodeproj
   ```

5. Compila e avvia (`Cmd + R`)

> **Nota importante**: Il file `MyTaskbar.xcodeproj` **non è versionato** nella repository.
> Viene generato automaticamente da `project.yml` tramite XcodeGen.
> Non committare mai `MyTaskbar.xcodeproj`.

### Struttura della repository
```
MyTaskbar/
├── project.yml              # Sorgente di verità per XcodeGen
├── MyTaskbar/               # Codice sorgente dell'app
│   ├── MyTaskbarApp.swift
│   ├── AppDelegate.swift
│   ├── TaskbarView.swift
│   ├── TaskbarViewModel.swift
│   ├── StartMenuView.swift
│   └── Info.plist
├── README.md
└── .gitignore
```

### Funzionalità MVP
- Finestra borderless sempre visibile in basso
- Elenco delle app in esecuzione (aggiornato automaticamente)
- Click sull'icona → porta l'app in primo piano
- Pulsante "Start" con pannello di ricerca e lancio app

### Note tecniche
- Usa `NSWindow` + `NSHostingView` perché SwiftUI puro non permette il controllo preciso della finestra richiesto.
- Per sviluppi futuri: supporto multi-monitor, drag & drop, miniature finestre.