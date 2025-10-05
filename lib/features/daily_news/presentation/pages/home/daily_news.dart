import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sw5e_manager/features/daily_news/presentation/bloc/articles/remote/remote_articles_bloc.dart';
import 'package:sw5e_manager/features/daily_news/presentation/bloc/articles/remote/remote_articles_state.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      title: Text(
        'Daily News',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }

  BlocBuilder<RemoteArticlesBloc, RemoteArticlesState> _buildBody() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (_,state) {
        if (state is RemoteArticlesLoading) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
        if (state is RemoteArticlesFailure) {
          return const Center(
            child: Icon(
              Icons.refresh,
            ),
          );
        }
        if (state is RemoteArticlesSuccess) {
          return ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('$index'),
              );
            },
            itemCount: state.articles.length,
          );
        }
        return const SizedBox();
      }
    );
  }
}