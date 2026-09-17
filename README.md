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

### Manuell

Den Repository-Ordner als `Mimorium` nach
`World of Warcraft/_retail_/Interface/AddOns/` kopieren.

## Entwicklung

- Die Addon-Metadaten und Lade-Reihenfolge liegen in `Mimorium.toc`.
- Die Version wird im TOC gepflegt und beim Laden gelesen.
- Globale gespeicherte Einstellungen: `MimoriumDB`; charakterbezogene: `MimoriumCharDB`.

