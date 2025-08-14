# ----- ETAPA 1: O "Builder" -----
# Começamos com a imagem oficial do Dart, que tem a versão correta da linguagem.
FROM dart:stable AS builder

# Instala as ferramentas necessárias (git e zip) para baixar o Flutter.
RUN apt-get update && apt-get install -y git zip unzip

# Cria uma pasta para o SDK do Flutter e clona o repositório do Flutter para dentro dela.
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Adiciona a ferramenta de linha de comando do Flutter ao "caminho" do sistema,
# para que possamos executar comandos como `flutter pub get`.
ENV PATH="/usr/local/flutter/bin:${PATH}"

# Baixa os binários de desenvolvimento do Flutter.
RUN flutter precache

# Define o diretório de trabalho do nosso aplicativo.
WORKDIR /app

# Copia os arquivos de dependência.
COPY pubspec.yaml pubspec.lock ./
# Agora este comando funcionará, pois `flutter` foi instalado acima.
RUN flutter pub get

# Copia todo o código do projeto.
COPY . .

# Compila o aplicativo Flutter para a web.
RUN flutter build web


# ----- ETAPA 2: O "Servidor" Final (Esta parte não muda) -----
FROM nginx:alpine

COPY .docker/nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]