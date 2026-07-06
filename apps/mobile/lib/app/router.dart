import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',

  routes: [

    GoRoute(

      path: '/',

      builder: (context, state) {

        return const Scaffold(

          body: Center(

            child: Text(

              '건강ON',

              style: TextStyle(

                fontSize: 30,

                fontWeight: FontWeight.bold,

              ),

            ),

          ),

        );

      },

    ),

  ],

);
