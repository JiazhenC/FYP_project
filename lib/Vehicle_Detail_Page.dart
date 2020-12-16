import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Add_Vehicle_Page.dart';
import 'Edit_Vehicle_Page.dart';
import 'package:flutter_phone_state/flutter_phone_state.dart';

class Vehicle_Detail_Page extends StatefulWidget {
  final String vehicleID;

  Vehicle_Detail_Page({Key key, @required this.vehicleID}) : super(key: key);

  @override
  _Vehicle_Detail_PageState createState() =>
      _Vehicle_Detail_PageState(vehicleID);
}

class _Vehicle_Detail_PageState extends State<Vehicle_Detail_Page> {
  String vehicleID;
  _Vehicle_Detail_PageState(this.vehicleID);

  Future<void> _showMyDialog(parkFee) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cannot exit'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Owner of vehicle ${vehicleID} has not pay the parking fee\n'),
                Text('Pay the fee of RM${parkFee}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Exit'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMyDialog2(vehicles) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(vehicleID),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Do you want to delete the details of vehicle ${vehicleID} ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                vehicles.doc(vehicleID).delete();
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void callPhone(phone){
    setState(() {
    FlutterPhoneState.startPhoneCall(phone);
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference vehicles =
        FirebaseFirestore.instance.collection('vehicles');

    return FutureBuilder<DocumentSnapshot>(
      future: vehicles.doc(vehicleID).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Text("Something went wrong"),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data.data();
          if (data != null) {
            var parkFee;
            if (data['entry'] != "-") {
              var checkTime = DateTime.now();
              var parkTime =
                  checkTime.difference(DateTime.parse(data['entry'])).inHours;
              if (parkTime <= 3) {
                parkFee = 2;
              } else {
                parkFee = 2;
                parkFee += parkTime;
              }
            } else {
              parkFee = 0;
            }

            return MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: Text("${data['plate']}"),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                Edit_Vehicle_Page(vehicleID: vehicleID)));
                      },
                    ),
                    IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _showMyDialog2(vehicles);
                        }),
                  ],
                ),
                body: Center(
                  child: ListView(
                    children: [
                      Text("Vehicle Model: ${data['model']}"),
                      Text("Vehicle Color: ${data['color']}"),
                      Text("Vehicle Owner: ${data['owner']}"),
                      Row(
                        children: [
                          Text("Owner Contact Number: ${data['contact']}"),
                          IconButton(
                              icon: Icon(Icons.phone),
                              onPressed: (){callPhone(data['contact']);},
                          ),
                        ],
                      ),
                      Text("Vehicle Entry Time: ${data['entry']}"),
                      Row(
                        children: [
                          TextButton(
                              onPressed: () {
                                vehicles.doc(vehicleID).update({
                                  'entry':
                                      DateTime.now().toString().substring(0, 19)
                                });
                                setState(() {});
                              },
                              child: Text('Vehicle Enter')),
                          TextButton(
                              onPressed: () {
                                if (data['paid'] == 'yes') {
                                  vehicles
                                      .doc(vehicleID)
                                      .update({'entry': '-'});
                                  setState(() {});
                                } else {
                                  _showMyDialog(parkFee);
                                }
                              },
                              child: Text('Vehicle Exit')),
                        ],
                      ),
                      Text("Parking Fee: RM ${parkFee}"),
                      Text("Paid: ${data['paid']}"),
                      TextButton(onPressed: null, child: Text('Pay')),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return MaterialApp(
              home: Scaffold(
                  body: Center(
                child: Column(
                  children: [
                    Text('Vehicle\'s Plate Number Not Found'),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  Add_Vehicle_Page(vehicleID: vehicleID)));
                        },
                        child: Text('Add Vehicle'))
                  ],
                ),
              )),
            );
          }
        }

        return MaterialApp(
          home: Scaffold(
            body: Text("Loading"),
          ),
        );
      },
    );
  }
}
