Visão Geral do Sistema

Um showroom VR para concessionárias transforma a experiência de vendas automotivas ao permitir que clientes explorem veículos de forma imersiva através do ​Meta Quest 3, enquanto vendedores controlam toda a experiência via tablet. O sistema utiliza ​Gaussian Splatting para renderizar modelos fotorrealistas de veículos, oferecendo personalização em tempo real de cores, rodas e acessórios, além de visualização detalhada de interiores—tudo isso gerenciado de forma eficiente para contornar as limitações de processamento do headset.


​Arquitetura de Três Camadas

O sistema opera através de três componentes principais que trabalham em conjunto:

Quest 3 (Cliente de Visualização): O headset funciona como um display imersivo, focado exclusivamente em renderizar o conteúdo 3D. Não processa lógica de negócio nem armazena todos os assets simultaneamente—carrega apenas o cenário e veículo atualmente visualizados, liberando memória após cada sessão.

Tablet do Vendedor (Interface de Controle): Centraliza toda a interação do vendedor, permitindo selecionar veículos, aplicar personalizações e navegar entre diferentes visualizações. O tablet envia comandos que o Quest 3 executa instantaneamente, mantendo o vendedor no controle da narrativa de vendas.

Servidor Backend: Gerencia o catálogo de veículos, armazena os modelos Gaussian Splatting e processa requisições de personalização. Pode estar hospedado localmente na concessionária ou na nuvem, dependendo dos requisitos de latência e infraestrutura.


Software de Apoio

Software de captura envia as imagens para o servidor. O servidor processa as imagens renderizando para gerar modelos 3D utilizando a técnica Gaussian Splatting.

