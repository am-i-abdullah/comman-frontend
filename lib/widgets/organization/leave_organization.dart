// ignore_for_file: use_build_context_synchronously

import 'package:comman/api/auth/user_auth.dart';
import 'package:comman/provider/token_provider.dart';
import 'package:comman/provider/user_provider.dart';
import 'package:comman/utils/constants.dart';
import 'package:comman/widgets/snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaveOrganization extends ConsumerStatefulWidget {
  const LeaveOrganization({
    super.key,
    required this.organizationId,
    required this.organizationName,
  });
  final String organizationId;
  final String organizationName;

  @override
  ConsumerState<LeaveOrganization> createState() => _LeaveOrganizationState();
}

class _LeaveOrganizationState extends ConsumerState<LeaveOrganization> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isPasswordVisible = true;
  String password = '';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
      height: 150,
      width: 300,
      child: Column(
        children: [
          Text(
            'Enter Password to Leave ${widget.organizationName}?',
            style: const TextStyle(fontSize: 16.5),
          ),
          Form(
            key: formKey,
            child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Password can't be empty!";
                }
                return null;
              },
              onSaved: (value) {
                password = value!;
              },
              decoration: InputDecoration(
                hintText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: isPasswordVisible,
            ),
          ),
          const Expanded(child: SizedBox()),
          if (!isLoading)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: width < 500 ? 110 : 120,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      bool isValid = formKey.currentState!.validate();
                      formKey.currentState!.save();

                      if (isValid) {
                        setState(() {
                          isLoading = true;
                        });

                        Dio dio = Dio();

                        try {
                          var result = await userAuth(
                              username: ref.read(userProvider).username,
                              password: password);

                          if (result.isEmpty) {
                            showSnackBar(context, 'Wrong Passowrd');
                            setState(() {
                              isLoading = false;
                            });
                            return;
                          }

                          // getting employee id
                          var response = await dio.get(
                            'http://$ipAddress:8000/hrm/organization/${widget.organizationId}/employees/me/',
                            options: getOpts(ref),
                          );

                          // deleting employee from org
                          response = await dio.delete(
                            'http://$ipAddress:8000/hrm/employee/${response.data['id']}/',
                            options: getOpts(ref),
                          );
                          showSnackBar(
                              context, 'Good Luck for your future Endeavours');
                          Navigator.pop(context);
                          return;
                        } catch (error) {
                          showSnackBar(context, 'Sorry, something went wrong');
                          print(error);
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    },
                    child: const Text(
                      "Confirm",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: width < 500 ? 110 : 120,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (isLoading) const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
