\# Sistema de Pedido de Vendas



Sistema simples de gestão de Clientes, Produtos e Pedidos de Venda desenvolvido em Delphi com arquitetura \*\*MVC\*\*, persistência em \*\*SQLite\*\* via \*\*FireDAC\*\*, aplicando conceitos de \*\*SOLID\*\*, \*\*Fluent Interface\*\*, \*\*Template Method\*\* e \*\*Generics\*\*.



\---



\## 📋 Índice



1\. \[Visão Geral](#-visão-geral)

2\. \[Stack Técnica](#-stack-técnica)

3\. \[Estrutura de Pastas](#-estrutura-de-pastas)

4\. \[Etapa 1 — Conexão e Schema](#-etapa-1--conexão-e-schema)

5\. \[Etapa 2 — BaseDAO Genérico (CRUD Reutilizável)](#-etapa-2--basedao-genérico-crud-reutilizável)

6\. \[Etapa 3 — Entidades com Fluent Interface](#-etapa-3--entidades-com-fluent-interface)

7\. \[Etapa 4 — Controllers](#-etapa-4--controllers)

8\. \[Etapa 5 — Form Padrão (Template Method)](#-etapa-5--form-padrão-template-method)

9\. \[Etapa 6 — Forms de Cadastro Filhos](#-etapa-6--forms-de-cadastro-filhos)

10\. \[Etapa 7 — Pedido de Venda (Composição)](#-etapa-7--pedido-de-venda-composição)

11\. \[Etapa 8 — Utilitários (Validação e Parse)](#-etapa-8--utilitários-validação-e-parse)

12\. \[Padrões de Projeto Aplicados](#-padrões-de-projeto-aplicados)

13\. \[Princípios SOLID Aplicados](#-princípios-solid-aplicados)

14\. \[Tutorial de Instalação e Distribuição](#-tutorial-de-instalação-e-distribuição)

15\. \[Como Executar](#-como-executar)



\---



\## 🎯 Visão Geral



O sistema atende três requisitos funcionais:



| Módulo | Responsabilidade |

|---|---|

| \*\*Clientes\*\* | Cadastro com Nome, CPF/CNPJ e Cidade |

| \*\*Produtos\*\* | Cadastro com Descrição, Preço de Venda e Unidade |

| \*\*Pedido de Venda\*\* | Seleção de cliente, adição de itens e totalização |



O foco da arquitetura é \*\*separação de responsabilidades\*\* e \*\*reaproveitamento de código\*\* — não duplicar lógica de CRUD, validação ou montagem de formulários.



\---



\## 🛠 Stack Técnica



\- \*\*Linguagem:\*\* Delphi (Object Pascal)

\- \*\*UI:\*\* VCL (Visual Component Library)

\- \*\*Banco:\*\* SQLite

\- \*\*Acesso a dados:\*\* FireDAC

\- \*\*Padrão arquitetural:\*\* MVC (Model-View-Controller)

\- \*\*Estilo de código:\*\* Fluent Interface + Generics + Template Method



\---



\## 📁 Estrutura de Pastas



```

/src

├── /Model

│   ├── Model.Connection.pas      ← Conexão FireDAC + criação do schema

│   ├── Model.BaseDAO.pas         ← CRUD genérico reutilizável

│   ├── Model.Cliente.pas         ← Entidade + DAO específico

│   ├── Model.Produto.pas

│   ├── Model.ItemPedido.pas

│   └── Model.Pedido.pas

├── /Controller

│   ├── Controller.Cliente.pas

│   ├── Controller.Produto.pas

│   └── Controller.Pedido.pas

├── /View

│   ├── View.Principal.pas

│   ├── View.Clientes.pas         ← herda de ufPadrao

│   ├── View.Produtos.pas         ← herda de ufPadrao

│   └── View.Pedido.Venda.pas

├── /Padrao

│   └── ufPadrao.pas              ← Form pai (Template Method)

└── /Util

&#x20;   ├── Util.Numero.pas           ← Parse e formatação de valores

&#x20;   └── Util.Validador.pas        ← Validação fluent reutilizável

```



A divisão segue \*\*MVC clássico\*\* com duas pastas extras:

\- \*\*`Padrao`\*\*: form pai herdável (recurso de Visual Form Inheritance do Delphi)

\- \*\*`Util`\*\*: código compartilhado entre camadas



\---



\## 🔌 Etapa 1 — Conexão e Schema



\### O que faz



A unit `Model.Connection.pas` cria e mantém a conexão FireDAC com SQLite, e cria as tabelas automaticamente na primeira execução.



\### Por que assim



\- \*\*Singleton estático\*\* (`class var FConn`): garante uma única conexão pro app inteiro. SQLite trabalha bem com conexão única.

\- \*\*Lazy initialization\*\* (`if not Assigned(FConn)`): conexão só é aberta quando o primeiro form chama `TConnection.Get`. Evita custo de inicialização desnecessário.

\- \*\*Schema idempotente\*\* (`CREATE TABLE IF NOT EXISTS`): pode rodar quantas vezes quiser, só cria se não existir. Funciona como migration simplificada.

\- \*\*`ForeignKeys=True`\*\* na string de conexão: SQLite vem com FK \*\*desligada\*\* por padrão (legado histórico). Liga pra valer o `ON DELETE CASCADE`.



\### Schema do banco



| Tabela | Campos principais | FKs |

|---|---|---|

| `clientes` | id, nome, documento (UNIQUE), cidade | — |

| `produtos` | id, descricao, preco\_venda, unidade | — |

| `pedidos` | id, data\_emissao, cliente\_id, total | → clientes |

| `pedido\_itens` | id, pedido\_id, produto\_id, quantidade, valor\_unitario | → pedidos (CASCADE), produtos |



\### Decisões importantes



\- \*\*`id INTEGER PRIMARY KEY AUTOINCREMENT`\*\*: SQLite gerencia o autoincremento. Mais simples que UUID e suficiente pra escala do projeto.

\- \*\*`total` denormalizado em `pedidos`\*\*: redundância proposital. Evita SUM nos itens em toda listagem. Recalculado a cada gravação.

\- \*\*`ON DELETE CASCADE` nos itens\*\*: apagar pedido apaga itens junto. Garante integridade sem código extra.



\---



\## 🔄 Etapa 2 — BaseDAO Genérico (CRUD Reutilizável)



\### O que faz



`Model.BaseDAO.pas` implementa \*\*CRUD genérico\*\* usando Generics do Delphi (`TBaseDAO<T>`). Toda entidade que herdar dela ganha automaticamente: `Inserir`, `Atualizar`, `Excluir`, `BuscarPorId`, `Listar`.



\### Como funciona



A classe `TEntidade` define um contrato que toda entidade deve cumprir:



```delphi

class function NomeTabela: string; virtual; abstract;

class function CamposInsert: string; virtual; abstract;

class function CamposUpdate: string; virtual; abstract;

procedure DoDataset(Q: TFDQuery); virtual; abstract;

procedure ParaParams(Q: TFDQuery); virtual; abstract;

```



A entidade "diz" qual é sua tabela, seus campos e como serializar/deserializar. O `TBaseDAO<T>` faz o resto.



\### Por que essa abordagem



| Sem BaseDAO | Com BaseDAO |

|---|---|

| Cada entidade tem seu próprio Inserir, Atualizar, etc. | Métodos vêm de graça pela herança |

| SQL repetido em vários lugares | SQL gerado dinamicamente |

| Adicionar nova entidade = copiar/colar CRUD | Adicionar entidade = 3 métodos abstratos |

| Manutenção dolorosa | Manutenção centralizada |



\### Exemplo



```delphi

TProdutoDAO = class(TBaseDAO<TProduto>); // ← uma linha

// Pronto: Inserir, Atualizar, Excluir, BuscarPorId, Listar funcionando

```



\### O que \*\*não\*\* é genérico



Operações específicas da entidade ficam no DAO concreto:



```delphi

TClienteDAO = class(TBaseDAO<TCliente>)

public

&#x20; class function BuscarPorDocumento(const ADocumento: string): TCliente;

end;

```



A regra: \*\*CRUD genérico fica no pai. Consultas de domínio ficam na filha.\*\*



\---



\## 🎨 Etapa 3 — Entidades com Fluent Interface



\### O que faz



Cada entidade (`TCliente`, `TProduto`, `TPedido`) tem métodos fluent que retornam `Self`, permitindo encadeamento.



\### Exemplo



```delphi

Cliente := TCliente.Create

&#x20; .ComId(15)

&#x20; .ComNome('João Silva')

&#x20; .ComDocumento('12345678909')

&#x20; .NaCidade('Sinop');

```



\### Por que fluent



\- \*\*Legibilidade\*\*: o código se lê quase como linguagem natural

\- \*\*Construção sem variáveis intermediárias\*\*: não precisa criar `Cliente`, depois setar uma a uma

\- \*\*Encadeamento com sub-builders\*\* (caso do `TPedido.ComItem`): permite estrutura aninhada visível



\### Caso especial — `TPedido.ComItem`



```delphi

Pedido := TPedido.Create

&#x20; .ParaCliente(FIdCliente)

&#x20; .EmitidoEm(Now)

&#x20; .ComItem(produto1Id, 2, 1500.00)

&#x20; .ComItem(produto2Id, 1, 350.00);

```



Cada `ComItem` cria um `TItemPedido` internamente, adiciona à lista, e retorna o `TPedido` pra continuar o encadeamento. Padrão "\*\*fluent com sub-construção interna\*\*".



\### Quando NÃO usar fluent



\- \*\*Setters de leitura de banco\*\* (não escreve, só lê)

\- \*\*Métodos com side-effect crítico\*\* (gravar no banco, enviar e-mail)

\- \*\*Properties triviais\*\* (Id que vem do banco)



O fluent foi aplicado \*\*só em construção/montagem\*\*, não em operações de persistência.



\---



\## 🎮 Etapa 4 — Controllers



\### O que faz



Controllers são a \*\*camada de aplicação\*\*: validam regras, orquestram DAOs e expõem operações pra View.



\### Estrutura típica



```delphi

TClienteController = class

public

&#x20; function Salvar(const ACliente: TCliente): string;

&#x20; procedure Excluir(AId: Integer);

&#x20; function BuscarPorId(AId: Integer): TCliente;

&#x20; function Listar: TObjectList<TCliente>;

end;

```



\### Por que `Salvar` retorna `string` em vez de `Boolean` ou exception



\- \*\*String vazia = sucesso\*\* | \*\*String com texto = mensagem de erro\*\*

\- Mais fácil de exibir na View (`ShowMessage(Erro)`)

\- Evita exception pra fluxo previsível (cliente com documento duplicado não é "excepcional")



\### Regra de validação centralizada



O Controller usa o `TValidador` (Etapa 8) pra acumular erros e retornar o primeiro:



```delphi

Result := TValidador.Novo

&#x20; .Quando(Trim(ACliente.Nome) = '',       'Nome obrigatório')

&#x20; .Quando(Trim(ACliente.Documento) = '',  'Documento obrigatório')

&#x20; .Quando(DocumentoDuplicado,             'Documento já cadastrado')

.PrimeiroErro;

```



\### Separação Controller vs DAO



| Controller | DAO |

|---|---|

| Aplica regras de negócio | Executa SQL |

| Valida antes de salvar | Persiste sem questionar |

| Conhece outras entidades | Conhece só sua tabela |

| Decide o que fazer | Faz o que mandam |



\---



\## 🏗 Etapa 5 — Form Padrão (Template Method)



\### O que faz



`ufPadrao.pas` é um form pai abstrato que implementa o \*\*fluxo padrão de cadastro\*\*: Novo, Editar, Excluir, Salvar, Cancelar. Os forms filhos só implementam o que muda.



A unit fica na pasta `/Padrao` pra deixar claro que é um recurso compartilhado, não uma View específica.



\### O padrão por trás



\*\*Template Method Pattern\*\* (Gang of Four) — combinado com \*\*Visual Form Inheritance\*\* (recurso nativo do Delphi).



\### Como funciona



```

Usuário clica "Salvar"

&#x20;       ↓

TfrmPadrao.btnSalvarClick (genérico)

&#x20;       ↓

Chama SalvarRegistro (virtual abstract)

&#x20;       ↓

TViewClientes.SalvarRegistro (específico)

```



O pai define o \*\*algoritmo\*\* (validar → salvar → atualizar grid → mudar modo). A filha define \*\*detalhes\*\* (qual entidade montar, qual controller chamar).



\### Métodos do contrato



```delphi

// FILHA OBRIGADA A IMPLEMENTAR

function SQLListagem: string; virtual; abstract;

procedure CarregarRegistroParaEdicao(AId: Integer); virtual; abstract;

function SalvarRegistro(AId: Integer): string; virtual; abstract;

procedure ExcluirRegistro(AId: Integer); virtual; abstract;

procedure LimparCamposEdicao; virtual; abstract;

function NomeEntidade: string; virtual; abstract;



// HOOKS OPCIONAIS (filha PODE sobrescrever)

procedure ConfigurarGrid; virtual;

function PodeExcluir(AId: Integer): Boolean; virtual;

procedure DepoisDeSalvar; virtual;

procedure AntesDeEntrarEmEdicao; virtual;

```



\### Por que esse padrão



\- \*\*DRY (Don't Repeat Yourself)\*\*: fluxo de cadastro existe uma vez só

\- \*\*Pressão de contrato\*\*: `abstract` força a filha a implementar

\- \*\*Hooks opcionais\*\*: filha personaliza sem reescrever tudo

\- \*\*Mudança de UI atinge todos os cadastros\*\*: trocar layout do form pai propaga pra todos os filhos



\### FDQuery vs ClientDataSet



Foi escolhido `TFDQuery` direto (não `TClientDataSet`) porque:



\- Integração nativa com FireDAC (sem conversões)

\- Filtros via `Filter`/`Filtered` ou `IndexFieldNames`

\- Ordenação por coluna do grid funciona sem código extra

\- O `SQLListagem` da filha vai direto pra `qryLista.SQL.Text`



\### Por que o nome `ufPadrao`



Convenção comum em projetos Delphi:

\- \*\*`u`\*\* = unit

\- \*\*`f`\*\* = form

\- \*\*`Padrao`\*\* = papel desempenhado



Mantém compatibilidade com padrões clássicos de nomenclatura Delphi sem perder clareza.



\---



\## 👥 Etapa 6 — Forms de Cadastro Filhos



\### O que faz



`View.Clientes` e `View.Produtos` herdam de `TfrmPadrao` e implementam só o que é específico de cada entidade.



\### Tamanho da filha



Cada filha tem \~80 linhas de código contra \~250 do pai. \*\*Reuso de 75% do código.\*\*



\### Estrutura típica



```delphi

TViewClientes = class(TfrmPadrao)

&#x20; edtNome: TEdit;

&#x20; edtDocumento: TEdit;

&#x20; edtCidade: TEdit;

private

&#x20; FController: TClienteController;

protected

&#x20; function SQLListagem: string; override;

&#x20; procedure CarregarRegistroParaEdicao(AId: Integer); override;

&#x20; function SalvarRegistro(AId: Integer): string; override;

&#x20; // ...

end;

```



\### Validações com Fluent Validator



```delphi

if not TValidador.Novo

&#x20; .Quando(Trim(edtNome.Text) = '',      'Nome obrigatório')      .FocarEm(edtNome)

&#x20; .Quando(Trim(edtDocumento.Text) = '', 'Documento obrigatório') .FocarEm(edtDocumento)

&#x20; .Quando(Trim(edtCidade.Text) = '',    'Cidade obrigatória')    .FocarEm(edtCidade)

.Valido then Exit;

```



Sem o validador, seriam 12 linhas com `if/ShowMessage/SetFocus/Exit` espalhados. Com ele, 3 linhas declarativas.



\### Forms com duplo uso — cadastro e seleção



Os mesmos forms `View.Clientes` e `View.Produtos` funcionam como \*\*forms de seleção\*\* quando chamados pelo pedido. Uma flag `FShowMenu` controla o comportamento:



\- `FShowMenu = True` → modo cadastro completo (com menu)

\- `FShowMenu = False` → modo seleção (chamado via `ShowModal`)



```delphi

// No pedido de venda:

ViewClientes := TViewClientes.Create(Application);

ViewClientes.FShowMenu := False;  // modo seleção



if ViewClientes.ShowModal = mrOk then

&#x20; FIdCliente := ViewClientes.FDQueryid.AsInteger;

```



\*\*Vantagens dessa decisão:\*\*



\- \*\*Zero forms de busca duplicados\*\* — não precisa criar `View.BuscaCliente`, `View.BuscaProduto`

\- \*\*Consistência visual\*\* — mesmo grid, mesmo filtro, mesma ordenação em todo lugar

\- \*\*Cadastro inline\*\* — usuário pode até cadastrar novo cliente sem sair do pedido

\- \*\*Manutenção centralizada\*\* — mudou um campo? Mudou em todo lugar



\---



\## 🛒 Etapa 7 — Pedido de Venda (Composição)



\### O que faz



`View.Pedido.Venda.pas` permite criar um pedido completo: seleciona cliente, adiciona vários itens, calcula total e grava em transação.



\### Estrutura visual



```

┌─────────────────────────────────────────────┐

│ Cliente: \[\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_] \[B]         │

│ Produto: \[\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_] \[B]         │

│ Un: \[\_\_] Vlr: \[\_\_\_\_\_\_] Qtd: \[\_\_\_\_] Total:\[\_]│

│                                       \[+]   │

├─────────────────────────────────────────────┤

│ \[Grid de itens]                             │

│  ID PROD | DESCRIÇÃO | QTD | VLR UNITÁRIO   │

├─────────────────────────────────────────────┤

│ Total: R$ 1.500,00      \[Gravar] \[Cancelar] │

└─────────────────────────────────────────────┘

```



\### Composição em vez de herança



Esse form \*\*não herda\*\* do `ufPadrao` porque o fluxo é diferente:



\- Não tem grid de listagem de pedidos no mesmo form

\- Tem cabeçalho + itens (estrutura mestre-detalhe)

\- Não tem Novo/Editar/Excluir de pedido — sempre criação nova

\- Reusa os forms de cadastro (Clientes/Produtos) em modo seleção



\*\*Princípio aplicado:\*\* "preferir composição sobre herança quando o fluxo diverge".



\### Seleção de cliente e produto via botão \[B]



Os botões `\[B]` ao lado de Cliente e Produto abrem os próprios forms de cadastro em modo seleção:



```delphi

procedure TViewPedidoVenda.btnBuscarClienteClick(Sender: TObject);

begin

&#x20; ViewClientes := TViewClientes.Create(Application);

&#x20; ViewClientes.FShowMenu := False;



&#x20; if ViewClientes.ShowModal = mrOk then

&#x20; begin

&#x20;   FIdCliente      := ViewClientes.FDQueryid.AsInteger;

&#x20;   edtCliente.Text := ViewClientes.FDQuerydescricao.AsString;

&#x20; end;

&#x20; FreeAndNil(ViewClientes);

end;

```



\### FDMemTable pros itens



Os itens ficam num `TFDMemTable` em memória. Só ao clicar "Gravar" a transação acontece. Vantagens:



\- Usuário pode revisar antes de gravar

\- Cancelar é instantâneo (não toca no banco)

\- Não polui o banco com pedidos abandonados



\### Gravação transacional



```delphi

Pedido := TPedido.Create

&#x20; .ParaCliente(FIdCliente)

&#x20; .EmitidoEm(Now);



FDQueryPedido.First;

while not FDQueryPedido.Eof do

begin

&#x20; Pedido.ComItem(produtoId, qtd, vlr);

&#x20; FDQueryPedido.Next;

end;



FPedidoController.Salvar(Pedido); // ← transação no DAO

```



O `TPedidoDAO.Salvar` envolve INSERT do cabeçalho + INSERT dos itens em uma única transação. Se algo falhar no meio, \*\*rollback total\*\*.



\---



\## 🧰 Etapa 8 — Utilitários (Validação e Parse)



\### Util.Validador.pas — Fluent Validator



Centraliza o padrão "validar → mostrar mensagem → focar controle" em uma interface fluent.



\*\*Antes:\*\*

```delphi

if Trim(edtNome.Text) = '' then

begin

&#x20; ShowMessage('Nome obrigatório');

&#x20; edtNome.SetFocus;

&#x20; Exit;

end;

if Trim(edtCidade.Text) = '' then

begin

&#x20; ShowMessage('Cidade obrigatória');

&#x20; edtCidade.SetFocus;

&#x20; Exit;

end;

```



\*\*Depois:\*\*

```delphi

if not TValidador.Novo

&#x20; .Quando(Trim(edtNome.Text) = '',   'Nome obrigatório')   .FocarEm(edtNome)

&#x20; .Quando(Trim(edtCidade.Text) = '', 'Cidade obrigatória') .FocarEm(edtCidade)

.Valido then Exit;

```



\*\*Recursos:\*\*

\- `.Quando(cond, msg)` — adiciona regra

\- `.FocarEm(controle)` — foca o controle se essa regra falhou

\- `.Executar(acao)` — executa lambda se essa regra falhou (ex: abrir busca)

\- `.Valido` — mostra dialog e retorna boolean

\- `.PrimeiroErro` — retorna string do erro (uso em Controller, sem UI)



A mesma classe serve pra \*\*View\*\* (com UI) e \*\*Controller\*\* (sem UI). Polimorfismo bem aplicado.



\### Util.Numero.pas — Parse robusto



Resolve o problema clássico do `StrToCurrDef('1.000,00', 0)` retornar `0` por confusão de separadores.



```delphi

function ParseValor(const ATexto: string): Currency;

var Limpo: string;

begin

&#x20; Limpo := StringReplace(ATexto, '.', '', \[rfReplaceAll]);

&#x20; Limpo := StringReplace(Limpo, ',', FormatSettings.DecimalSeparator, \[rfReplaceAll]);

&#x20; Result := StrToCurrDef(Limpo, 0);

end;

```



\*\*Por que existe:\*\* o parser do Delphi confunde ponto decimal com ponto de milhar dependendo do locale. A função \*\*limpa o texto\*\* antes de converter, eliminando ambiguidade.



\*\*Regra:\*\* todo lugar que lê valor formatado de `TEdit` usa `ParseValor`, nunca `StrToCurrDef`/`StrToFloatDef` direto.



\---



\## 🎨 Padrões de Projeto Aplicados



| Padrão | Onde | Por quê |

|---|---|---|

| \*\*Template Method\*\* | `ufPadrao` | Define algoritmo no pai, detalhes na filha |

| \*\*Generics\*\* | `TBaseDAO<T>` | CRUD reutilizável sem perder tipagem |

| \*\*Fluent Interface\*\* | Entidades, `TValidador` | API legível e encadeável |

| \*\*Singleton\*\* | `TConnection` | Uma conexão pro app |

| \*\*DAO (Data Access Object)\*\* | `TClienteDAO`, etc. | Isola SQL do domínio |

| \*\*MVC\*\* | Estrutura geral | Separação de responsabilidades |

| \*\*Composition over Inheritance\*\* | `View.Pedido.Venda` | Quando fluxo é diferente do padrão |

| \*\*Visual Form Inheritance\*\* | Forms herdados | Recurso nativo Delphi pra UI hierárquica |

| \*\*Reuse Form as Dialog\*\* | `View.Clientes` e `View.Produtos` | Mesmo form serve a cadastro e seleção |



\---



\## ⚖ Princípios SOLID Aplicados



| Princípio | Como aparece no projeto |

|---|---|

| \*\*S — Single Responsibility\*\* | `Connection` só conecta. `BaseDAO` só persiste. `Controller` só orquestra. `Validador` só valida. |

| \*\*O — Open/Closed\*\* | Adicionar entidade nova não modifica `BaseDAO`. Adicionar regra nova não modifica `Validador`. |

| \*\*L — Liskov Substitution\*\* | Toda subclasse de `TEntidade` funciona com `TBaseDAO<T>`. Todo `TfrmPadrao` filho funciona com o fluxo do pai. |

| \*\*I — Interface Segregation\*\* | `IValidador` tem só 5 métodos coesos. Não há "interface gigante que faz tudo". |

| \*\*D — Dependency Inversion\*\* | Controllers dependem de DAOs concretos (atalho pragmático). Em versão DDD plena, dependeriam de `IRepository`. |



\---



\## 📦 Tutorial de Instalação e Distribuição



O SisVendas \*\*não precisa de instalador separado\*\*. Toda a inicialização (criação de pastas, extração da DLL, criação do banco) ocorre automaticamente dentro do próprio executável.



\### Fluxo da primeira execução



```

Usuário abre SisVendas.exe

&#x20;       │

&#x20;       ▼

1\. Existe C:\\SisVendas ?

&#x20;  ├── Não → cria a pasta

&#x20;  └── Sim → continua

&#x20;       │

&#x20;       ▼

2\. Existe C:\\SisVendas\\sqlite3.dll ?

&#x20;  ├── Não → extrai do recurso embutido no exe e grava na pasta

&#x20;  └── Sim → continua

&#x20;       │

&#x20;       ▼

3\. Existe C:\\SisVendas\\pedidos.db ?

&#x20;  ├── Não → FireDAC cria o arquivo SQLite automaticamente

&#x20;  └── Sim → abre o banco existente

&#x20;       │

&#x20;       ▼

4\. Executa as migrations (CREATE TABLE IF NOT EXISTS)

&#x20;  → tabelas criadas se não existirem, ignoradas se já existirem

&#x20;       │

&#x20;       ▼

5\. Sistema pronto para uso

```



\### Como funciona o embutimento da DLL no exe



\#### 1. Geração do arquivo de recurso



Antes de compilar o projeto, é necessário executar uma vez:



```bash

brcc32.exe sqlite3res.rc

```



O `sqlite3res.rc` contém:



```rc

SQLITE3DLL RCDATA "DLL\\sqlite3.dll"

```



O `brcc32` lê esse arquivo e converte a `sqlite3.dll` em um bloco de bytes binários, gerando o `sqlite3res.res`.



\#### 2. Embutimento do recurso no exe



A diretiva no código:



```delphi

{$R sqlite3res.res}

```



Instrui o compilador Delphi a incluir o conteúdo do `.res` dentro do próprio `.exe`. O resultado é um executável \*\*único e autocontido\*\* — sem dependências externas.



\#### 3. Extração em tempo de execução



Quando o programa roda pela primeira vez, este trecho é executado:



```delphi

RS := TResourceStream.Create(HInstance, 'SQLITE3DLL', RT\_RCDATA);

RS.SaveToFile('C:\\SisVendas\\sqlite3.dll');

```



O `TResourceStream` lê o bloco de bytes embutido no exe e o grava como arquivo em disco. A partir daí, o FireDAC consegue carregar o driver SQLite normalmente.



\### Estrutura de arquivos no ambiente de desenvolvimento



```

MeuProjeto\\

├── DLL\\

│   └── sqlite3.dll           ← DLL original (fonte para o recurso)

├── sqlite3res.rc             ← declaração do recurso (você cria)

├── sqlite3res.res            ← gerado pelo brcc32 (não commitar\*)

├── SisVendas.dproj

├── Model.Connection.pas

└── Win32\\

&#x20;   └── Debug\\

&#x20;       └── SisVendas.exe     ← exe já contém a DLL embutida

```



> \*\*\\\*\*\* O `.res` é gerado a partir do `.rc` + da DLL. Não precisa ir pro repositório Git — basta rodar o `brcc32` uma vez ao clonar o projeto.



\### Estrutura de arquivos no computador do cliente



```

C:\\SisVendas\\

├── sqlite3.dll    ← extraída automaticamente na 1ª execução

└── pedidos.db     ← criado automaticamente na 1ª execução

```



O cliente recebe \*\*apenas o `SisVendas.exe`\*\*. Não precisa instalar nada.



\### Pré-requisitos para desenvolvimento



| Requisito | Onde obter |

|---|---|

| `sqlite3.dll` (32 ou 64 bits conforme a plataforma alvo) | \[sqlite.org/download.html](https://sqlite.org/download.html) → Precompiled Binaries for Windows |

| `brcc32.exe` | Já incluso no RAD Studio / Delphi — sem instalação adicional |



\### Passo a passo para novos desenvolvedores



1\. Clonar o repositório

2\. Baixar a `sqlite3.dll` compatível com a plataforma (Win32 ou Win64)

3\. Colocar a DLL em `<raiz do projeto>\\DLL\\sqlite3.dll`

4\. Abrir o \*\*Prompt do RAD Studio\*\* (Ferramentas → Prompt de Comando do RAD Studio)

5\. Navegar até a raiz do projeto:

&#x20;  ```bash

&#x20;  cd C:\\caminho\\do\\projeto

&#x20;  ```

6\. Compilar o recurso:

&#x20;  ```bash

&#x20;  brcc32.exe sqlite3res.rc

&#x20;  ```

7\. Abrir o projeto no Delphi e compilar normalmente (F9)

8\. Executar — a pasta `C:\\SisVendas` e o banco serão criados automaticamente



\### Observações importantes



\#### Primeira execução requer permissão de escrita em C:\\



Em Windows 10/11 com UAC ativo, gravar em `C:\\` pode exigir que o exe seja executado como Administrador \*\*apenas na primeira vez\*\* (pra criar a pasta `C:\\SisVendas` e extrair a DLL).



Nas execuções seguintes, o programa já encontra a pasta e os arquivos prontos e \*\*não precisa de elevação\*\*.



\#### A DLL só é extraída uma vez



O código verifica se `sqlite3.dll` já existe antes de extrair:



```delphi

if not TFile.Exists(DllDestino) then

&#x20; ExtrairDLL(DllDestino);

```



Substituir o exe por uma versão nova \*\*não sobrescreve a DLL\*\* existente no cliente. Se precisar atualizar a DLL, delete o arquivo em `C:\\SisVendas\\` manualmente ou adicione lógica de versionamento.



\#### As migrations são idempotentes



Todas as tabelas usam `CREATE TABLE IF NOT EXISTS`. Isso significa que rodar uma versão nova do exe \*\*nunca destrói dados existentes\*\* — só cria o que ainda não existe.



\---



\## ▶ Como Executar



\### Pré-requisitos

\- Delphi 10.3 Rio ou superior (com suporte a Generics e FireDAC)

\- Driver SQLite (vem com FireDAC)



\### Passos

1\. Abrir `SisVendas.dproj` no Delphi

2\. Build (Shift+F9)

3\. Run (F9)



\### Primeira execução

\- A pasta `C:\\SisVendas` é criada automaticamente

\- A `sqlite3.dll` é extraída do exe pra essa pasta

\- O arquivo `pedidos.db` é criado automaticamente

\- As tabelas são criadas via `CREATE TABLE IF NOT EXISTS`

\- Não há dados de exemplo — comece cadastrando cliente e produto antes de fazer pedido



\---



\## 📝 Considerações Finais



Este projeto prioriza \*\*clareza arquitetural e reuso de código\*\* sobre completude funcional. Decisões importantes:



\- \*\*In-memory + SQLite\*\*: foco no fluxo de dados, não na infra

\- \*\*MVC clássico\*\*: padrão pedido na proposta, mais simples que DDD completo

\- \*\*Fluent everywhere\*\*: aprendizado e legibilidade, não modismo

\- \*\*Generics no BaseDAO\*\*: mostra domínio do recurso, evita código repetido

\- \*\*Template Method no `ufPadrao`\*\*: reuso pesado de UI sem perder flexibilidade

\- \*\*Form duplo-uso (cadastro + seleção)\*\*: economia de código sem perder clareza

\- \*\*Distribuição self-contained\*\*: usuário final recebe um único `.exe`



A estrutura permite evoluir naturalmente para:

\- Persistência em outro banco (trocar `Model.Connection` e DAOs)

\- Camada de domínio mais rica (adicionar Value Objects e Aggregate Roots)

\- Testes unitários (Controllers já são testáveis isoladamente)

\- Relatórios e regras fiscais (extensão dos Controllers)



\---



\*\*Desenvolvido como avaliação técnica — Delphi / SOLID / Clean Code\*\*

