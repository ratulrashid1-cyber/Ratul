import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const bg = Color(0xFF0B1017), panel = Color(0xFF151E29), mint = Color(0xFF62E6B5);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(QuitlyApp(prefs: await SharedPreferences.getInstance()));
}
class QuitlyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const QuitlyApp({super.key, required this.prefs});
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, title: 'QUITLY',
    theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(primary: mint, surface: panel),
      appBarTheme: const AppBarTheme(backgroundColor: bg, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: panel,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
    home: HomePage(prefs: prefs));
}
class HomePage extends StatefulWidget {
  final SharedPreferences prefs;
  const HomePage({super.key, required this.prefs});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  late DateTime quitDate;
  late int perDay, packPrice, packSize;
  bool bn = true; int tab = 0, sos = 0; Timer? timer;
  String t(String a, String b) => bn ? a : b;
  @override void initState() {
    super.initState(); final p = widget.prefs;
    quitDate = DateTime.tryParse(p.getString('quitDate') ?? '') ?? DateTime.now();
    perDay = p.getInt('perDay') ?? 10; packPrice = p.getInt('packPrice') ?? 15; packSize = p.getInt('packSize') ?? 20;
  }
  int get days => DateTime.now().difference(DateTime(quitDate.year, quitDate.month, quitDate.day)).inDays.clamp(0, 99999);
  int get saved => (days * perDay / (packSize == 0 ? 20 : packSize) * packPrice).floor();
  int get avoided => days * perDay;
  Future<void> save() async { final p=widget.prefs; await p.setString('quitDate',quitDate.toIso8601String()); await p.setInt('perDay',perDay); await p.setInt('packPrice',packPrice); await p.setInt('packSize',packSize); }
  @override void dispose(){ timer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final pages=[dashboard(), challenge(), settings()];
    return Scaffold(appBar: AppBar(title: const Text('QUITLY',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:3)),
      actions:[TextButton(onPressed:()=>setState(()=>bn=!bn),child:Text(bn?'EN':'বাং',style:const TextStyle(color:mint)))]),
      body:SafeArea(child:pages[tab]),
      bottomNavigationBar:NavigationBar(backgroundColor:panel,indicatorColor:mint.withOpacity(.16),selectedIndex:tab,
        onDestinationSelected:(v)=>setState(()=>tab=v),destinations:[
          NavigationDestination(icon:const Icon(Icons.home_outlined),label:t('হোম','Home')),
          NavigationDestination(icon:const Icon(Icons.flag_outlined),label:t('চ্যালেঞ্জ','Challenge')),
          NavigationDestination(icon:const Icon(Icons.tune),label:t('সেটিংস','Settings'))]));
  }
  Widget dashboard()=>ListView(padding:const EdgeInsets.all(18),children:[
    Text(t('প্রতিটি দিনই একটি জয়।','Every smoke-free day is a win.'),style:const TextStyle(color:Colors.white70,fontSize:16)),
    const SizedBox(height:18),
    Container(padding:const EdgeInsets.all(24),decoration:BoxDecoration(
      gradient:const LinearGradient(colors:[Color(0xFF183A36),Color(0xFF172432)]),
      borderRadius:BorderRadius.circular(24),border:Border.all(color:mint.withOpacity(.25))),
      child:Column(children:[const Icon(Icons.spa,color:mint,size:34),const SizedBox(height:10),
        Text(t('সিগারেট ছাড়া','SMOKE FREE'),style:const TextStyle(color:mint,letterSpacing:2,fontWeight:FontWeight.bold)),
        Text('$days',style:const TextStyle(fontSize:68,fontWeight:FontWeight.w900)),
        Text(t('দিন','DAYS'),style:const TextStyle(color:Colors.white70,letterSpacing:3)),
        const SizedBox(height:14),Text(t('তুমি পারছো। চালিয়ে যাও!','You are doing it. Keep going!'))])),
    const SizedBox(height:14),Row(children:[
      Expanded(child:stat(Icons.savings_outlined,t('টাকা বেঁচেছে','MONEY SAVED'),'৳$saved')),
      const SizedBox(width:12),Expanded(child:stat(Icons.smoke_free,t('এড়ানো সিগারেট','CIGARETTES AVOIDED'),'$avoided'))]),
    const SizedBox(height:20),Text(t('CRAVING হলে','WHEN A CRAVING HITS'),style:const TextStyle(fontWeight:FontWeight.bold)),
    const SizedBox(height:10),card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(t('ধীরে শ্বাস নাও, পানি খাও, ইচ্ছেটা কেটে যেতে একটু সময় দাও।','Breathe slowly, drink water, and give the urge time to pass.'),style:const TextStyle(color:Colors.white70)),
      const SizedBox(height:12),SizedBox(width:double.infinity,child:FilledButton.icon(
        style:FilledButton.styleFrom(backgroundColor:mint,foregroundColor:bg,padding:const EdgeInsets.all(14)),
        onPressed:craving,icon:const Icon(Icons.favorite),label:Text(t('Craving SOS','CRAVING SOS'))))])),
    const SizedBox(height:12),Text(t('শুরু: ${quitDate.day}/${quitDate.month}/${quitDate.year}','Started: ${quitDate.day}/${quitDate.month}/${quitDate.year}'),style:const TextStyle(color:Colors.white38))
  ]);
  Widget challenge() => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      Text(t('৩০ দিনের চ্যালেঞ্জ', '30-DAY CHALLENGE'),
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(t('ছোট ছোট ধাপেই বড় পরিবর্তন।', 'Small steps create big change.'),
        style: const TextStyle(color: Colors.white60)),
      const SizedBox(height: 18),
      for (final d in [1, 3, 7, 14, 21, 30])
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: card(
            Row(children: [
              CircleAvatar(
                backgroundColor: days >= d ? mint : Colors.white12,
                child: Icon(days >= d ? Icons.check : Icons.flag,
                  color: days >= d ? bg : Colors.white70),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$d ${t('দিন', 'days')}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    days >= d ? t('সম্পন্ন হয়েছে', 'Completed')
                      : t('তোমার পরবর্তী লক্ষ্য', 'Your next milestone'),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              )),
              if (days >= d) const Icon(Icons.verified, color: mint),
            ]),
          ),
        ),
      const SizedBox(height: 10),
      card(Text(
        t('Slip হলে সব শেষ নয়। আবার শুরু করাই আসল.',
          'A slip is not failure. Starting again matters.'),
        style: const TextStyle(color: Colors.white70),
      )),
    ],
  );
  Widget settings()=>ListView(padding:const EdgeInsets.all(18),children:[
    Text(t('তোমার হিসাব','YOUR DETAILS'),style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
    const SizedBox(height:16),numberField(t('প্রতিদিন কয়টি সিগারেট খেতে?','Cigarettes per day'),perDay,(v)=>perDay=v),
    const SizedBox(height:12),numberField(t('এক প্যাকেটের দাম (৳)','Price per pack (৳)'),packPrice,(v)=>packPrice=v),
    const SizedBox(height:12),numberField(t('এক প্যাকেটে কয়টি?','Cigarettes per pack'),packSize,(v)=>packSize=v),
    const SizedBox(height:16),SizedBox(width:double.infinity,child:FilledButton(
      style:FilledButton.styleFrom(backgroundColor:mint,foregroundColor:bg,padding:const EdgeInsets.all(15)),
      onPressed:()async{await save();if(mounted){setState((){});ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t('সেভ হয়েছে','Saved'))));}},
      child:Text(t('সেভ করুন','SAVE CHANGES')))),
    const SizedBox(height:18),card(ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.restart_alt,color:Colors.orange),
      title:Text(t('Quit date রিসেট','Reset quit date')),subtitle:Text(t('নতুন করে শুরু করতে','Start again')),onTap:resetDate)),
    const SizedBox(height:14),Text(t('তথ্য শুধু এই ফোনেই সেভ থাকে।','Your data stays on this phone.'),style:const TextStyle(color:Colors.white38))]);
  Widget numberField(String label,int value,ValueChanged<int> changed){
    final c=TextEditingController(text:'$value');
    return TextField(controller:c,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:label),
      onChanged:(s){final n=int.tryParse(s);if(n!=null)changed(n);});
  }
  Widget stat(IconData icon,String label,String value)=>card(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Icon(icon,color:mint,size:25),const SizedBox(height:12),Text(value,style:const TextStyle(fontSize:25,fontWeight:FontWeight.bold)),
    const SizedBox(height:4),Text(label,style:const TextStyle(color:Colors.white54,fontSize:10,letterSpacing:1))]));
  Widget card(Widget child)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(18)),child:child);
  void craving(){
    timer?.cancel();setState(()=>sos=60);
    timer=Timer.periodic(const Duration(seconds:1),(x){if(sos<=1){x.cancel();setState(()=>sos=0);}else{setState(()=>sos--);}});
    showDialog(context:context,builder:(ctx)=>AlertDialog(backgroundColor:panel,
      title:Text(t('একটু থামো ❤️','Pause for a moment ❤️')),
      content:Column(mainAxisSize:MainAxisSize.min,children:[
        Text(t('ধীরে শ্বাস নাও। এক গ্লাস পানি খাও। ইচ্ছেটা কেটে যেতে সময় দাও।','Breathe slowly. Drink water. Let the urge pass.'),textAlign:TextAlign.center),
        const SizedBox(height:20),Text(sos>0?'$sos s':t('তুমি পেরেছো!','You made it!'),style:const TextStyle(fontSize:32,color:mint,fontWeight:FontWeight.bold))]),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:Text(t('বন্ধ','CLOSE')))]));
  }
  Future<void> resetDate()async{
    final d=await showDatePicker(context:context,initialDate:DateTime.now(),firstDate:DateTime(2020),lastDate:DateTime.now());
    if(d!=null){setState(()=>quitDate=d);await save();}
  }
}
