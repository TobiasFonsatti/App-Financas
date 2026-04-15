# App Finanças

> Aplicativo Mobile para Gestão de Finanças Pessoais

**Desenvolvido como avaliação prática (P1) para a disciplina de Dispositivos Móveis - FATEC**

---

## 📋 Sobre o Projeto

App Finanças é um aplicativo mobile desenvolvido em **Flutter/Dart** com o objetivo de oferecer uma solução completa para gestão de finanças pessoais. O aplicativo permite que usuários gerenciem suas transações financeiras, visualizem relatórios financeiros e controlem seus gastos de forma intuitiva e eficiente.

---

## 🎯 Funcionalidades

- ✅ **Autenticação de Usuários**: Login e registro com recuperação de senha
- ✅ **Gestão de Transações**: Adicionar, visualizar e gerenciar transações financeiras
- ✅ **Análise Financeira**: Visualização de dados financeiros através de radar financeiro (gráficos)
- ✅ **Dashboard**: Página inicial com visão geral das finanças
- ✅ **Interface Responsiva**: Design adaptado para diferentes tamanhos de tela
- ✅ **Drawer Menu**: Navegação prática entre as páginas do aplicativo

---

## 🏗️ Arquitetura do Projeto

O projeto segue uma estrutura modular bem organizada:

```
lib/
├── main.dart                          # Ponto de entrada da aplicação
├── view/                              # Telas/Views da aplicação
│   ├── login_view.dart
│   ├── register_view.dart
│   ├── forgot_password_view.dart
│   ├── home_view.dart
│   ├── add_transaction_view.dart
│   ├── transactions_view.dart
│   ├── radar_financeiro_view.dart
│   ├── about_view.dart
│   └── widgets/                       # Componentes reutilizáveis
│       └── app_drawer.dart
├── controller/                        # Controllers (Lógica de Negócio)
│   ├── login_controller.dart
│   ├── forgot_password_controller.dart
│   └── (outros controllers)
├── service/                           # Serviços (Comunicação com API)
│   └── brapi_service.dart
├── model/                             # Modelos de Dados
│   └── brapi_models.dart
└── assets/                            # Recursos (Imagens, Fontes)
    └── images/
```

---

## 📱 Fluxo de Usuário

1. **Autenticação**
   - Novo usuário registra-se através da tela de registro
   - Usuário existente faz login com credenciais
   - Opção de recuperação de senha disponível

2. **Dashboard Principal**
   - Visualização de resumo financeiro
   - Acesso rápido às funcionalidades do app

3. **Gestão de Transações**
   - Adicionar novas transações (receita/despesa)
   - Visualizar histórico de transações
   - Deletar ou editar transações

4. **Análise Financeira**
   - Visualizar radar financeiro com dados gráficos
   - Análise visual da situação financeira

5. **Menu de Navegação**
   - Drawer menu com acesso a todas as seções
   - Link para página "Sobre"

---

## 📊 Integração com API

O projeto utiliza a **BrAPI** (Brasil API) como serviço backend para:
- Autenticação de usuários
- Gerenciamento de transações
- Obtenção de dados financeiros

Detalhes de integração encontram-se em `lib/service/brapi_service.dart`

---

## 🐛 Tratamento de Erros

O aplicativo implementa tratamento robusto de erros com:
- Validação de formulários
- Mensagens de erro ao usuário
- Tratamento de exceções de rede
- Fallback para dados locais quando aplicável

---

## 👥 Autores

**Desenvolvido por:** Artur Ruiz e Tobias Fonsatti  
**Disciplina:** Programação para Dispositivos Móveis  
**Instituição:** FATEC  
**Semestre:** 4°  
**Ano:** 2026

---

## 📄 Licença

Este projeto é fornecido como avaliação acadêmica. Todos os direitos reservados.
