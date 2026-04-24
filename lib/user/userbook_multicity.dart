import 'package:flutter/material.dart';
import 'package:ticketing_flutter/user/userbook_oneway.dart';
import 'package:ticketing_flutter/user/userbook_roundtrip.dart';
import 'package:ticketing_flutter/auth/login.dart';
import 'package:ticketing_flutter/public/home.dart';
import 'package:ticketing_flutter/user/account_details.dart';

const List<String> countries = [
  "Philippines - Manila",
  "Japan - Tokyo",
  "USA - New York",
];

class UserBookMulticity extends StatefulWidget {
  const UserBookMulticity({super.key});

  @override
  State<UserBookMulticity> createState() => _UserBookMulticityState();
}

class _UserBookMulticityState extends State<UserBookMulticity> {
  int _adults = 1;
  int _children = 0;
  int _infants = 0;
  String _selectedClass = "Economy";

  final TextEditingController box7Controller = TextEditingController();
  final TextEditingController box8Controller = TextEditingController();

  bool _isSearchPressed = false;

  /// Multi-city list of routes
  List<FlightRoute> routes = [FlightRoute()];

  @override
  void initState() {
    super.initState();
    box7Controller.text = "${_adults + _children + _infants} Passengers";
    box8Controller.text = _selectedClass;
  }

  void _addRoute() {
    setState(() {
      routes.add(FlightRoute());
    });
  }

  void _removeRoute(int index) {
    setState(() {
      if (routes.length > 1) {
        routes.removeAt(index);
      }
    });
  }

