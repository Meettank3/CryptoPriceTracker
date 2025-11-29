import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Crypto Price Tracker',
        theme: ThemeData(
          useMaterial3: true, // Use the latest Google design
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.grey, 
            brightness: Brightness.dark
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  Map<String, dynamic> cryptoPrices = {};
  bool isLoading = false;
  // will fetch price
  void getPrice() async{
    isLoading = true;   
    notifyListeners();
    var url = Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana,dogecoin&vs_currencies=usd');
    var response = await http.get(url);    
    if(response.statusCode == 200){
      var jsonResponse = jsonDecode(response.body);
      cryptoPrices = jsonResponse;    
      jsonResponse.forEach( ( key, value )=>{
        debugPrint('$key: $value'),        
      });
    isLoading = false;
    notifyListeners();
    }
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    var appState = context.watch<MyAppState>();
    var coinList = appState.cryptoPrices.keys.toList();

    // for responsive sorting high to low
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    var isDesktopWidth = screenWidth > 600; // 600px is a standard "break point"
    var isDesktopHeight = screenHeight > 800;
    var isDesktop = isDesktopWidth && isDesktopHeight;
    coinList.sort(
      (a, b) {
      var priceA = appState.cryptoPrices[a]['usd'];
      var priceB = appState.cryptoPrices[b]['usd'];
      return priceB.compareTo(priceA); // High to Low
      }
    );

    return Scaffold(
      
      appBar: AppBar(
        title: Text('Crypto Price Tracker',style: style),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primaryContainer,
        animateColor: true,
        actions: [
          IconButton(
            onPressed:(){
              setState(() {              
            });
            },
            icon: Icon(Icons.refresh),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(top: isDesktop ? screenHeight * 0.05 : screenHeight * 0.2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [             
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.primary,
                ),
                onPressed: () {
                  appState.getPrice();
                },
                child: Text(" Get Bitcoin Price"),
              ),
              SizedBox(height: 20),
              appState.isLoading 
              ? CircularProgressIndicator() 
              : appState.cryptoPrices.isNotEmpty 
              ? Expanded(
                child: Container(            
                  margin: EdgeInsets.only(top: 10),
                    width: isDesktop ? 600 : screenWidth * 0.9,
                    child: 
                      ListView.builder(   
                        itemCount: coinList.length,         
                        itemBuilder: (context, index){              
                          String key = coinList[index];
                          var value = appState.cryptoPrices[key];
                          return Card(                        
                            color: theme.colorScheme.primaryContainer,
                            elevation: 4, // Adds a nice shadow
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Spacing between cards
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: ListTile( 
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.secondary,                            
                                child: Text(
                                  key[0].toUpperCase(), // Takes first letter 'b' -> 'B'
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),                     
                              title: Text(key.toUpperCase(),
                               style: TextStyle(fontWeight: FontWeight.bold)
                               ,),
                              trailing: Text("\$${value['usd']}",
                               style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary // Make money look green!
                                ),
                              ),
                            ),
                          );
                        }
                        )              
                  ),
              )
              :Text("Click this Button to fetch Coin price", style: style,),
            ],
          ),
        ),
      ),
    );
  }
}
