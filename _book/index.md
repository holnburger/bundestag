--- 
title: "Geschlechterunterschiede im Deutschen Bundestag"
author: "Josef Holnburger und Gina-Gabriela Görner"
site: bookdown::bookdown_site
bibliography: book.bib
link-citations: yes
documentclass: scrbook
classoption: oneside, 12pt, numbers=endperiod
graphics: yes
linestretch: 1.5
---

\frontmatter
\pagenumbering{Roman}

\listoffigures
\addcontentsline{toc}{chapter}{\listfigurename}
\vspace*{24pt}
{\let\clearpage\relax \listoftables}	
\addcontentsline{toc}{chapter}{\listtablename}

\mainmatter

# Einleitung {#intro}

Zusammen mit Gina-Gabriela Görner analysiere ich die Protokolle des Deutschen Bundestages auf mögliche Geschlechterunterschiede. Hierfür wollen wir die Anzahl aber auch Inhalte der Reden mehrer Wahlperioden des Bundestags untersuchen. Dieses Projekt wurde auch für das [European Symposium Series on Societal Challenges](http://symposium.computationalsocialscience.eu/2018/) eingereicht und wir dürfen es dort mit einem Plakat vorstellen.

Wir orientieren uns vor allem an der Forschung von @back_2014, welche das schwedische Parlament auf mögliche Geschlechterunterschiede und Diskriminierung hin untersucht haben. In dieser Studie wurden Unterschiede sowohl in der Anzahl als auch bezüglich des Inhalts der Reden festgestellt. Auuch im schwedischen Parlament sind Männer deutlich häufiger zu hören -- obwohl es mit einem Frauenanteil von 40 Prozent die höchste Quote europäischer Parlamente aufweist [@back_2014, S. 505]. Männer sprechen in ihren Reden häufiger über *hard topics*, bei *soft topics* ist der Redeanteil hingegen ausgeglichen (ebd: 513ff.).
Die Konstruktion der *hard* und *soft topics* geht dabei auf @wangnerud_2000 zurück und ist nicht unkritisch -- hier werden durchaus Geschlechterstereotype aufrechterhalten oder gar reproduziert, indem "typische" Frauen und Männerthemen identifiziert werden. Wangnerud hat ihn ihrer Untersuchung die Mitglieder des schwedischen *Riksdag* bezüglich ihrer Aktivitäten befragt. Das Ergebnis von @back_2014 ist deshalb auch nicht besonders überraschend -- bestätigt es doch nur, dass die Fachpolitiker_innen häufiger über ihre Themen auch im Plenum reden.

In dieser Arbeit soll anders vorgegangen werden. Die Inhalte der Reden im Bundestaug sollen ohne voherige Identifikation vermeintlicher Frauen- und Männerthemen untersucht werden. Hierbei nutzen wir die Möglichkeiten des  *Topic Modelling* um zunächst generell Themen der Reden im Bundestags zu identifizieren und diese anschließend auf mögliche Geschlechterunterschiede untersuchen. Natürlich wollen auch wir die Unterschiedlichen Redeanteile untersuchen.

Da ich den Prinzipien der Open Science sehr viel abgewinnen kann, soll die Erhebung und Auswertung möglichst transparent und nachvollziehbar dargestellt werden.
