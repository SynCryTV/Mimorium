# Mimorium

Ein leichtes WoW-Addon für Emotes, Gesten und kleine Rollenspiel-Momente.

## Aktueller Stand

Die technische Basis steht. Das Addon lässt sich mit `/mimorium` oder `/mimo`
öffnen; als Nächstes folgen Kategorien, Favoriten und die Emote-Sammlung.

## Installation

### Über WowUp

1. In WowUp **Get Addons** öffnen.
2. **Install from URL** wählen.
3. Die URL dieses GitHub-Repositories einfügen.

WowUp lädt immer die automatisch erzeugte Release-ZIP herunter. Sie wird bei
jedem Push auf `main` aus der Version in `Mimorium.toc` erstellt.

### Manuell

Den Repository-Ordner als `Mimorium` nach
`World of Warcraft/_retail_/Interface/AddOns/` kopieren.

## Entwicklung

- Die Addon-Metadaten und Lade-Reihenfolge liegen in `Mimorium.toc`.
- Die Version wird im TOC gepflegt und beim Laden gelesen.
- Bei einem Release die `## Version:` in `Mimorium.toc` und den Changelog
  aktualisieren, dann nach `main` pushen. GitHub Actions erstellt die ZIP und
  das Release automatisch.
- Globale gespeicherte Einstellungen: `MimoriumDB`; charakterbezogene: `MimoriumCharDB`.
