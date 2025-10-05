import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sw5e_manager/app/di/injection_container.dart';
import 'package:sw5e_manager/features/daily_news/presentation/bloc/articles/remote/remote_articles_bloc.dart';
import 'package:sw5e_manager/features/daily_news/presentation/bloc/articles/remote/remote_articles_event.dart';
import 'package:sw5e_manager/features/daily_news/presentation/bloc/articles/remote/remote_articles_state.dart';

class ArticlesPage extends StatelessWidget {
  const ArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RemoteArticlesBloc>()
        ..add(const RemoteArticlesRequested()), // déclenche le GET
      child: Scaffold(
        appBar: AppBar(title: const Text('Top headlines')),
        body: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
          builder: (context, state) {
            return switch (state) {
              RemoteArticlesInitial() || RemoteArticlesLoading()
                  => const Center(child: CircularProgressIndicator()),
              RemoteArticlesFailure(:final message)
                  => Center(child: Text('Erreur : $message')),
              RemoteArticlesSuccess(:final articles) => ListView.separated(
                  itemCount: articles.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final a = articles[i];
                    return ListTile(
                      title: Text(a.title ?? '(Sans titre)'),
                      subtitle: Text(a.description ?? ''),
                    );
                  },
                ),
            };
          },
        ),
      ),
    );
  }
}