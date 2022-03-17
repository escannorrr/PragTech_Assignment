import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int likeCount=0;
  List userList=[];
  List userLikedList=[];
  List likesList=[];
  bool isLikedFlag=false;
  final storage=FlutterSecureStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  getUserData()async{
    final String response=await rootBundle.loadString("assets/userJson.json");
    userList=json.decode(response);
    String? value;
    String? value1;
    // await storage.delete(key: "LIKED_USER_LIST");
    value = await storage.read(key: "LIKED_USER_LIST")??"";
    value1 = await storage.read(key: "LIKED_LIST")??"";
    if(value1==null||value1==""){
      likesList=[];
    }else{
      likesList=json.decode(value1!);
    }
    setState(() {
      likesList=likesList;
    });
    if(value==null||value==""){

      for(int i= 0;i<userList.length;i++){
        userLikedList.add("N");
      }

    }else{

      userLikedList=json.decode(value!);
      setState(() {
        userLikedList=userLikedList;
      });

      for(int i=0;i<userLikedList.length;i++){
        if(userLikedList[i]=="Y"){
          likeCount++;
        }
      }

      setState(() {
        likeCount=likeCount;
      });
    }
    setState(() {
      userList=userList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "User List",
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
        actions: [
          Center(
            child: Text(
              "${likesList.length}",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          SizedBox(
            width: 20.0,
          )
        ],
      ),
      body: Container(
        child:userList.length>0? ListView.builder(
          itemCount: userList.length,
          itemBuilder: (ctx,index){
            return ListTile(
              title: Text(
                "${userList[index]['username']}",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold
                ),
              ),
              subtitle:  Text(
                "${userList[0]['email']}",
                style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[400],
                ),
              ),
              trailing: InkWell(
                onTap: ()async{
                  setState(() {
                    if(likesList.contains(userList[index]['username'])){
                      likesList.remove(userList[index]['username']);
                    }else{
                      likesList.add(userList[index]['username']);
                    }
                    if(userLikedList[index]=="Y"){
                      userLikedList.removeAt(index);
                      userLikedList.insert(index, "N");


                    }else{

                      userLikedList.removeAt(index);
                      userLikedList.insert(index, "Y");

                    }
                  });
                  await storage.write(key: "LIKED_USER_LIST", value: json.encode(userLikedList));
                  await storage.write(key: "LIKED_LIST", value: json.encode(likesList));
                  for(int i=0;i<userLikedList.length;i++){
                    if(userLikedList[i]=="Y"){
                      likeCount++;
                    }
                  }
                  setState(() {
                    likeCount=likeCount;
                    likesList=likesList;
                  });
                },
                child: Container(
                  width: 40.0,
                  child: userLikedList[index]=="Y"?Image.asset("assets/liked.png"):Image.asset("assets/like.png"),
                ),
              ),
            );
          },
        ):CircularProgressIndicator(),
      ),
    );
  }
}
