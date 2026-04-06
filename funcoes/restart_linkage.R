restart_linkage <- function(df) {
  # Remove colunas que nao sao mais necessarias
  df <- df |> 
    select(-starts_with(c("par_c2", "par_c3", "par_c4", "par_c5"))) |> 
    select(-par_c6, -par_c7, -par_c8, -par_c9, -par_c10, -par_c11, -par_c12, -par_c13, -par_c14, -par_c15, -par_c16, -par_c17,-par_c18, -par_c19) 
  
  # Renomeia par_1 para par_c1
  df <- df |> 
    rename(par_c1 = par_1)
  
  return(df)
}