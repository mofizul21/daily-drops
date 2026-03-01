import 'package:flutter/material.dart';
import '../models/drop.dart';
import '../services/drop_service.dart';

class PostBox extends StatefulWidget {
  final Drop? editDrop;
  final Function(Drop)? onUpdate;
  final Function()? onCancelEdit;

  const PostBox({super.key, this.editDrop, this.onUpdate, this.onCancelEdit});

  @override
  State<PostBox> createState() => _PostBoxState();
}

class _PostBoxState extends State<PostBox> {
  final TextEditingController _textController = TextEditingController();
  final DropService _dropService = DropService();
  bool _isPosting = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.editDrop != null) {
      _isEditMode = true;
      _textController.text = widget.editDrop!.dropText;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _postDrop() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something before posting!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    final result = await _dropService.saveDrop(_textController.text.trim());

    setState(() {
      _isPosting = false;
    });

    if (result == 'success') {
      _textController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Drop posted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post: $result'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateDrop() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something before updating!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    if (widget.editDrop != null && widget.editDrop!.id != null) {
      final result = await _dropService.updateDrop(
        widget.editDrop!.id!,
        _textController.text.trim(),
      );

      setState(() {
        _isPosting = false;
      });

      if (result == 'success') {
        _textController.clear();
        setState(() {
          _isEditMode = false;
        });
        if (widget.onCancelEdit != null) {
          widget.onCancelEdit!();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Drop updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $result'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelEdit() {
    _textController.clear();
    setState(() {
      _isEditMode = false;
    });
    if (widget.onCancelEdit != null) {
      widget.onCancelEdit!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _isEditMode ? Colors.blue : Colors.orange,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _isEditMode ? 'Edit your drop' : 'What is one small win today?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Write in one sentence...',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 0,
                    ),
                  ),
                  maxLines: null,
                  minLines: 1,
                  textInputAction: TextInputAction.done,
                ),
              ),
            ),
            if (!_isEditMode) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPosting ? null : _postDrop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Post',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isPosting ? null : _cancelEdit,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isPosting ? null : _updateDrop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: _isPosting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              ),
                            )
                          : const Text(
                              'Update',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
