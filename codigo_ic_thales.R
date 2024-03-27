# isso aqui define o diretório do script como diretório atual
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(rvest)
library(dplyr)
library(magrittr)
library(stringr)
library(openxlsx)

data <- data.frame()

for (i in seq(from = 1, to = 8, by = 1)) {
  url <- paste0("https://www.adorocinema.com/filmes/numero-cinemas/?page=", i)
  
  pagina <- read_html(url)
  
  # Aqui retira-se os títulos dos filmes dessa página
  Titulo <- html_nodes(pagina, ".entity-card-list .meta-title-link") %>% html_text()
  
  # O mesmo aqui, só que para a descrição do filme
  Descricao <- html_nodes(pagina, ".meta-body-info") %>% html_text()
  
  # Extrair a duração com a função "str_extract" a partir do formato "NÚMEROh NÚMEROmin"
  # Ou seja, a função procura na string se tem algum trecho nesse formato e extrai ele
  Duracao <- str_extract(Descricao, "\\d+h \\d+min")
  
  # Criar um data frame com os dados extraídos
  page_data <- data.frame(Titulo, Descricao, Duracao)
  
  # Juntar os dados
  data <- bind_rows(data, page_data)
}

# Aqui a gente ordena o conjunto de dados em ordem crescente relativo a duração do filme
data <- data %>% arrange(as.numeric(gsub("\\D", "", Duracao)))

view(data)

# Verificar se o diretório "results" existe e criar se não existir
if (!file.exists("results")) {
  dir.create("results")
}

# Escrever os dados no arquivo Excel
write.xlsx(data, "results/cinema_data.xlsx", rowNames = FALSE)


