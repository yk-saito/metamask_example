import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static Web3App? _walletConnect;
  static String? _url;
  static SessionData? _sessionData;

  String get deepLinkUrl => 'metamask://wc?uri=$_url';

  @override
  void initState() {
    super.initState();
    _initWalletConnect();
  }

  Future<void> _initWalletConnect() async {
    _walletConnect = await Web3App.createInstance(
      projectId: 'f46f91321f7ac82f929eff53633f52ab',
      metadata: const PairingMetadata(
        name: 'Flutter WalletConnect',
        description: 'Flutter WalletConnect Dapp Example',
        url: 'https://walletconnect.com/',
        icons: [
          'https://walletconnect.com/walletconnect-logo.png',
        ],
      ),
    );
  }

  Future<String?> connectWallet() async {
    if (_walletConnect == null) {
      await _initWalletConnect();
    }

    final ConnectResponse connectResponse = await _walletConnect!.connect(
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          chains: ['eip155:80001'],
          methods: [
            'eth_signTransaction',
            'eth_sendTransaction',
          ],
          events: [
            'chainChanged',
            'accountsChanged',
          ],
        ),
      },
    );

    final Uri? uri = connectResponse.uri;

    if (uri == null) {
      return null;
    }

    final String encodedUrl = Uri.encodeComponent('$uri');

    _url = encodedUrl;

    await launchUrlString(deepLinkUrl, mode: LaunchMode.externalApplication);

    _sessionData = await connectResponse.session.future;

    final String account = NamespaceUtils.getAccount(
      _sessionData!.namespaces.values.first.accounts.first,
    );

    return account;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connect to MetaMask demo',
      home: Center(
        child: ElevatedButton(
          onPressed: () {
            connectWallet().then((value) {
              debugPrint('connected $value');
            }).catchError((error) {
              debugPrint('error $error');
            });
          },
          child: const Text('Connect'),
        ),
      ),
    );
  }
}
