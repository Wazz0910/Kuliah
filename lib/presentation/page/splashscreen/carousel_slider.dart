import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:tes/presentation/page/auth/login_page.dart';
import 'package:tes/presentation/page/splashscreen/theme.dart';
import 'dart:ui';

final List<String> imgList = [
  'asset/gambar1.png',
  'asset/gambar2.png',
  'asset/gambar3.png',
  'asset/gambar4.png',
];

final themeMode = ValueNotifier(2);

class FullscreenSliderDemo extends StatefulWidget {
  @override
  _FullscreenSliderDemoState createState() => _FullscreenSliderDemoState();
}

class _FullscreenSliderDemoState extends State<FullscreenSliderDemo> {
  final CarouselController _controller = CarouselController();
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Carousel
          CarouselSlider.builder(
            carouselController: _controller,
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              autoPlay: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
            itemCount: imgList.length,
            itemBuilder: (context, index, realIndex) {
              final image = imgList[index];
              return Image.asset(
                image,
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height,
              );
            },
          ),

          // Position the button and pointers at the bottom center
          Positioned(
            bottom: 20.0, // Adjust spacing as needed
            left: 0.0,
            right: 0.0,
            child: Column(
              // Use Column to stack pointers and button vertically
              mainAxisSize: MainAxisSize.min, // Minimize the size of the column
              children: [
                // Row for pointers (adjust spacing and number of pointers as needed)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < imgList.length; i++)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 5.0),
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _current == i
                                ? bluecolor
                                : Colors
                                    .grey, // Change color based on current index
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(
                    height: 10.0), // Add spacing between pointers and button
                Center(
                  child: Container(
                    width: 280.0, // Adjust the width as needed
                    height: 60.0, // Adjust the height as needed
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                        print('Get Started button pressed!');
                        // Replace with your desired action
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            bluecolor), // Change the button background color
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8.0), // Adjust the border radius as needed
                          ),
                        ),
                      ),
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                            color: Colors.white), // Change the text color
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
