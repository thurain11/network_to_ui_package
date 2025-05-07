// import 'package:flutter/material.dart';
//
// import '../network_to_ui.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Factory တွေ register လုပ်ပါ
//   FactoryManager.setupFactories();
//
//   // Initialize storage
//   final StorageInterface storage = HiveStorage();
//
//   // Initialize DioBaseNetworkConfig singleton
//   DioBaseNetworkConfig().updateConfig(
//     nowVersionIos: "1.0.0",
//     nowVersionAndroid: "1.0.0",
//     authorizationToken: await storage.getString("token"),
//     shopCity: await storage.getString("shop_city"),
//     language: await storage.getString("language"),
//   );
//
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: HomePage(),
//     );
//   }
// }
//
// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Home")),
//       body: Column(
//         children: [
//           // Home Slider
//           Expanded(
//             child: NetWorkToUiBuilder<HomeSlideOb>(
//               url: "home_slider",
//               requestType: ReqType.get,
//               widget: (ob, load) {
//                 HomeSlideOb hOb = ob;
//                 return ListView.builder(
//                   itemCount: hOb.data?.length ?? 0,
//                   itemBuilder: (context, index) {
//                     final slide = hOb.data![index];
//                     return ListTile(
//                       title: Text(slide.title ?? "No Title"),
//                       subtitle: Text(slide.description ?? "No Description"),
//                     );
//                   },
//                 );
//               },
//               customLoadingWidget: Center(child: CircularProgressIndicator()),
//             ),
//           ),
//           // Profile
//           Expanded(
//             child: NetWorkToUiBuilder<ProfileOb>(
//               url: "profile",
//               requestType: ReqType.get,
//               widget: (ob, load) {
//                 ProfileOb pOb = ob;
//                 return ListTile(
//                   title: Text(pOb.name ?? "No Name"),
//                   subtitle: Text(pOb.email ?? "No Email"),
//                 );
//               },
//               customLoadingWidget: Center(child: CircularProgressIndicator()),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // FactoryManager
// class FactoryManager {
//   static void setupFactories() {
//     ObjectFactory.registerFactory<HomeSlideOb>(
//         (json) => HomeSlideOb.fromJson(json));
//     ObjectFactory.registerFactory<ProfileOb>(
//         (json) => ProfileOb.fromJson(json));
//   }
// }
//
// // HomeSlideOb and HomeSlideData classes
// class HomeSlideOb {
//   List<HomeSlideData>? data;
//   int? result;
//   String? message;
//
//   HomeSlideOb({this.data, this.result, this.message});
//
//   HomeSlideOb.fromJson(Map<String, dynamic> json) {
//     if (json['data'] != null) {
//       data = <HomeSlideData>[];
//       json['data'].forEach((v) {
//         data!.add(HomeSlideData.fromJson(v));
//       });
//     }
//     result = json['result'];
//     message = json['message'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     data['result'] = this.result;
//     data['message'] = this.message;
//     return data;
//   }
// }
//
// class HomeSlideData {
//   String? id;
//   String? type;
//   String? title;
//   String? description;
//   String? image;
//
//   HomeSlideData({this.title, this.description, this.image, this.id, this.type});
//
//   HomeSlideData.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     type = json['type'];
//     title = json['title'];
//     description = json['description'];
//     image = json['image'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['title'] = this.title;
//     data['description'] = this.description;
//     data['image'] = this.image;
//     return data;
//   }
// }
//
// // ProfileOb class
// class ProfileOb {
//   String? name;
//   String? email;
//
//   ProfileOb({this.name, this.email});
//
//   ProfileOb.fromJson(Map<String, dynamic> json) {
//     name = json['name'];
//     email = json['email'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['name'] = this.name;
//     data['email'] = this.email;
//     return data;
//   }
// }
