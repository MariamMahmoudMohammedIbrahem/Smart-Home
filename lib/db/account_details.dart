/*
import 'package:flutter/material.dart';
import 'package:mega/constants.dart';
import 'package:mega/db/edit_account.dart';

class AccountDetails extends StatefulWidget {
  const AccountDetails({super.key, required this.userName});

  final String userName;

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    initial = widget.userName.trim().isNotEmpty
        ? widget.userName.trim()[0].toUpperCase()
        : ''; // Get the first let
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .07),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40.0,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    widget.userName,
                    style: const TextStyle(fontSize: 28),
                    softWrap: true,
                  ),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text(
                  'Account Profile',
                ),
                trailing: const Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountEdit(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: const Text(
                  'Languages',
                ),
                trailing: const Icon(Icons.arrow_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text(
                  'Notifications',
                ),
                trailing: const Icon(Icons.arrow_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text(
                  'Help and Support',
                ),
                trailing: const Icon(Icons.arrow_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text(
                  'Feedback',
                ),
                trailing: const Icon(Icons.arrow_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout_outlined),
                title: const Text(
                  'LogOut',
                ),
                trailing: const Icon(Icons.arrow_right),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
      */
/*floatingActionButton: FloatingActionButton(
        onPressed: (){
          showModalBottomSheet(context: context, builder: (context)=>const AddTaskScreen());
        },
        child: const Icon(
            Icons.add),
      ),*//*

    );
  }
}
*/
/*class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: const Text('ewhjbwe',style: TextStyle(decoration: TextDecoration.none),),
    );
  }
}*/
