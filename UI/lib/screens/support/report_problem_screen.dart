import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/report_problem_provider.dart';
import '../../theme/app_theme.dart';

class ReportProblemScreen extends ConsumerStatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  ConsumerState<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends ConsumerState<ReportProblemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(reportProblemProvider.notifier).submit(
          description: _descCtrl.text.trim(),
        );
    if (!mounted) return;

    final state = ref.read(reportProblemProvider);
    if (state.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Problem reported — we will look into it.')),
      );
      Navigator.pop(context);
      return;
    }

    if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportProblemProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        title: const Text('Report a problem', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Describe the problem', style: AppTextStyles.heading3),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'What happened? Include booking id if relevant',
                  ),
                  validator: (v) => (v == null || v.trim().length < 6)
                      ? 'Please enter a short description'
                      : null,
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: reportState.isLoading ? null : _submit,
                  child: reportState.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send Report'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
