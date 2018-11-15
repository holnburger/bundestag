# Generelles zur Datenerhebung {#data-01}

Die Reden im Deutschen Bundestag sind in den Protokollen dokumentiert und lassen sich [online abrufen](https://www.bundestag.de/protokolle). Praktischerweise liegen die Daten seit der aktuellen Wahlerperiode auch im [TEI-Format (Text Encoding Initiative)](http://www.tei-c.org/) vor. Dies erleichtert die Analyse der Protkolle erheblich.
Die Datenerhebung und Auswertung erfolgt mit der Programmiersprache R [@rcoreteam_2018] und der `tidyverse` Packetsammlung [@wickham_2017].

Die Datenerhebung soll zunächst an einem Beispielprotokoll gezeigt werden -- wir nutzen hierfür das Protokoll der [61. Sitzung des 19. Bundestages](https://www.bundestag.de/blob/577958/b2d1fce9b7dec32a1403a2ec5f6bc58d/19061-data.xml). Das Protokoll liegt dabei sowohl als PDF, als TXT und auch als XML-Datei vor. Letzeres wird für diese Arbeit herangezogen.

Mit dem Packet `xml2` [@wickham_2018] kann das Protokoll ausgelesen und anschließend in ein passendes Format umgewandelt werden. Mit der Funktion `read_html()` wird das vollständige Protokoll in der Variable `prot_file` eingelesen. Die Umwandlung der einzelnen Knoten und Attribute des XML-Dokuments erfolgt mit dem `rvest` Packet [@wickham_2016].

Da für diese Auswertung nur die Reden im Deutschen Bundestag herangezogen werden (und angehängte Dokumente sowie Anwesenheitslisten irrelevant sind), soll nur ein Teil des Protkolls untersucht werden. Mittels der Funktion `xml_find_all("//rede")` können alle Einträge unter dem Knoten "rede" herausgefiltert werden.


```r
library(tidyverse)
library(xml2)
library(rvest)

prot_file <- read_html("https://www.bundestag.de/blob/577958/b2d1fce9b7dec32a1403a2ec5f6bc58d/19061-data.xml") 

prot_overview <- prot_file %>%
  xml_find_all("//rede")
```

Die Datei soll anschließend in einen *Dataframe* umgewandelt werden. Dies erleichtert die weitere Arbeit und im weiteren Verlauf können die Daten einfacher nach nach Geschlecht, Partei, Datum oder Wahlperiode gefiltert werden. Hierbei wird vor allem mit den Funktionen `xml_node()` und `xml_attr()` gearbeitet. Zum Verständnis bietet sich hier ein kleiner Diskurs an.

## XML-Knoten und Attribute

Nachdem die Datei eingelesen wurde, lohnt sich ein Blick auf die Rohdaten:

```xml
<rede id="ID196105400">
  <p klasse="redner"><redner id="11004826"><name><vorname>Siemtje</vorname><nachname>Möller</nachname><fraktion>SPD</fraktion></name></redner>Siemtje Möller (SPD):</p>
  <p klasse="J_1">Lieber Jürgen Trittin, Sie haben gerade eigentlich das wiederholt, was Sie schon in Ihrem Redebeitrag gesagt haben. Ich möchte dazu genau dasselbe sagen, was ich auch in der Debatte über Syrien und eine mögliche Beteiligung der Bundeswehr gesagt habe: Wir sind da noch nicht. Es gilt, alles zu tun, damit dieser Zustand nicht eintritt. Und genau das tut Heiko Maas.</p>
  <kommentar>(Beifall bei der SPD)</kommentar>
</rede>
```



In diesem Beispiel wird das XML-Fragment in die Variable `xml_example` geladen und ausgewertet. Die Knoten eines XML-Documents werden durch `<>` und `</>` eingefasst. Beispielsweise können die Knoten mit den Namen "Kommentar" folgendermaßen extrahiert werden:


```r
xml_example %>% xml_nodes("kommentar")
```

```
## {xml_nodeset (1)}
## [1] <kommentar>(Beifall bei der SPD)</kommentar>
```

Bei der Ausgabe fällt jedoch auf, dass die Datei weiterhin eine XML-Datei bleibt und die Knoteninformationen ebenfalls extrahiert werden. Mittels der Funktion `xml_text()` kann das Ergebniss in einen in einen Character-String umwandelt werden.


```r
xml_example %>% xml_nodes("kommentar") %>% xml_text()
```

```
## [1] "(Beifall bei der SPD)"
```

Die Ergebnisse werden in einer Liste zusammengefasst und können beispielsweise in einem Datenframe umgewandelt werden. 

Die Attribute eines Knotens finden sich in den Klammern nach dem Gleichheitszeichen: `<knotenname attribut="inhalt">...`. Die Werte eines Attributes (und auch den Attributnamen) können mit der Funktion `xml_attr()` extrahiert werden.


```r
xml_example %>% xml_node("rede") %>% xml_attr("id")
```

```
## [1] "ID196105400"
```

Mit dieser kurzen Exkursion können wir nun eine Funktion bauen, welche auf die für uns relevanten Daten aus dem XML-Dokument extrahiert und anschließend in einen Datenframe umwandelt.


```r
get_overview_df <- function(x){
  rede_id <- x %>% xml_attr("id")
  redner_id <- x %>% xml_node("redner") %>% xml_attr("id")
  redner_vorname <- x %>% xml_node("redner") %>% xml_node("vorname") %>% xml_text()
  redner_nachname <- x %>% xml_node("redner") %>% xml_node("nachname") %>% xml_text()
  redner_fraktion <- x %>% xml_node("redner") %>% xml_node("fraktion") %>% xml_text()
  redner_rolle <- x %>% xml_node("rolle_kurz") %>% xml_text()
  
  data_frame(rede_id, redner_id, redner_vorname, redner_nachname, redner_fraktion, redner_rolle)
}
```

Wir können mit dieser Funktion nun die vorher eingelesen XML-Datei in einen Datenframe umwandeln und auswerten. 


```r
overview_df <- get_overview_df(prot_overview)

overview_df
```

```
## # A tibble: 144 x 6
##    rede_id redner_id redner_vorname redner_nachname redner_fraktion
##    <chr>   <chr>     <chr>          <chr>           <chr>          
##  1 ID1961… 11003196  Andrea         Nahles          SPD            
##  2 ID1961… 11004873  Ulrike         Schielke-Ziesi… AfD            
##  3 ID1961… 11002666  Hermann        Gröhe           CDU/CSU        
##  4 ID1961… 11004179  Johannes       Vogel           FDP            
##  5 ID1961… 11004012  Matthias W.    Birkwald        DIE LINKE      
##  6 ID1961… 11003578  Markus         Kurth           BÜNDNIS 90/DIE…
##  7 ID1961… 11003142  Hubertus       Heil            <NA>           
##  8 ID1961… 11004856  Jürgen         Pohl            AfD            
##  9 ID1961… 11002812  Max            Straubinger     CDU/CSU        
## 10 ID1961… 11004941  Gyde           Jensen          FDP            
## # ... with 134 more rows, and 1 more variable: redner_rolle <chr>
```

## Zwischenfazit

Wir konnten  mit wenigen Zeilen Code das XML-Format in einen Datenframe umwandeln, welcher uns die weitere Arbeit erheblich erleichter. So könnten wir sehr schnell sagen, wie viele Reden es von den einzelnen Fraktionen zur 61. Sitzung des 19. Bundestags gab:


```r
overview_df %>% 
  group_by(redner_fraktion) %>%
  summarise(reden = n()) %>%
  arrange(-reden)
```

```
## # A tibble: 8 x 2
##   redner_fraktion       reden
##   <chr>                 <int>
## 1 CDU/CSU                  41
## 2 SPD                      27
## 3 AfD                      20
## 4 BÜNDNIS 90/DIE GRÜNEN    16
## 5 FDP                      16
## 6 DIE LINKE                15
## 7 <NA>                      6
## 8 fraktionslos              3
```

Da *NA* Fraktionen sind dabei die Reden von Ministern und Gästen. Sie werden keiner Fraktion zugeordnet. Insgesamt gab es 144 Reden an diesem Tag.

Uns interessieren natürlich nun nicht nur die Anzahl der Reden, sondern auch deren Inhalt. Wir untersuchen hierfür alle Knoten eine Ebene unter den "rede"-Knoten. 


```r
prot_speeches <- prot_file %>%
  xml_find_all("//rede/*")
```

Wir bauen wieder eine Funktion, um alle Inhalte der Reden zu extrahieren. Diese Funktion ist ein wenig komplexer, da sie unter anderem die Funktion `map()` aus dem `purrr` Packet nutzt (ebenfalls `tidyverse`) -- für weitere Informationen über die Funktion `map()` bietet sich dieses [Tutorial an](https://jennybc.github.io/purrr-tutorial/).

Außerdem müssen die Rohdaten etwas angepasst werden, da die Aussagen des Präsidiums sonst falsch zugeordnet werden.


```r
get_speeches_df <- function(x){
  raw <- x
  rede <- x %>% xml_text()
  id <- x %>% xml_node("redner") %>% xml_attr("id")
  vorname <- x %>% xml_node("vorname") %>% xml_text()
  nachname <- x %>% xml_node("nachname") %>% xml_text()
  fraktion <- x %>% xml_node("fraktion") %>% xml_text()
  rolle <- x %>% xml_node("rolle_kurz") %>% xml_text()
  typ <- x %>% xml_name()
  status <- x %>% xml_attr("klasse")
  
  data_frame(raw, rede, id, vorname, nachname, fraktion, rolle, typ, status) %>%
    mutate(rede_id = map(raw, ~xml_parent(.) %>% xml_attr("id")) %>% as.character()) %>%
    select(-raw) %>%
    mutate(status = ifelse(typ == "kommentar", typ, status)) %>%
    mutate(status = ifelse(typ == "name", "präsidium", status)) %>%
    mutate(fraktion = case_when(
      typ == "name"       ~ "präsidium",
      !is.na(rolle)       ~ "andere",
      TRUE                ~ fraktion)) %>%
    fill(id, vorname, nachname, fraktion) %>%
    mutate(präsidium = ifelse(fraktion == "präsidium", TRUE, FALSE)) %>%
    mutate(fraktion = ifelse(fraktion == "präsidium", NA, fraktion)) %>%
    filter(!status %in% c("T_NaS", "T_Beratung", "T_fett", "redner")) %>%
    filter(!typ %in% c("a", "fussnote", "sup")) %>%
    select(rede_id, rede, id, vorname, nachname, fraktion, präsidium, typ, status)
}

get_overview_df <- function(x){
  rede_id <- x %>% xml_attr("id")
  redner_id <- x %>% xml_node("redner") %>% xml_attr("id")
  redner_vorname <- x %>% xml_node("redner") %>% xml_node("vorname") %>% xml_text()
  redner_nachname <- x %>% xml_node("redner") %>% xml_node("nachname") %>% xml_text()
  redner_fraktion <- x %>% xml_node("redner") %>% xml_node("fraktion") %>% xml_text()
  redner_rolle <- x %>% xml_node("rolle_kurz") %>% xml_text()
  sitzung <- x %>% xml_find_first("//sitzungsnr") %>% xml_text() %>% as.integer()
  datum <- x %>% xml_find_first("//datum") %>% xml_attr("date") %>% lubridate::dmy()
  wahlperiode <- x %>% xml_find_first("//wahlperiode") %>% xml_text() %>% as.integer()
  
  data_frame(rede_id, redner_id, redner_vorname, redner_nachname, redner_fraktion, redner_rolle, sitzung, datum, wahlperiode)
}

speeches_df <- get_speeches_df(prot_speeches)
```

Mittels dieses Datenframes ist es nun möglich, nur die Aussagen von beispielsweise Andrea Nahles zu untersuchen -- ohne Unterbrechungen und Fragen von anderen Abgeordneten "mitzuschneiden" oder Aussagen des Präsidiums mitzunehmen.

Hier ein Beispiel:


```r
speeches_df %>%
  filter(typ != "kommentar") %>%
  filter(präsidium == FALSE) %>%
  filter(id == "11003196") %>%
  pull(rede) %>% 
  cat(fill = TRUE)
```

```
## Herr Präsident! Meine lieben Kolleginnen und Kollegen! Auch in dieser Woche verabschieden SPD und CDU/CSU konkrete Gesetze, die für mehr Gerechtigkeit und für mehr Zusammenhalt in Deutschland sorgen werden. Wir erhöhen das Kindergeld um 10 Euro. Wir verabschieden eine Pflegereform, auf deren Grundlage deutlich mehr Pflegekräfte eingestellt werden und die Pflegekräfte insgesamt besser bezahlt werden. Wir schaffen Arbeitsplätze für Mitbürgerinnen und Mitbürger, die schon sehr lange arbeitslos sind. Und wir sichern die Rente auf dem jetzigen Niveau. Diese Regierung liefert. 
## Mit der heutigen Rentenreform vollziehen wir einen grundsätzlichen Richtungswechsel. Die alte Rentenformel sah vor, dass die Rente geringer steigt als die Löhne. Die neue Rentenformel stellt sicher: Die Renten steigen wie die Löhne. 
## Wir sichern damit ein Rentenniveau auf dem heutigen Level. Das ist wirklich eine sehr entscheidende Weichenstellung. Zusätzliche Vorsorge über Betriebsrenten oder privat ist eine gute Sache – wenn sie eben ergänzend gedacht ist, nicht ersetzend. Das ist der entscheidende Punkt für uns. 
## Denn die gesetzliche Rentenversicherung ist und bleibt die zentrale Säule im deutschen Rentensystem. 
## Die Rentenreform folgt einem einfachen Prinzip: Wer ein Leben lang arbeitet, der verdient auch einen anständigen Lebensabend, der verdient eine Rente, von der er auch leben kann. 
## Ich betone: Ich benutze den Begriff „verdient“ bewusst. Denn die Rente ist kein Almosen, und sie ist auch kein Luxus. Die Rente ist der gesellschaftliche Lohn für ein Leben voller Arbeit. Für die Mehrheit der Bevölkerung ist übrigens die gesetzliche Rente ihr größtes Vermögen. Sie bleibt die sicherste Form der Altersversorgung. 
## Uns ist die Stärkung der umlagefinanzierten Rente ja auch deswegen so wichtig, weil die Systeme, die vor allem auf private Absicherung ausgerichtet waren, letztendlich alle in der Finanzkrise deutlich gestrauchelt sind. Das ist ganz eindeutig der Fall gewesen. 
## Im Gegensatz zu den privaten steht die gesetzliche Rente blendend da. Würde man aus Beiträgen und Rentenansprüchen in der gesetzlichen Rente die Rendite berechnen, ergäbe sich ein stabiler Ertrag von 2 bis 3 Prozent pro Jahr, verlässlich und frei von Schwankungen. Das ist auf dem Kapitalmarkt momentan nicht zu kriegen, um es sehr deutlich zu sagen. 
## Die umlagefinanzierte Rente ist deswegen der kapitalgedeckten überlegen. 
## Ich spreche jetzt in diesem Hohen Haus auch etwas aus, was vielleicht nicht alle gerne hören: Entweder wir sichern heute das Rentenniveau auf dem jetzigen Stand bis zum Jahr 2025 und nach dem Willen der SPD auch weiter darüber hinaus, 
## oder wir lassen zu, dass die Renten immer weiter sinken und entwertet werden. 
## Wenn wir das aber zulassen, muss die junge Generation einem solchen System irgendwann das Vertrauen entziehen. Denn warum sollte ausgerechnet die junge Generation jahrzehntelang Beiträge zahlen, wenn sie am Ende keine Sicherheit darüber hat, was sie rausbekommt? Das ist doch Unsinn. 
## Deswegen ist aus meiner Sicht die Sicherung des Rentenniveaus in diesem System auch wichtig im Sinne der Generationengerechtigkeit. Ein garantiertes Rentenniveau schafft für die junge Generation nämlich die Sicherheit, dass sie sich eben am Ende auch auf dieses System der gesetzlichen Rentenversicherung verlassen kann. 
## Jetzt sagen manche, das sei nicht finanzierbar. Das ist ein ziemlich scheinheiliges Argument. 
## Denn niemand wird ja wohl bestreiten, dass das Geld für eine auskömmliche Rente im Jahre, sagen wir, 2040 auch immer irgendwo herkommen muss. Die einzige Frage ist doch: Was ist der beste und der gerechteste Weg, dies dann zu finanzieren? Soll die heutige Arbeitnehmergeneration sowohl die Renten von heute finanzieren und gleichzeitig privat noch die eigene Rente aufstocken? Damit würden viele Arbeitnehmerinnen und Arbeitnehmer komplett überfordert. Oder soll auch die heutige Arbeitnehmergeneration sich darauf verlassen können, dass auch sie im Alter eine von ihren Kindern und dann auch durch zusätzliche Steuermittel finanzierte Rente bekommt? Die Frage ist doch nicht, ob, sondern die Frage ist, wie wir die Renten und die Garantie eines Rentenniveaus in Zukunft finanzieren. Darüber lohnt sich jeder Streit; gar keine Frage. 
## Das, was wir heute beschließen, ist finanziert. Bis 2025 ist das Rentenniveau klar gesichert. 
## Wir steigen darüber hinaus in die Bildung einer Demografierücklage ein. 
## Damit schaffen wir die Voraussetzung, um den Steueranteil zur Finanzierung der Rentenversicherung systematisch auf- und ausbauen zu können. 
## Das wird wahrscheinlich auch der Weg der Zukunft sein. Darüber wird aber in der Rentenkommission noch weiter diskutiert werden. 
## Wenn es aber etwas gibt, was wir klären müssen, dann ist das doch die Frage: Wollen wir in Zukunft wirklich auf die gesetzliche Rentenversicherung als wesentliche Säule unseres Rentensystems setzen, ja oder nein? 
## Einen Weg zur Finanzierung werden wir in einem reichen Land wie Deutschland sicherlich finden, und zwar einen gerechten, wenn es nach der SPD geht. 
## Letzter Satz. Wenn es also einen Gradmesser für die soziale Sicherheit in Deutschland gibt, dann ist das aus meiner Sicht eine gute Alterssicherung. Für eine gute Altersversorgung sorgen wir mit diesem Rentenpaket heute und jetzt. 
## Vielen Dank.
```

Somit könnten wir für dieses Protokoll die einzelnen Reden (aber zum Beispiel auch Zwischenfragen) von Abgeordneten gezielt auf deren Inhalte untersuchen. Wir können noch nicht die Zwischenrufe und den Applaus nach Abgeordneten bzw. Fraktionen auswerten. Dies wäre mit sogenannten *regular experesions* aber möglich.

Wie wir alle aktuellen Protokolle auswerten, behandeln wir in Daten wir in Kapitel \@ref(data-02). Die beiden Funktionen speichern wir im Ordner "functions".

