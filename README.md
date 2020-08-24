# BetterContacts

`BetterContacts` macht Kontaktpunkte besser: In das Eingabefeld für Lua-Aufrufe können nun auch Funktionsparameter eingegeben werden.
`BetterContacts` ist der Nachfolger meiner berühmten „Codezeile“, die die selbe Funktion hatte. Die Auslagerung in ein separates Modul macht den Code übersichtlicher und fasst mehrere Varianten der ursprünglichen Codezeile zusammen.

### Schnellstartanleitung

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

- `print("Der Kontaktpunkt wurde vom Zug ", Zugname, " ausgelöst")`  
  &rarr; Schreibt den Namen des Zuges mittels `print` ins Ereignisfenster.
- `ZugAusDepot(2)`  
  &rarr; Ruft den nächsten Zug aus dem Depot 2 ab (sofern eine entsprechende `function ZugAusDepot(depotNummer)` im Skript definiert ist).
- `RegistriereZugAnSignal(Zugname, 1234)`  
  &rarr; Registriert den Zug für Signal 1234 (sofern eine entsprechende `function RegistriereZugAnSignal(zugname, signalId)` im Skript definiert ist).

Bitte beachte, dass das Eingabefeld maximal 63 Zeichen zulässt.

### Konfigurations-Möglichkeiten

Es ist möglich, einige Aspekte von BetterContacts zu konfigurieren. Dazu muss die `require`-Zeile folgendermaßen ergänzt werden:

```lua
require("BetterContacts_BH2"){printErrors=true, chunkname="Kontaktpunkt-Eintrag"}
```

Dabei werden die folgenden Parameter unterstützt:

- ⚠️ `varname`: Ein beliebiger Variablenname als String (standardmäßig `"Zugname"`). Unter diesem Variablennamen wird der von EEP übergebene Name des Zuges bereitgestellt, der den Kontaktpunkt überfahren hat. Wenn du lieber einen anderen Variablennamen verwenden willst, kannst du das mit dieser Option ändern.
- `printErrors`: `true` oder `false` (Standardwert). Wenn `true`, wird bei Syntaxfehlern eine entsprechende Meldung im Ereignisfenster ausgegeben, die beim Fehlersuchen helfen kann (siehe [unten](#Fehlersuche)).
- `chunkname`: Ein beliebiger String (standardmäßig `"KP-Eintrag"`). Dieser wird als _Chunkname_ an Lua übergeben und taucht in Fehlermeldungen auf. Die Funktionalität wird durch diesen Parameter nicht verändert.
- ⚠️ `replaceDots`: `true` oder `false` (Standardwert). Dies ist für EEP 10 nötig, da bei dieser Version fälschlicherweise alle in das Eingabefeld eingegebenen Kommas in Punkte umgewandelt werden. Wenn `replaceDots` auf `true` gesetzt ist, werden alle Punkte wieder in Kommas zurückverwandelt. Somit ist es möglich, mehrere (durch Komma getrennte) Parameter an eine Funktion zu übergeben. Leider werden damit auch gewollte Punkte durch Kommas ersetzt, sodass eine Dezimalzahl (z.B. `10.2`) als zwei Parameter `10, 2` interpretiert wird. Ab EEP 11(?) ist die fälschliche Komma-durch-Punkt-Ersetzung behoben, sodass diese Option nicht mehr benötigt wird (sofern es in der Anlage nicht noch alte Kontaktpunkte mit falschen Punkten gibt).

**Achtung:** Die mit ⚠️ markierten Parameter `varname` und `replaceDots` können nicht nach Belieben geändert werden, sondern müssen zu den tatsächlichen Einträgen in den Kontaktpunkten auf der Anlage passen.

_Unwichtiger Hinweis:_ Bei der oben angegebenen `require`-Zeile handelt es sich um eine Kurzschreibweise, die dank verschiedener technischer Kniffe möglich ist. Die folgende Langversion (mit `.setOptions`, Klammern und Zeilenumbrüchen) macht genau das gleiche:

```lua
require("BetterContacts_BH2").setOptions({
  printErrors = true,
  chunkname = "Kontaktpunkt-Eintrag",
})
```

### Fehlersuche

Beim Programmieren kann es immer vorkommen, dass man sich mal verschreibt.
Zum Beispiel könnte es sein, dass du Folgendes in einen Kontaktpunkt eingetragen hast:  
`print("Der Kontaktpunkt wurde vom Zug ", Zugname, " ausgelöst!"`  
Wenn du jetzt auf OK klickst, beschwert sich EEP, dass es die entsprechende "Lua Funktion nicht finden" kann. So eine Fehlermeldung ist nicht hilfreich.

Um herauszufinden, wo der Fehler liegt, kannst du bei BetterContacts die Option `printErrors` auf `true` setzen (siehe [oben](#Konfigurations-Möglichkeiten)).
Dazu musst du den Kontaktpunkt mit Abbrechen verlassen (vorher am besten den fehlerhaften Eintrag in die Zwischenablage kopieren), dann den Lua-Editor öffnen, die `require`-Zeile entsprechend anpassen, per Klick auf den entsprechenden Knopf das Skript neu laden, in den EEP-Optionen das "EEP Ereignis Fenster" aktivieren, den Kontaktpunkt-Dialog wieder öffnen und den Code aus der Zwischenablage einfügen.  
Wenn du jetzt auf OK klickst, kommt wieder die wenig hilfreiche Fehlermeldung von EEP. Gleichzeitig erscheint im Ereignisfenster aber auch noch eine Fehlermeldung mit mehr Details:  
`[string "Kontaktpunkt-Eintrag"]:1: ')' expected near 'end'`  
Diese von Lua generierte Fehlermeldung ist zwar auch etwas kryptisch, enthält aber die wesentliche Info: Es fehlt eine schließende Klammer am Ende.

Wenn du diese Hilfe zur Fehlersuche nicht mehr benötigst, kannst du die Option `printErrors` wieder deaktivieren (entweder gar nicht angeben oder explizit auf `false`).

### Changelog

Siehe [EMAPS](http://emaps-eep.de/lua/bettercontacts) oder [GitHub-Release-Seite](https://github.com/EEP-Benny/BetterContacts/releases).
