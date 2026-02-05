// import 'package:flutter/material.dart';

// class ResponsiveHome extends StatelessWidget {
//   const ResponsiveHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     bool isTablet = screenWidth > 600;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Babysitter Finder"),
//         centerTitle: true,
//       ),

//       body: Padding(
//         padding: EdgeInsets.all(isTablet ? 24 : 16),
//         child: Column(
//           children: [
//             // 🔹 Header Section
//             Text(
//               "Find Trusted Babysitters Near You",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: isTablet ? 28 : 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 20),

//             // 🔹 Main Content Section
//             Expanded(
//               child: GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: isTablet ? 2 : 1,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                   childAspectRatio: 3,
//                 ),
//                 itemCount: 4,
//                 itemBuilder: (context, index) {
//                   return Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.shade50,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         const CircleAvatar(
//                           radius: 30,
//                           child: Icon(Icons.person),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Babysitter ${index + 1}",
//                                 style: TextStyle(
//                                   fontSize: isTablet ? 20 : 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               const Text("⭐ 4.8 | Verified"),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // 🔹 Footer / Action Section
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: () {},
//                 child: const Text("Search Babysitters"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
