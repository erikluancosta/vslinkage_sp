remove_duplicados_sim <- function(df, fill_after = FALSE) {
  library(dplyr)
  library(tidyr)
  library(lubridate)
  library(rlang)
  
  # --- snapshot original ---
  df_original <- df %>% mutate(.row_id = row_number())
  
  # --- preparar tipos e variáveis auxiliares ---
  df <- df_original %>%
    mutate(
      dt_nasc  = suppressWarnings(as.Date(dt_nasc)),
      dt_obito = suppressWarnings(as.Date(dt_obito)),
      ano      = suppressWarnings(as.integer(ano)),
      ano_nasc = lubridate::year(dt_nasc),
      causa_3d = if ("cd_causabas" %in% names(.)) substr(cd_causabas, 1, 3) else NA_character_
    )
  
  # --- função de score ---
  score_linha <- function(data) {
    base_cols <- setdiff(names(data), c(".row_id", "causa_3d"))
    data %>%
      mutate(
        n_non_na = if (length(base_cols) > 0)
          rowSums(across(all_of(base_cols), ~ !is.na(.))),
        has_cns  = as.integer(!is.na(nu_cns)),
        has_nome = as.integer(!is.na(ds_nome_pac) & ds_nome_pac != ""),
        has_dt   = as.integer(!is.na(dt_obito) | !is.na(dt_nasc)),
        ord_obito = as.numeric(coalesce(dt_obito, as.Date("1900-01-01"))),
        ord_nasc  = as.numeric(coalesce(dt_nasc,  as.Date("1900-01-01"))),
        score = (has_cns * 1e6) + (has_nome * 1e5) + (has_dt * 1e4) +
          (n_non_na * 10) + ord_obito + ord_nasc
      )
  }
  
  # --- resolver duplicados por chaves ---
  resolve_grupo <- function(data, keys, tag, filtro_extra = NULL) {
    dat <- if (!is.null(filtro_extra)) filter(data, !!parse_expr(filtro_extra)) else data
    
    dup_keys <- dat %>%
      group_by(across(all_of(keys))) %>%
      summarise(n = n(), .groups = "drop") %>%
      filter(n > 1)
    
    if (nrow(dup_keys) == 0) {
      return(list(data = data, drops = tibble(.row_id = integer(), .drop_reason = character())))
    }
    
    candidatos <- dat %>%
      inner_join(dup_keys %>% select(all_of(keys)), by = keys) %>%
      score_linha()
    
    melhores <- candidatos %>%
      group_by(across(all_of(keys))) %>%
      arrange(desc(score), .by_group = TRUE) %>%
      slice(1) %>%
      ungroup() %>%
      select(.row_id)
    
    perdedores <- candidatos %>%
      anti_join(melhores, by = ".row_id") %>%
      transmute(.row_id, .drop_reason = tag)
    
    list(
      data  = anti_join(data, perdedores, by = ".row_id"),
      drops = perdedores
    )
  }
  
  drops_all <- tibble(.row_id = integer(), .drop_reason = character())
  
  # --- regras ---
  regras <- list(
    list(keys = c("nu_do"), tag  = "R1: dup nu_do"),
    list(keys = c("ds_nome_pac","ds_nome_pai","ds_nome_mae","ano","ano_nasc", "dt_obito"),
         tag  = "R2: nome+pais+ano+ano_nasc", filtro = "!is.na(ds_nome_pac)"),
    list(keys = c("nu_cns","dt_obito","dt_nasc"),
         tag  = "R3: nu_cns+dt_obito+dt_nasc", filtro = "!is.na(nu_cns)"),
    list(keys = c("ds_nome_pac_sound","dt_obito","dt_nasc"),
         tag  = "R4: soundex_pac+dt_obito+dt_nasc", filtro = "!is.na(dt_nasc)"),
    list(keys = c("ds_nome_pac_sound","ano","dt_nasc"),
         tag  = "R5: soundex_pac+ano+dt_nasc", filtro = "!is.na(dt_nasc)"),
    list(keys = c("ds_nome_mae_sound","dt_nasc","dt_obito","causa_3d", "ds_nome_pac1"),
         tag  = "R6: soundex_mae+datas+causa3", filtro = "!is.na(dt_nasc)"),
    list(keys = c("ds_nome_pai_sound","dt_nasc","dt_obito","causa_3d"),
         tag  = "R7: soundex_pai+datas+causa3", filtro = "!is.na(dt_nasc)")
  )
  
  for (reg in regras) {
    r <- resolve_grupo(df, reg$keys, reg$tag, reg$filtro %||% NULL)
    df <- r$data
    drops_all <- bind_rows(drops_all, r$drops)
  }
  
  if (isTRUE(fill_after) && "nu_do" %in% names(df)) {
    df <- df %>%
      group_by(nu_do) %>%
      fill(everything(), .direction = "downup") %>%
      ungroup()
  }
  
  removidos <- df_original %>%
    inner_join(drops_all, by = ".row_id") %>%
    select(-.row_id)
  
  resumo <- drops_all %>%
    count(.drop_reason, name = "n_drops") %>%
    arrange(desc(n_drops))
  
  list(
    data   = df %>% select(-.row_id, -causa_3d),
    drops  = removidos,
    resumo = resumo
  )
}
