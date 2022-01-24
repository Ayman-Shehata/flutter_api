import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'data_model.dart';

class DataView extends StatefulWidget {
  @override
  _DataViewState createState() => _DataViewState();
}

class _DataViewState extends State<DataView> {
  late Future<List<Data>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "data",
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            //بيانات كود الاستجابة
            FutureBuilder<DataModel>(
              future: getHeadData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: <Widget>[
                      Card(
                        elevation: 12,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                  leading: Image(
                                    image: NetworkImage(
                                        'http://serv.emcanhouse.com/edit.png'),
                                  ),
                                  title:
                                      Text(snapshot.data!.message.toString()),
                                  subtitle: Text(
                                      snapshot.data!.responseCode.toString())),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                return CircularProgressIndicator(
                  strokeWidth: 10,
                );
              },
            ),
            //بيانات الليست
            Expanded(
              child: FutureBuilder<List<Data>>(
                future: futureData,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Data>? data2 = snapshot.data;
                    return ListView.builder(
                        itemCount: data2!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: 3,
                            child: Column(
                              children: [
                                Text("Trans. #  : " + (index + 1).toString(),
                                    style: TextStyle(fontSize: 24)),
                                ListTile(
                                  title: Text(
                                    data2[index].name.toString(),
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  leading: Image(
                                    image: NetworkImage(
                                        'http://serv.emcanhouse.com/' +
                                            data2[index].image.toString()),
                                  ),
                                  subtitle:
                                      Text(data2[index].nameAr.toString()),
                                  trailing: Text(
                                    "Code: " + data2[index].id.toString(),
                                    style: TextStyle(
                                        color: Colors.green, fontSize: 24),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<DataModel> getHeadData() async {
  final response =
      await http.get(Uri.parse("http://serv.emcanhouse.com/data.json"));
  if (response.statusCode == 200) {
    final jsonresponse = json.decode(response.body);
    return DataModel.fromJson(jsonresponse);
  } else {
    throw Exception('Error');
  }
}

Future<List<Data>> fetchData() async {
  final response =
      await http.get(Uri.parse('http://serv.emcanhouse.com/data.json'));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body)['data'];
    return jsonResponse.map((data) => Data.fromJson(data)).toList();
  } else {
    throw Exception('Unexpected error occured!');
  }
}
