import 'package:flutter/material.dart';
import 'Vehicle_Detail_Page.dart';

class Type_In_Plate_Page extends StatefulWidget {
  final String vehicleID;

  Type_In_Plate_Page ({Key key, @required this.vehicleID}) : super(key: key);
  @override
  _Type_In_Plate_PageState createState() => _Type_In_Plate_PageState(vehicleID);
}

class _Type_In_Plate_PageState extends State<Type_In_Plate_Page> {
  String vehicleID;
  TextEditingController _controller = TextEditingController();

  _Type_In_Plate_PageState(this.vehicleID);

  @override
  Widget build(BuildContext context) {
    _controller.text=vehicleID;
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 50, 0, 50),
            child: Column(
              children: [
                TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Type in the Plate Number",
                    labelText: "Plate Number"
                  ),
                ),
                TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context)=>
                      Vehicle_Detail_Page(vehicleID: _controller.text)));
                    },
                    child: Text("Check")
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
