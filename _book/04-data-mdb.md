# Daten der Abgeordneten



Wir haben nun die Reden als auch die Inhalte der Reden im Bundestag heruntergeladen. Dabei haben wir auch schon Verweise auf die Fraktionen und auch die Rollen (beispielsweise die Rede als Bundesminister_in) generieren können. Es fehlen uns jedoch noch Aussagen über das Geschlecht der Redner_innen (und weitere Daten -- etwa Alter, Ausschussmitgliedschaften und Amtszeit).

Diese können wir abermals über das Open Data Portal^[https://www.bundestag.de/service/opendata] des Bundestags herunterladen. Es handelt sich um eine `ZIP`-Datei, welche wir zunächst herunterladen und anschließed extrahieren.


```r
link_zip <- "https://www.bundestag.de/blob/472878/e207ab4b38c93187c6580fc186a95f38/mdb-stammdaten-data.zip"

download.file(link_zip, file.path("data/", basename(link_zip)))

unzip("data/mdb-stammdaten-data.zip", exdir = "data/")
```


```r
file_stammdaten <- read_xml("data/MDB_STAMMDATEN.XML")
```


Nachdem die Datei heruntergeladen und ausgelesen wurde, können wir die Daten wieder einen *Dataframe* umwandeln.


```r
get_data_mdb <- function(x){
  id <- x %>% xml_find_all("//ID") %>% xml_text()
  geschlecht <- x %>% xml_find_all("//ID/following-sibling::BIOGRAFISCHE_ANGABEN/GESCHLECHT") %>% xml_text()
  geburtsjahr <- x %>% xml_find_all("//ID/following-sibling::BIOGRAFISCHE_ANGABEN/GEBURTSDATUM") %>% xml_text() %>% as.integer()
  partei <- x %>% xml_find_all("//ID/following-sibling::BIOGRAFISCHE_ANGABEN/PARTEI_KURZ") %>% xml_text()
  wahlperioden <- x %>% xml_find_all("//ID/following-sibling::WAHLPERIODEN")
  
  data_frame(id, geschlecht, geburtsjahr, partei, wahlperioden) %>%
    mutate(wahlperioden = map(wahlperioden, ~xml_nodes(., "WP") %>% xml_text() %>% as.integer())) %>%
    mutate(anzahl_wahlperioden = map(wahlperioden, ~length(.)) %>% unlist())
}

data_mdb <- get_data_mdb(file_stammdaten)

data_mdb
```

```
## # A tibble: 4,073 x 6
##    id       geschlecht geburtsjahr partei wahlperioden anzahl_wahlperioden
##    <chr>    <chr>            <int> <chr>  <list>                     <int>
##  1 11000001 männlich          1930 CDU    <int [7]>                      7
##  2 11000002 männlich          1909 FDP    <int [5]>                      5
##  3 11000003 weiblich          1913 CDU    <int [3]>                      3
##  4 11000004 weiblich          1933 CDU    <int [2]>                      2
##  5 11000005 männlich          1950 CDU    <int [5]>                      5
##  6 11000007 männlich          1919 SPD    <int [4]>                      4
##  7 11000008 männlich          1912 CDU    <int [1]>                      1
##  8 11000009 männlich          1876 CDU    <int [5]>                      5
##  9 11000010 weiblich          1944 SPD    <int [4]>                      4
## 10 11000011 männlich          1920 CDU    <int [3]>                      3
## # ... with 4,063 more rows
```

Die Namen brauchen wir nicht zwingend, da wir dies auch  den bestehenden Daten entnehmen können (außerdem haben wir ein kleine Problem mit Abgeordneten, welche während oder zwischen den Wahlperioden den Nachnamen ändern oder ergänzen). Wichtig ist hier die ID -- mit dieser können wir die einzelnen Reden den Abgeordneten und schließich auch dem jeweiligen Geschlecht zuordnen.

Bei den Stammdaten handelt es sich um die Daten aller Bundestagsabgeordnetem seit dem 1. Bundestag, welcher 14. August 1949 gewählt wurde. Insgesamt waren 4.073 Personen im Bundestag vertreten. Wie viele davon weiblich und männlich waren, lässt sich wenigen Zeilen Code darstellen. Die letzten beiden Zeilen des Codes beziehen sich nur auf eine bessere Darstellung in der PDF und der Webseite.


```r
data_mdb %>% 
  group_by(geschlecht) %>% 
  summarise(n = n()) %>%
  mutate(freq = n / sum(n)) %>%
  arrange(-n) %>%
  knitr::kable(caption = "Bundestagsabgeordnete nach Geschlecht aller Wahlperioden", booktabs = TRUE) %>%
  kableExtra::kable_styling(full_width = FALSE)
```

```
## Warning in kableExtra::kable_styling(., full_width = FALSE): Please specify
## format in kable. kableExtra can customize either HTML or LaTeX outputs. See
## https://haozhu233.github.io/kableExtra/ for details.
```



Table: (\#tab:unnamed-chunk-5)Bundestagsabgeordnete nach Geschlecht aller Wahlperioden

geschlecht       n        freq
-----------  -----  ----------
männlich      3223   0.7913086
weiblich       850   0.2086914

Die große Mehrheit der im Bundestag vertretenen Person ist männlich. Nur eine Minderheit von 20,9% der Abgeordneten war oder ist weiblich. Ein nicht-binäres Geschlecht oder eine Verweigerung der Angabe des Geschlechts wurde bisher noch nicht angegeben oder nicht dokumentiert -- trans- und intersexuelle Menschen sind im Bundestag somit auch weiterhin kaum vertreten.^[Eine Ausnahme ist etwa der Politiker Christian Schenk, welcher sich nach seiner Zeit im Bundestag als Transmann outete und eine Geschlechtsumwandlung vollzog.]

Wir können mit diesen Daten auch mit wenig aufwand die Frauenquote in den jeweiligen Wahlperioden darstellen.


```r
data_mdb %>%
  unnest() %>%
  group_by(geschlecht, wahlperioden) %>%
  summarise(n = n()) %>%
  group_by(wahlperioden) %>%
  mutate(freq = n / sum(n)) %>%
  rename(Geschlecht = geschlecht) %>%
  ggplot(aes(x = wahlperioden, y = freq, colour = Geschlecht)) +
  geom_line() +
  labs(title = "Geschlechteranteile im Deutschen Bundestag", 
       subtitle = "Auswertung des 1. bis 19. Deutschen Bundestages",
       x = "Wahlperiode",
       y = "Anteil in Prozent") +
  theme_minimal()
```

<div class="figure" style="text-align: center">
<img src="04-data-mdb_files/figure-epub3/unnamed-chunk-6-1.png" alt="Auswertung der Geschlechteranteile aller Deutscher Bundestage"  />
<p class="caption">(\#fig:unnamed-chunk-6)Auswertung der Geschlechteranteile aller Deutscher Bundestage</p>
</div>

. 
