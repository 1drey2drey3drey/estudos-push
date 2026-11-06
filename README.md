# estudos_push

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Status do Firebase

**Situação: Serviço Firebase desativado após a demonstração da atividade.**

O projeto Firebase utilizado durante o desenvolvimento e os testes foi encerrado após a conclusão da demonstração acadêmica.

Durante a implementação, o aplicativo utilizou o Firebase Cloud Messaging (FCM) para realizar três funcionalidades:

- Envio de notificações push simples.
- Envio de notificações personalizadas com imagem.
- Navegação para telas específicas por meio de dados personalizados nas notificações.

**Importante:** o serviço de envio de notificações não está mais disponível no projeto Firebase original. O código-fonte da integração foi mantido neste repositório para fins de consulta e estudo.

Para utilizar novamente as notificações push, será necessário:

1. Criar um novo projeto no Firebase Console.
2. Registrar o aplicativo Android no novo projeto.
3. Executar `flutterfire configure --project=SEU_PROJECT_ID --platforms=android`.
4. Atualizar os arquivos de configuração Firebase gerados.
5. Executar `flutter pub get` e testar novamente a aplicação.

A demonstração original foi realizada em um Samsung S23 com Android 14.
