import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Client? httpClient;
  Web3Client? ethClient;
  final address = '0x75936a0c47FeCEf2367BF8d16901C0B9A9c432b2';
  var myData;
  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    httpClient = Client(); //initializing httpClient
    ethClient = Web3Client(
        //initializing Web3Client
        "https://kovan.infura.io/v3/8a93b1337c3f41f5b7a743f4800e1438",
        httpClient!);

    /// get url from infura
    getBalance();
    super.initState();
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString('assets/abi.json');
    String contractAddresss = '0x8807295CcB5C96E35f4C564b8cd7c0F8dA16253d';
    final contract = DeployedContract(ContractAbi.fromJson(abi, 'cheemsCoin'),
        EthereumAddress.fromHex(contractAddresss));
    return contract; //returning contract to query()
  }

  Future<List<dynamic>> query(String funcName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(funcName);
    final result = ethClient!
        .call(contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<void> getBalance() async {
    // EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> result = await query('getBalance', []);
    setState(() {
      myData = result[0];
    });
  }

  Future<String> submit(String funcName, List<dynamic> args) async {
    EthPrivateKey credentails = EthPrivateKey.fromHex("_____privateKey_____");
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(funcName);
    final result = await ethClient!.sendTransaction(
        credentails,
        Transaction.callContract(
            contract: contract, function: ethFunction, parameters: args),
        chainId: null,
        fetchChainIdFromNetworkId: true);
    return result;
  }

  Future<String> depositCoin() async {
    var bigAmt = BigInt.from(int.parse(controller.text));
    var response = await submit("deposit", [bigAmt]);
    print('deposited');
    return response;
  }

  Future<String> withdrawCoin() async {
    var bigAmt = BigInt.from(int.parse(controller.text));
    var response = await submit("withdraw", [bigAmt]);
    print('withdrawn');
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CheemsCoin'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Balance: ' + myData.toString() + ' CC',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: controller,
              ),
              TextButton.icon(
                  onPressed: () {
                    getBalance();
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Refresh')),
              TextButton.icon(
                  onPressed: () {
                    depositCoin();
                  },
                  icon: Icon(Icons.add),
                  label: Text('Deposit')),
              TextButton.icon(
                  onPressed: () {
                    withdrawCoin();
                  },
                  icon: Icon(Icons.arrow_back),
                  label: Text('Withdraw')),
            ],
          ),
        ),
      ),
    );
  }
}
