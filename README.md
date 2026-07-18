<h1 align="center">MyOs - Sistema Operacional Simples</h1>

![Static Badge](https://img.shields.io/badge/Parado-%2523?style=flat-square&color=%23FF8811)

## Objetivo

Após entendimento básico sobre sistema operacionais, ainda mais após aprofundamento em Linux, este projeto surgiu para a compreensão ainda mais profunda de como um SO realmente trabalha por baixo dos panos, como funciona de verdade o gerenciamento de memória, o gerenciamento de arquivos, o gerenciamento de processos e etc

## O que está pronto

O que foi feito até agora foi nada mais que o sistema de boot, lendo de forma pseudo dinâmica o kernel do disco para a memória RAM
**Mas Por quê pseudo dinâmica?**
Pois como o sistema de arquivo ainda não foi feita, não tem como eu saber de forma 100% dinâmica, aonde o kernel se encontra no disco, então uma regra foi aplicada momentaneamente, o kernel começa no segundo setor do disco, ai na compilação, eu passo ao bootloader o tamanho final do kernel, podendo assim ler do setor 1 até N bytes / 512 ( tamanho de 1 setor é de 512 bytes )

<br/>

Uma pequena biblioteca de monitor também está sendo contruída e está parcealmente finalizada, pois com ela, desacoplo o kernel de como o gerenciamento do display é efetuado. Pois o kernel apenas enxerga uma ABI
<br/>
E a biblioteca de monitor é quem fica responsável pela implementação de ABI, sabendo exatamente em que modo de vídeo o monitor estará e como desenhar gráficos no display, seja em direct mode ou em uma VRAM ( Videm Random Access Memory )

## Tecnologias Utilizadas

- Assembly para arquitetura de 16 bits
  - Como pretendo aprender apenas um básico de um sistema operacional, não vou realmente criar um funcional a nível de insdústria, me limitei ao real mode, que opera em 16 bits
- Nasm para a compilação do assembly e injeção de pré-processadores
- Docker para a construção de um ambiente de compilação
  - Utilizei docker para a criação de um ambiente de compilação que seja igual em qualquer lugar, podendo assim ser testado em diferentes OSs ( Windows, Linux, MacOS e quais quer outros sistemas que suportem Docker )

# Próximos Passos

Terminar o sistema de monitor para uma renderização mais complexa, desde quadrados, triângulos, círculos e outras formas geométricas
<br/>
Fazer o sistema de buffer de teclado para uma interação com o usuário
