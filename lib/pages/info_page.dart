import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final facebook = Uri.parse("https://www.facebook.com/phm.cng");  
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Hi...
                      Container(
                        width: 85, // Set the desired width
                        height: 85, // Set the desired height
                        child: Lottie.network(
                            'https://lottie.host/ea08129b-ab38-4eab-97c7-9f31b9df0189/sb0B7V8CXb.json'),
                      ),
                      Text(
                        "Information",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                  Center(
                    child: Column(
                      children: [
                        Container(
                        width: 300, // Set the desired width
                        height: 300, // Set the desired height
                        child: Lottie.network(
                            'https://lottie.host/be34fe66-a233-42ac-9616-9e78426a7591/OY8bw4Se9l.json'),
                      ),
                      SizedBox(height: 50,),
                        Text(
                          "Developed by Pham Cuong",
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 30,),
                        Text(
                          "Contact",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20,),
                        Text(
                          "Email: bomwithme@gmail.com",
                          style: TextStyle(fontSize: 20, color: Colors.grey.shade600),
                        ),
                        SizedBox(height: 20,),
                        Text(
                          "Phone: 0866783837",
                          style: TextStyle(fontSize: 20, color: Colors.grey.shade600),
                        ),
                        // IconButton(
                        //   onPressed: () {
                        //     launchUrl(facebook);
                        //     },
                        //   icon: Icon(Icons.facebook,color: Colors.blue,),
                        // )
                      ],
                    ),
                  )
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
