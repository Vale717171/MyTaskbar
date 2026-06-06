## MyTaskbar

**Taskbar personalizzata per macOS** costruita con SwiftUI + AppKit.

L'obiettivo è sperimentare una barra in stile Windows per macOS: Start menu, app aperte, app fissate, blur, orologio, batteria e comportamento always-on-top.

### Requisiti
- macOS 14.0 Sonoma o superiore
- Xcode 16 o superiore
- XcodeGen

### Come compilare

```bash
git clone https://github.com/Vale717171/MyTaskbar.git
cd MyTaskbar
brew install xcodegen   # se non lo hai già
xcodegen generate
xcodebuild -project MyTaskbar.xcodeproj -scheme MyTaskbar -configuration Debug build
open MyTaskbar.xcodeproj
```

Poi premi `Cmd + R` da Xcode.

> `MyTaskbar.xcodeproj` non è versionato. Viene generato da `project.yml` tramite XcodeGen.

### Struttura della repository

```
MyTaskbar/
├── project.yml
├── README.md
├── .gitignore
└── MyTaskbar/
    ├── MyTaskbarApp.swift
    ├── AppDelegate.swift
    ├── TaskbarView.swift
    ├── TaskbarViewModel.swift
    ├── StartMenuView.swift
    ├── AppInfo.swift
    ├── VisualEffectView.swift
    ├── ClockView.swift
    ├── BatteryView.swift     ← nuovo
    └── Info.plist
```

### Funzionalità attuali

- Finestra borderless in basso, always-on-top.
- Presenza su tutti gli Spaces tramite `collectionBehavior`.
- UI scura con blur/trasparenza.
- Pulsante Start.
- Start menu con ricerca app.
- Elenco app installate da `/Applications` e `~/Applications`.
- App aperte mostrate in taskbar.
- App fissate in stile Windows.
- Menu contestuale per aggiungere/rimuovere app dalla taskbar.
- Indicatore sotto le app aperte e app attiva.
- **Orologio e data** sul lato destro.
- **BatteryView**: percentuale batteria + icona (carica/collegata) usando IOKit.ps. Aggiorna ogni 30 secondi.

### Note tecniche

Questa è una base sperimentale. Alcune funzioni più avanzate richiederanno Accessibility API e permessi macOS:

- miniature finestre;
- elenco finestre per singola app;
- chiusura/minimizzazione finestre;
- supporto multi-monitor completo;
- autohide robusto;
- gestione Dock/Spaces più raffinata.

Prima di aggiungere queste funzioni conviene verificare che la build base passi con `xcodebuild`.