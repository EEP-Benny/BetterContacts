# BetterContacts

`BetterContacts` macht Kontaktpunkte besser: In das Eingabefeld für Lua-Aufrufe können nun auch Funktionsparameter eingegeben werden.
`BetterContacts` ist der Nachfolger meiner berühmten „Codezeile“, die die selbe Funktion hatte. Die Auslagerung in ein separates Modul macht den Code übersichtlicher und fasst mehrere Varianten der ursprünglichen Codezeile zusammen.

### Schnellstart-Anleitung

#### 1. Installieren

Nach dem [Download](http://emaps-eep.de/lua/bettercontacts) die zip-Datei in EEP über den Menüpunkt „Modelle installieren“ installieren (gibt es erst ab EEP13), ansonsten die zip-Datei entpacken und die `Installation.eep` aufrufen, oder die `BetterContacts_BH2.lua` von Hand ins EEP-Verzeichnis in den Unterordner `LUA` kopieren.

#### 2. Einbinden

Füge diese Zeile an den Anfang des Anlagen-Skripts ein:

```lua
require("BetterContacts_BH2")
```

##### 2.1. Vorzeitigen Lua-Stopp verhindern

Stelle sicher, dass die Funktion `EEPMain` niemals mittels `return 0` beendet wird (sondern immer mit `return 1`).
Leider enthält das Standardskript ab EEP16 ein `return 0`. Falls noch nicht geschehen, entferne die folgende Zeile:

```lua
    if (I>9) then return 0 end
```

#### 3. Aktivieren

Schalte in den 3D-Modus, sodass Lua einmal ausgeführt wird.

#### 4. Verwenden

Jetzt kannst du beliebige Lua-Befehle in die Kontaktpunkte schreiben, insbesondere auch Funktionsaufrufe mit Parametern. Der Name des aktuellen Zugs steht dabei in der Variablen `Zugname` zur Verfügung.

##### Beispiele für Kontaktpunkt-Einträge

- Der folgende Eintrag schreibt den Namen des Zuges mittels `print` ins Ereignisfenster:
  ```lua
  print("Der Kontaktpunkt wurde vom Zug ", Zugname, " ausgelöst!")
  ```

* Der folgende Eintrag ruft den nächsten Zug aus dem Depot 2 ab (sofern du eine entsprechende `function ZugAusDepot(depotNummer)` im Skript definiert hast):
  ```lua
  ZugAusDepot(2)
  ```
* Der folgende Eintrag registriert den Zug für Signal 1234 (sofern du eine entsprechende `function RegistriereZugAnSignal(zugname, signalId)` im Skript definiert hast):
  ```lua
  RegistriereZugAnSignal(Zugname, 1234)
  ```
