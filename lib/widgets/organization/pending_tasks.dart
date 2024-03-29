// ignore_for_file: use_build_context_synchronously

import 'package:comman/api/data_fetching/org_pending_task.dart';
import 'package:comman/provider/token_provider.dart';
import 'package:comman/utils/constants.dart';
import 'package:comman/widgets/organization/dismiss_org_task.dart';
import 'package:comman/widgets/snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PendingTasks extends ConsumerStatefulWidget {
  const PendingTasks({super.key, required this.id});
  final String id;

  @override
  ConsumerState<PendingTasks> createState() => _PendingTasksState();
}

class _PendingTasksState extends ConsumerState<PendingTasks> {
  var tasks;
  var content;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    content = const Center(child: CircularProgressIndicator());
    tasks = await getOrgPendingTasks(
      token: ref.read(tokenProvider.state).state!,
      id: widget.id,
    );

    if (tasks.toString() == '[]') {
      content = const Center(
        child: Text(
          "Dial 0320-0094995, \nGet your business promoted, \nyou'll see a list here!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 19),
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return GridView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: width > 850 ? 2 : 1,
        childAspectRatio: width > 850 ? 2 : 1.5,
        crossAxisSpacing: 0,
        mainAxisSpacing: 12,
      ),
      children: (tasks != null && tasks.isNotEmpty)
          ? [
              for (final task in tasks)
                PendingTask(
                  id: task['id'].toString(),
                  title: task['title'],
                  width: width,
                  date: task['date_due'],
                  details: task['details'],
                  status: task['completion_status'],
                  refresh: getData,
                ),
            ]
          : width > 800
              ? [content, content]
              : [content],
    );
  }
}

class PendingTask extends ConsumerWidget {
  const PendingTask({
    super.key,
    required this.id,
    required this.width,
    required this.title,
    required this.date,
    required this.details,
    required this.status,
    required this.refresh,
  });

  final double width;
  final String title;
  final String date;
  final String details;
  final bool status;
  final String id;
  final void Function() refresh;

  double getResponsiveFontSize(
      BuildContext context, double percentageOfScreenWidth) {
    return MediaQuery.of(context).size.width * percentageOfScreenWidth / 100;
  }

  String convertDate() {
    String inputDate = date;
    DateTime dateTime = DateTime.parse(inputDate);
    return DateFormat('yyyy-MMMM-dd').format(dateTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white12
          : Colors.white54,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              convertDate(),
              style: TextStyle(fontSize: width < 600 ? 14 : 20),
            ),
            Text(
              title,
              softWrap: false,
              style: TextStyle(fontSize: width < 600 ? 20 : 35),
            ),
            Text(
              "Detaisl: $details",
              style: TextStyle(fontSize: width < 600 ? 12 : 18),
            ),
            Text(
              'Completion Status: ${status ? 'Completed' : 'Pending'}',
              style: const TextStyle(fontSize: 18),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: status
                          ? const Color.fromARGB(150, 255, 235, 59)
                          : Colors.green[400],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        Dio dio = Dio();

                        try {
                          print('updating the organization task');
                          var response = await dio.patch(
                            'http://$ipAddress:8000/hrm/task/$id/',
                            options: getOpts(ref),
                            data: {
                              'completion_status': !status,
                            },
                          );
                          showSnackBar(context, 'Status updated!');
                          refresh();
                        } catch (error) {
                          showSnackBar(
                              context, 'Sorry, cant change the status.');
                          print(error);
                        }
                      },
                      child: Text(
                        status ? "Mark Pending" : "Mark Complete",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        await showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: DismissOrganizationTask(
                              taskId: id,
                            ),
                          ),
                        );

                        refresh();
                      },
                      child: const Text(
                        "Dismiss Task",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
