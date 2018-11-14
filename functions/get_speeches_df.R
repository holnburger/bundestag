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