  void _navigateToPage(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showPassengerSelector() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildPassengerRow("Adults", _adults, (val) {
                    setStateModal(() => _adults += val);
                  }, min: 1),
                  const Divider(),
                  _buildPassengerRow("Children", _children, (val) {
                    setStateModal(() => _children += val);
                  }),
                  const Divider(),
                  _buildPassengerRow("Infants", _infants, (val) {
                    setStateModal(() => _infants += val);
                  }),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 35,
                    ), // move it higher
                    child: ElevatedButton(
                      onPressed: () {
                        final total = _adults + _children + _infants;
                        box7Controller.text = "$total Passengers";
                        Navigator.pop(context);
                      },
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showClassSelector() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildClassOption("Economy"),
              _buildClassOption("Business"),
              _buildClassOption("First Class"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPassengerRow(
    String type,
    int count,
    Function(int) onUpdate, {
    int min = 0,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(type, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: count > min ? () => onUpdate(-1) : null,
            ),
            Text(count.toString(), style: const TextStyle(fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onUpdate(1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassOption(String className) {
    return ListTile(
      title: Text(className),
      onTap: () {
        setState(() {
          _selectedClass = className;
          box8Controller.text = _selectedClass;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        width: 300.0,
        backgroundColor: const Color(0xFF111827),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF000000),
                      Color(0xFF111827),
                      Color(0xFF1E3A8A),
                    ],
                  ),
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.flight, color: Colors.white),
              title: const Text('Book', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts, color: Colors.white),
              title: const Text(
                'Manage',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text(
                'Travel Info',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.explore, color: Colors.white),
              title: const Text(
                'Explore',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('About', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle, color: Colors.white),
              title: const Text(
                'My Account',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const MyAccountDetailsPage(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final boxHeight = 600.0;
          final boxWidth = 330.0;
          final boxTop = (screenHeight / 2) - (boxHeight / 2);
          final screenWidth = MediaQuery.of(context).size.width;
          final boxLeft = (screenWidth - boxWidth) / 2;

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF000000),
                            Color(0xFF111827),
                            Color(0xFF1E3A8A),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.blue.shade100,
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 30,
                left: 10,
                child: Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                ),
              ),
              // Prompt text just above the booking box
              Positioned(
                top: boxTop - 45, // 45 pixels above the box
                left: boxLeft,
                child: SizedBox(
                  width: boxWidth,
                  child: Center(
                    child: Text(
                      'Where do you want to fly?',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 129, 150, 207),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: boxTop,
                left: boxLeft,
                child: Container(
                  width: boxWidth,
                  height: boxHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  _navigateToPage(const UserBookOneway()),
                              child: buildClickableBox("One-way"),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  _navigateToPage(const UserBookRoundtrip()),
                              child: buildClickableBox("Roundtrip"),
                            ),
                            buildClickableBox("Multi-city", isSelected: true),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: routes.length,
                            itemBuilder: (context, index) {
                              return FlightRouteCard(
                                route: routes[index],
                                onRemove: () => _removeRoute(index),
                              );
                            },
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addRoute,
                          icon: const Icon(Icons.add),
                          label: const Text("Add Another City"),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildInputBox(
                              "Passengers",
                              box7Controller,
                              width: 140,
                              readOnly: true,
                            ),
                            buildInputBox(
                              "Class",
                              box8Controller,
                              width: 140,
                              readOnly: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTapDown: (_) {
                            setState(() => _isSearchPressed = true);
                          },
                          onTapUp: (_) {
                            setState(() => _isSearchPressed = false);
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const Home(),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                transitionDuration: const Duration(
                                  milliseconds: 300,
                                ),
                              ),
                            );
                          },
                          onTapCancel: () {
                            setState(() => _isSearchPressed = false);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity, // w-full
                            height: 56,
                            decoration: BoxDecoration(
                              color: _isSearchPressed
                                  ? const Color.fromARGB(
                                      255,
                                      53,
                                      56,
                                      58,
                                    ) // Slightly darker when pressed
                                  : const Color.fromARGB(255, 5, 23, 37),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Search Flights',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 49, // adjust as you like
                left: 0,
                right: 0,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.copyright,
                        size: 20,
                        color: Color.fromARGB(179, 7, 7, 7),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '2025 Airlines Ticketing. All Rights Reserved',
                        style: TextStyle(
                          color: Color.fromARGB(179, 26, 25, 25),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildAutocompleteField(String hint, TextEditingController controller) {
    return Container(
      width: 300,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          return countries.where(
            (country) => country.toLowerCase().contains(
              textEditingValue.text.toLowerCase(),
            ),
          );
        },
        onSelected: (String selection) {
          controller.text = selection;
        },
        fieldViewBuilder:
            (context, textController, focusNode, onFieldSubmitted) {
              return TextField(
                controller: textController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                ),
              );
            },
      ),
    );
  }

  Widget buildClickableBox(String label, {bool isSelected = false}) {
    if (isSelected) {
      // Black box with white text for "One-way"
      return Container(
        width: 93,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      // White box with black text and subtle shadow for Roundtrip and Multi-City
      return Container(
        width: 93,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  Widget buildInputBox(
    String hint,
    TextEditingController controller, {
    double width = 300,
    bool readOnly = false,
  }) {
    if (readOnly) {
      return GestureDetector(
        onTap: () {
          if (hint == "Passengers") {
            _showPassengerSelector();
          } else if (hint == "Class") {
            _showClassSelector();
          }
        },
        child: Container(
          width: width,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            controller.text.isEmpty ? hint : controller.text,
            style: TextStyle(
              color: controller.text.isEmpty
                  ? Colors.grey.shade600
                  : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    return Container(
      width: width,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }
}

class FlightRoute {
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  int selectedPrice = 10000;
}

class FlightRouteCard extends StatelessWidget {
  final FlightRoute route;
  final VoidCallback onRemove;

  const FlightRouteCard({
    super.key,
    required this.route,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildAutocompleteField("From", route.fromController),
        const SizedBox(height: 12),
        buildAutocompleteField("To", route.toController),
        const SizedBox(height: 12),
        buildDatePickerField(
          "Departure",
          route.dateController,
          context,
          onPriceUpdate: (price) {
            route.selectedPrice = price;
          },
        ),
        if (route.dateController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 8),
            child: Text(
              'Price: ₱${route.selectedPrice}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onRemove,
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text("Remove"),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget buildAutocompleteField(String hint, TextEditingController controller) {
    return Container(
      width: 300,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          return countries.where(
            (country) => country.toLowerCase().contains(
              textEditingValue.text.toLowerCase(),
            ),
          );
        },
        onSelected: (String selection) {
          controller.text = selection;
        },
        fieldViewBuilder:
            (context, textController, focusNode, onFieldSubmitted) {
              return TextField(
                controller: textController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                ),
              );
            },
      ),
    );
  }

  Widget buildDatePickerField(
    String hint,
    TextEditingController controller,
    BuildContext context, {
    Function(int)? onPriceUpdate,
  }) {
    return GestureDetector(
      onTap: () async {
        DateTime today = DateTime.now();
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: today,
          firstDate: today,
          lastDate: DateTime(today.year + 2),
        );

        if (pickedDate != null) {
          String formattedDate =
              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
          controller.text = formattedDate;
          int daysDiff = pickedDate.difference(today).inDays;
          int price = 10000 - (daysDiff * 100);
          if (price < 5000) price = 5000;
          if (onPriceUpdate != null) onPriceUpdate(price);
        }
      },
      child: Container(
        width: 300,
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          controller.text.isEmpty ? hint : controller.text,
          style: TextStyle(
            color: controller.text.isEmpty
                ? Colors.grey.shade600
                : Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class Page9 extends StatelessWidget {
  const Page9({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page 9")),
      body: const Center(child: Text("Welcome to Page 9")),
    );
  }
}
