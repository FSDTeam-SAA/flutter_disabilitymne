import 'dart:math';
import 'package:flutter/material.dart';

class WeightInputScreen extends StatefulWidget {
  const WeightInputScreen({super.key});

  @override
  State<WeightInputScreen> createState() => _WeightInputScreenState();
}

class _WeightInputScreenState extends State<WeightInputScreen> {
  int weight = 72;
  bool isKg = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(
        weight * 60 - (MediaQuery.of(context).size.width / 2 - 30),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Step 3 of 8"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "How Much Do You Weigh?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),

            // KG / LBS Toggle
            Container(
              width: 140,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!isKg) {
                        setState(() {
                          weight = (weight / 2.20462).round();
                          isKg = true;
                        });
                      }
                    },
                    child: Text(
                      "kg",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isKg ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isKg) {
                        setState(() {
                          weight = (weight * 2.20462).round();
                          isKg = false;
                        });
                      }
                    },
                    child: Text(
                      "lbs",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: !isKg ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Weight Picker
            SizedBox(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    "assets/logo/age.png",
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    "$weight ${isKg ? "kg" : "lbs"}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Positioned(
  top: 0,
  left: 0,
  right: 0,
  child: SizedBox(
    height: 160,
    child: NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          int newWeight = (_scrollController.offset / 60).round();
          if (newWeight >= 0 && newWeight <= 100) {
            setState(() {
              weight = newWeight;
            });
          }
        }
        return true;
      },
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 101,
        itemBuilder: (context, index) {
          bool isSelected = index == weight;

          // Calculate vertical offset using sine for overlay/curve effect
          double center = weight.toDouble();
          double offsetY = 50 * sin((index - center) * pi / 50);

          return GestureDetector(
            onTap: () {
              setState(() => weight = index);
              _scrollController.animateTo(
                index * 60 - (screenWidth / 2 - 30),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: offsetY + 50), // moves up/down
              child: Text(
                index.toString(),
                style: TextStyle(
                  fontSize: isSelected ? 32 : 20,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.white70,
                ),
              ),
            ),
          );
        },
      ),
    ),
  ),
)
                ],
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
