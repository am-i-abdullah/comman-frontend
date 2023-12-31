import 'package:comman/pages/subpages/crm.dart';
import 'package:comman/pages/subpages/hrm.dart';
import 'package:comman/pages/subpages/notifications.dart';

import 'package:comman/widgets/organization/org_dashboard.dart';
import 'package:comman/widgets/sidebar.dart';
import 'package:flutter/material.dart';

class Organization extends StatefulWidget {
  const Organization({
    super.key,
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  State<Organization> createState() => _OrganizationState();
}

class _OrganizationState extends State<Organization> {
  var content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideBar(storage: null),
      appBar: AppBar(
        // page tiltle
        centerTitle: true,
        title: InkWell(
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            setState(
              () {
                content = OrganizationDashboard(id: widget.id);
              },
            );
          },
          child: Text(
            widget.name,
            style: const TextStyle(fontSize: 30),
          ),
        ),

        // remaining navigation buttons
        actions: [
          // Home/ dashboard button
          IconButton(
            onPressed: () {
              setState(() {
                Navigator.pop(context);
              });
            },
            icon: const Icon(Icons.home),
          ),

          // HRM
          IconButton(
            onPressed: () {
              setState(() {
                content = const HRM();
              });
            },
            icon: const Icon(Icons.group),
          ),

          // CRM buttom
          IconButton(
            onPressed: () {
              setState(() {
                content = CRM(
                  organizationId: widget.id,
                );
              });
            },
            icon: const Icon(Icons.widgets),
          ),

          // Notifications button
          IconButton(
            onPressed: () {
              setState(() {
                content = const Notifications();
              });
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: content ?? OrganizationDashboard(id: widget.id),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.background
          : Colors.white54,
    );
  }
}
