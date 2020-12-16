import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Edit_Vehicle_Page extends StatefulWidget {
  final String vehicleID;

  Edit_Vehicle_Page({Key key, @required this.vehicleID}) : super(key: key);

  @override
  _Edit_Vehicle_PageState createState() => _Edit_Vehicle_PageState(vehicleID);
}

class _Edit_Vehicle_PageState extends State<Edit_Vehicle_Page> {
  String vehicleID;

  String instructionMessage = "Edit the vehicle\'s detail";
  var _cModel = TextEditingController();
  var _cColor = TextEditingController();
  var _cPlate = TextEditingController();
  var _cOwner = TextEditingController();
  var _cContact = TextEditingController();
  var _cEntry = TextEditingController();

  _Edit_Vehicle_PageState(this.vehicleID);

  void editVehicles(vehicles) {
    setState(() {
      instructionMessage = "Editing the vehicle";
    });
    vehicles
        .doc(vehicleID)
        .update({
          'model': _cModel.text,
          'color': _cColor.text,
          'plate': _cPlate.text,
          'owner': _cOwner.text,
          'contact': _cContact.text,
        })
        .then((value) => setState(() {
              instructionMessage = "Vehicle Edited";
            }))
        .catchError((error) => setState(() {
              instructionMessage = "Vehicle Not Edited: ${error}";
            }));
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference vehicles =
        FirebaseFirestore.instance.collection('vehicles');
    return FutureBuilder<DocumentSnapshot>(
        future: vehicles.doc(vehicleID).get(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot> snapshot) {
          if(snapshot.hasError){
            return MaterialApp(
              home: Scaffold(
                body: Container(
                  child: Text('Error'),
                ),
              ),
            );
          }
          if(snapshot.connectionState==ConnectionState.done){
            Map<String, dynamic> data = snapshot.data.data();
            _cModel.text="${data['model']}";
            _cColor.text="${data['color']}";
            _cPlate.text="${data['plate']}";
            _cOwner.text="${data['owner']}";
            _cContact.text="${data['contact']}";
            return
              MaterialApp(
                home: Scaffold(
                  appBar: AppBar(
                    title: Text('Edit ${vehicleID}'),
                  ),
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
                            onPressed: (){editVehicles(vehicles);},
                            child: Text('Edit the vehicles')
                        ),
                        Text(instructionMessage),
                      ],
                    ),
                  ),
                ),
              );
          }

            return MaterialApp(
              home: Scaffold(
                body: Container(
                  child: Text('Loading vehicle\'s detail')
                ),
              ),
            );
        });
  }
}
