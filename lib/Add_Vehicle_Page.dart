import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lpr_prototype/Vehicle_Detail_Page.dart';

class Add_Vehicle_Page extends StatefulWidget {
  final String vehicleID;

  Add_Vehicle_Page({Key key, @required this.vehicleID}) : super(key: key);

  @override
  _Add_Vehicle_PageState createState() => _Add_Vehicle_PageState(vehicleID);
}

class _Add_Vehicle_PageState extends State<Add_Vehicle_Page> {
  String vehicleID;
  String instructionMessage = "Type in the vehicle\'s detail";
  var _cModel = TextEditingController();
  var _cColor = TextEditingController();
  var _cPlate = TextEditingController();
  var _cOwner = TextEditingController();
  var _cContact = TextEditingController();
  _Add_Vehicle_PageState(this.vehicleID);


  void addVehicle(vehicles) {
    setState(() {
      instructionMessage = "Adding the vehicle";
    });
    vehicles
        .doc(vehicleID)
        .set({
          'model': _cModel.text,
          'color': _cColor.text,
          'plate': _cPlate.text,
          'owner': _cOwner.text,
          'contact': _cContact.text,
          'entry': '-',
          'paid': 'No',
          'troubleCaused': '0',
        })
        .then((value) => setState(() {
              instructionMessage = "Vehicle Added";
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      Vehicle_Detail_Page(vehicleID: vehicleID)));
            }))
        .catchError((error) => setState(() {
              instructionMessage = "Vehicle Not Added: ${error}";
            }));
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference vehicles =
        FirebaseFirestore.instance.collection('vehicles');
    _cPlate.text = vehicleID;
    return FutureBuilder<DocumentSnapshot>(
        future: vehicles.doc(vehicleID).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if(snapshot.hasError){
            return MaterialApp(
              home: Scaffold(
                body: Text("Something went wrong"),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data.data();
            if (data == null) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: ListView(
                      children: [
                        Text("Vehicle Model"),
                        TextField(
                          controller: _cModel,
                        ),
                        Text("Vehicle Color"),
                        TextField(
                          controller: _cColor,
                        ),
                        Text("Plate Number:"),
                        TextField(
                          readOnly: true,
                          controller: _cPlate,
                        ),
                        Text("Vehicle owner"),
                        TextField(
                          controller: _cOwner,
                        ),
                        Text('Owner Contact Number'),
                        TextField(
                          controller: _cContact,
                        ),
                        TextButton(
                            onPressed: () {
                              addVehicle(vehicles);
                            },
                            child: Text('Add the vehicles')),
                        Text(instructionMessage),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return MaterialApp(
                home: Scaffold(
                  body: Container(
                    child: Center(child:Text('Vehicle ${vehicleID} exists'),)
                  ),
                ),
              );
            }
          }
          return MaterialApp(
            home: Scaffold(
              body: Container(
                child: Text('Loading'),
              ),
            ),
          );
        });
  }
}
