## Configuração de auto cluster scaling com kubernetes
Esse projeto proporciona o autoscaling de nodes de forma automatizada. Quando os pods estão configurados com HPA (Horizontal Pod Autoscaler) e houver a necessidade de adicionar novos pods, o cluster estará apto para fazer autoscaling das máquinas virtuais que o compõe.

#### Exemplificando os arquivos de configuração

1. autoClusterScale.yaml: 
    a. Criação de um service account para os processos do pod