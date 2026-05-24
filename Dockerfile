FROM archlinux:latest

# Atualizando ambiente
RUN pacman -Syyu --noconfirm

# Instalando dependências necessárias
RUN pacman -S --noconfirm \
    base-devel gcc gdb make cmake \
    nasm qemu-full git

# Limpando cache do pacman
RUN pacman -Scc --noconfirm

# Selecionando pasta de trabalho
WORKDIR /workspace

# Criando novo usuário
RUN useradd -m dev

# Entrando em modo de usuario
USER dev

# Expondo a porta 1234 para debug com gdb

EXPOSE 1234

# Executando o bash
CMD [ "/bin/bash" ]