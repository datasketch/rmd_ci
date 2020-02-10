library(tidyverse)
library(glue)
library(airtabler)
dotenv::load_dot_env()
exploralatam <- airtable(
    base = "appIXZnJhGYNFH9Q9",
    tables = c("projects")
  )


projects0 <- exploralatam$projects$select_all()
projects0 <- mop::na_to_empty_chr(projects0, empty = c(NA, "NA"))


## projects
proj_tpl <- read_lines("scripts/proyecto-template.md") %>% paste(collapse = "\n")

projs <- transpose(projects0)
proj <- projs[[sample(length(projs),1)]]
proj$type <- ""

proj_defaults <- list(
  name = "_NOMBRE INICIATIVA NO ENCONTRADO_",
  description = NULL,
  type = "Desconocido"
)
proj2 <- modifyList(proj_defaults, proj)
proj2$uid <- proj2$name
proj2$name <- gsub("'", "\\\\'", proj2$name)
proj2$description <- gsub("'", "\\\\'", proj2$description)
glue_data(proj2, proj_tpl)

### Generate files
projs <- projects0 %>% transpose()

all_proj <- map(projs, safely(function(proj){
  proj2 <- modifyList(proj_defaults, proj)
  proj2$name <- gsub("'", "\\\\'", proj2$name)
  proj2$uid <- mop::create_slug(proj2$name)
  proj2$description <- gsub("'", "\\\\'", proj2$description)
  md <- glue_data(proj2, proj_tpl)
  write_lines(md, paste0("content/proyectos/", proj2$uid, ".md"))
  proj2
}))

