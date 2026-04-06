library(tidyr)
library(dplyr)

namestand2 <- vitallinkage::namestand |> 
  mutate(
    fonte =
      case_when(
        fonte=="SINAN"~"SINAN_VIOL",
        fonte=="ESUS_AB"~"ESUS_APS",
        TRUE~fonte
      )
  ) |> 
  bind_rows(
    data.frame(
      fonte = c(
        "SIH", "SIH", 
        "SINAN_VIOL", "SINAN_VIOL", 
        "SIM","SIM", "SIM",
        "ESUS_APS", "ESUS_APS", "ESUS_APS", "ESUS_APS"
      ),
      var_names_orig = c(
        "id_sih", "id_unico", 
        "id_sinan_viol","id_unico",
        "id_sim","id_unico", "DTATESTADO",
        "id_esus_aps","id_unico", "nu_cnes", "enc_nu_cid10"
      ),
      stanard_name = c(
        "id_sih", "id_unico",
        "id_sinan_viol","id_unico", 
        "id_sim", "id_unico", "dt_atestado",
        "id_esus_aps","id_unico", "nu_cnes", "enc_nu_cid10"
      )
    )
  ) |> 
  filter(
    !(var_names_orig %in% c("tba_co_unidade_saude", "tbenc_co_cid10", "tbenc_co_ciap"))
  )


