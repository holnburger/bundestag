# Erhebung der Daten des 19. Bundestags {#data-02}

Leider gibt es keine Möglichkeit, die XML-Protokolle des Deutschen Bundestages gesammelt herunterzuladen. Zwar finden sich auf *Open Data*-Seite des Bundestags^[https://www.bundestag.de/service/opendata] die Verweise auf die Bundestagsprotkolle, allerdings können diese nur umständlich einezln heruntergeladen werden.
Durch das Auslesen der Netzwerkdaten nach einem Klick auf die nächsten fünf Protkolle eine Webseite gefunden werden, auf welcher jeweils fünf Protkolle gespeichert sind^[https://www.bundestag.de/ajax/filterlist/de/service/opendata/-/543410?offset=0]. Durch setzen des `offset=0` auf `5, 10, 15, 20, …` können wir die weiteren Protokolle abrufen. 

Mittels `rvest` und `xml2` ziehen wir uns zunächst die Nummer des letzten Bundestagsprotokolls. Über die Funktion `seq()` und `paste0()` können wir anschließend alle für den weiteren Verlauf notwendigen URLs erstellen.



```r
bt_website <- "https://www.bundestag.de/ajax/filterlist/de/service/opendata/-/543410"

last_protocol <- bt_website %>% 
  read_html() %>%
  xml_find_first("//strong") %>% 
  xml_text(trim = TRUE) %>%
  str_extract("\\d+")

prot_websites <- paste0(bt_website, "?offset=", seq(0, last_protocol, 5))
```

Insgesamt müssen wir also 13 Webseiten aufrufen und uns jeweils fünf Protokolle herunterladen.

Der Aufwand ist hier noch überschaubar. Natürlich laden wir die Protokolle dennoch nicht per Hand herunter, sondern erstellen uns hierfür ein kleines Script. Da die meisten Rechner auch mit mehr als nur einem Prozessor ausgestattet sind, können wir die Funktion auch auf mehreren Prozessoren ausführen. Wir sprechen hier von *multiprocessing*. Dies realisieren wir über das Packet `furrr` [@vaughan_2018] - eine Abwandlung des bereits genutzten `purrr`.

Wir schreiben uns zunächst eine Funktion, um die Links der Webseiten zu extrahieren.


```r
get_prot_links <- function(x){
  x %>%
    read_html() %>%
    html_nodes(".bt-link-dokument") %>%
    html_attr("href") %>%
    paste0("https://www.bundestag.de", .)
  }

get_prot_links(bt_website)
```

```
## [1] "https://www.bundestag.de/blob/578466/7430bccaf792e7bc55e84d5e64675820/19062-data.xml"
## [2] "https://www.bundestag.de/blob/577958/e2063c0f51a32690a269f48aa6102c1d/19061-data.xml"
## [3] "https://www.bundestag.de/blob/577622/da97888b713abb16ed2070836504b83a/19060-data.xml"
## [4] "https://www.bundestag.de/blob/575138/b5395a975d1c55838da0e52251018160/19059-data.xml"
## [5] "https://www.bundestag.de/blob/574826/0e3659e11c1c3cdbfa621369cd16735a/19058-data.xml"
```

Dies wenden wir nun auf alle 13 Webseiten an und speichern die Dateien anschließend im Ordner `data\protokolle`.


```r
library(furrr)
plan(multiprocess)

prot_links <- future_map(prot_websites, ~get_prot_links(.)) %>% unlist()

prot_links %>% future_map(~download.file(., file.path("data/protokolle", basename(.))))
```

Wir waren erfolgreich und konnten in wenigsten Sekunden alle aktuellen Protokolle herunterladen. Wir können sie jetzt auslesen und dabei auch unsere bereits erstellten Funktionen verwenden. Jetzt können wir alle Dateien einlesen, die Übersicht der Reden oder den Inhalt der Reden extrahieren und anschließend auswerten.


```r
source("functions/get_overview_df.R")
source("functions/get_speeches_df.R")
```


```r
prot_files <- list.files("data/protokolle", full.names = TRUE)

prot_extract <- map(prot_files, ~read_html(.) %>% xml_find_all("//rede"))

class(prot_extract) <- "xml_nodeset"

prot_overview <- map_dfr(prot_extract, ~get_overview_df(.))
```

## Überblick der Reden

Wir konnten nun alle Dateien herunterladen und anschließend alle Protkolle in R einlesen. Mit unserer Funktion `get_overview_df()` konnten wir alle Protokolle in einen für uns passenden Datenframe umwandeln. Insgesamt können wir derzeit 5.777 Reden des aktuellen Bundestags untersuchen -- etwa nach der Person, welche die meisten reden gehalten hat.


```r
prot_overview %>% 
  group_by(redner_id, redner_vorname, redner_nachname,
           redner_fraktion, redner_rolle) %>% 
  summarise(reden = n()) %>%
  arrange(-reden)
```

```
## # A tibble: 773 x 6
## # Groups:   redner_id, redner_vorname, redner_nachname, redner_fraktion
## #   [728]
##    redner_id redner_vorname redner_nachname redner_fraktion redner_rolle
##    <chr>     <chr>          <chr>           <chr>           <chr>       
##  1 11002617  Peter          Altmaier        <NA>            Bundesminis…
##  2 999990073 Olaf           Scholz          <NA>            Bundesminis…
##  3 11004427  Volker         Ullrich         CDU/CSU         <NA>        
##  4 11001478  Angela         Merkel          <NA>            Bundeskanzl…
##  5 11004809  Heiko          Maas            <NA>            Bundesminis…
##  6 11004851  Frauke         Petry           fraktionslos    <NA>        
##  7 11004798  Alexander Graf Lambsdorff      FDP             <NA>        
##  8 11003625  Andreas        Scheuer         <NA>            Bundesminis…
##  9 999990074 Svenja         Schulze         <NA>            Bundesminis…
## 10 11003638  Jens           Spahn           <NA>            Bundesminis…
## # ... with 763 more rows, and 1 more variable: reden <int>
```

Die Minister_innen haben am häuiigsten im Bundestag geredet, der MdB Volker Ullrich landet erst af Platz 4 mit insgesamt vierzig Reden in der aktuellen Wahlperiode. Überraschenderweise hat Frauke Petry sehr viele Reden gehalten: 35 Stück. Das sind deutlich mehr als in ihrer damaligen Zeit im Landesparlament.

Wir können die Reden auch nach Fraktionen auswerten:


```r
prot_overview %>%
  group_by(redner_fraktion) %>%
  summarise(reden = n()) %>%
  arrange(-reden) %>%
  knitr::kable(caption = "Reden Nach Fraktion im Deutschen Bundestag", booktabs = TRUE)
```



Table: (\#tab:unnamed-chunk-8)Reden Nach Fraktion im Deutschen Bundestag

redner_fraktion          reden
----------------------  ------
CDU/CSU                   1353
SPD                        962
AfD                        784
FDP                        683
BÜNDNIS 90/DIE GRÜNEN      662
NA                         662
DIE LINKE                  606
fraktionslos                63
Bremen                       1
Bündnis 90/Die Grünen        1

Mit auswertung der Daten nach Fraktion stellen wir kleinere Probleme Fest: Anscheinend wurden die Grüne in einem Dokument nicht in der üblichen Schreibweise geschrieben. Und die Fraktion "Bremen" ist vermutlich auch in der falschen Spalte gelandet - es handelt sich nämlich um eine Rede des Bremer Bürgermeisters.
Beide ändern wir entsprechend:


```r
prot_overview <- prot_overview %>%
  mutate(redner_fraktion = ifelse(redner_fraktion == "Bündnis 90/Die Grünen", "BÜNDNIS 90/DIE GRÜNEN", redner_fraktion)) %>%
  mutate(redner_fraktion = ifelse(redner_fraktion == "Bremen", NA, redner_fraktion))
```

## Inhalte der Reden




```r
speech_extract <- map(prot_files, ~read_html(.) %>% xml_find_all("//rede/*"))

class(speech_extract) <- "xml_nodeset"

prot_speeches <- map_dfr(speech_extract, ~get_speeches_df(.))
```
