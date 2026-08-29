// import 'package:flutter/material.dart';

// class BoardsScreen extends StatefulWidget {
//   const BoardsScreen({super.key});

//   @override
//   State<BoardsScreen> createState() =>
//       _BoardsScreenState();
// }

// class _BoardsScreenState
//     extends State<BoardsScreen> {
//   final List<String> _boards = [];

//   Future<void> _createBoard() async {
//     final controller =
//         TextEditingController();

//     final name = await showDialog<String>(
//       context: context,
//       builder: (_) {
//         return AlertDialog(
//           title:
//               const Text('Create board'),
//           content: TextField(
//             controller: controller,
//             autofocus: true,
//             decoration:
//                 const InputDecoration(
//               hintText: 'Board name',
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () =>
//                   Navigator.pop(context),
//               child:
//                   const Text('Cancel'),
//             ),
//             FilledButton(
//               onPressed: () {
//                 final name =
//                     controller.text.trim();

//                 if (name.isNotEmpty) {
//                   Navigator.pop(
//                     context,
//                     name,
//                   );
//                 }
//               },
//               child:
//                   const Text('Create'),
//             ),
//           ],
//         );
//       },
//     );

//     controller.dispose();

//     if (name == null) return;

//     setState(() {
//       _boards.add(name);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'My Boards',
//           style: TextStyle(
//             fontWeight:
//                 FontWeight.w900,
//           ),
//         ),
//         actions: [
//           IconButton(
//             onPressed: _createBoard,
//             icon: const Icon(
//               Icons.add_rounded,
//             ),
//           ),
//         ],
//       ),
//       body: _boards.isEmpty
//           ? Center(
//               child: Column(
//                 mainAxisAlignment:
//                     MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.folder_open_rounded,
//                     size: 65,
//                   ),
//                   const SizedBox(height: 15),
//                   const Text(
//                     'No boards yet',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight:
//                           FontWeight.w800,
//                     ),
//                   ),
//                   const SizedBox(height: 18),
//                   FilledButton.icon(
//                     onPressed:
//                         _createBoard,
//                     icon: const Icon(
//                       Icons.add,
//                     ),
//                     label: const Text(
//                       'Create board',
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : ListView.builder(
//               padding:
//                   const EdgeInsets.all(16),
//               itemCount:
//                   _boards.length,
//               itemBuilder: (_, index) {
//                 return Card(
//                   child: ListTile(
//                     leading: const CircleAvatar(
//                       child: Icon(
//                         Icons.folder_rounded,
//                       ),
//                     ),
//                     title:
//                         Text(_boards[index]),
//                     trailing: const Icon(
//                       Icons.chevron_right,
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class BoardsScreen extends StatefulWidget {
//   const BoardsScreen({super.key});

//   @override
//   State<BoardsScreen> createState() => _BoardsScreenState();
// }

// class _BoardsScreenState extends State<BoardsScreen> {
//   final List<String> _boards = [];

//   final TextEditingController _searchController =
//       TextEditingController();

//   String _searchQuery = '';

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   List<String> get _filteredBoards {
//     if (_searchQuery.trim().isEmpty) {
//       return _boards;
//     }

//     return _boards
//         .where(
//           (board) => board
//               .toLowerCase()
//               .contains(_searchQuery.toLowerCase()),
//         )
//         .toList();
//   }

//   Future<void> _createBoard() async {
//     final controller = TextEditingController();

//     final name = await showDialog<String>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: const Text(
//             'Create board',
//             style: TextStyle(
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//           content: TextField(
//             controller: controller,
//             autofocus: true,
//             textCapitalization: TextCapitalization.words,
//             decoration: InputDecoration(
//               hintText: 'e.g. Anime Inspiration',
//               prefixIcon: const Icon(
//                 Icons.folder_outlined,
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//             ),
//             onSubmitted: (value) {
//               if (value.trim().isNotEmpty) {
//                 Navigator.pop(
//                   dialogContext,
//                   value.trim(),
//                 );
//               }
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext);
//               },
//               child: const Text('Cancel'),
//             ),
//             FilledButton.icon(
//               onPressed: () {
//                 final value = controller.text.trim();

//                 if (value.isNotEmpty) {
//                   Navigator.pop(
//                     dialogContext,
//                     value,
//                   );
//                 }
//               },
//               icon: const Icon(Icons.add_rounded),
//               label: const Text('Create'),
//             ),
//           ],
//         );
//       },
//     );

//     controller.dispose();

//     if (!mounted || name == null || name.isEmpty) {
//       return;
//     }

//     if (_boards.any(
//       (board) => board.toLowerCase() == name.toLowerCase(),
//     )) {
//       _showMessage('A board with this name already exists.');
//       return;
//     }

//     setState(() {
//       _boards.insert(0, name);
//     });

//     _showMessage('Board created');
//   }

//   Future<void> _renameBoard(String oldName) async {
//     final controller = TextEditingController(
//       text: oldName,
//     );

//     final newName = await showDialog<String>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: const Text(
//             'Rename board',
//             style: TextStyle(
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//           content: TextField(
//             controller: controller,
//             autofocus: true,
//             textCapitalization: TextCapitalization.words,
//             decoration: InputDecoration(
//               prefixIcon: const Icon(
//                 Icons.edit_outlined,
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//             ),
//             onSubmitted: (value) {
//               if (value.trim().isNotEmpty) {
//                 Navigator.pop(
//                   dialogContext,
//                   value.trim(),
//                 );
//               }
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext);
//               },
//               child: const Text('Cancel'),
//             ),
//             FilledButton(
//               onPressed: () {
//                 final value = controller.text.trim();

//                 if (value.isNotEmpty) {
//                   Navigator.pop(
//                     dialogContext,
//                     value,
//                   );
//                 }
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );

//     controller.dispose();

//     if (!mounted || newName == null || newName.isEmpty) {
//       return;
//     }

//     final duplicate = _boards.any(
//       (board) =>
//           board.toLowerCase() == newName.toLowerCase() &&
//           board != oldName,
//     );

//     if (duplicate) {
//       _showMessage('A board with this name already exists.');
//       return;
//     }

//     final index = _boards.indexOf(oldName);

//     if (index == -1) return;

//     setState(() {
//       _boards[index] = newName;
//     });

//     _showMessage('Board renamed');
//   }

//   Future<void> _deleteBoard(String board) async {
//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: const Text(
//             'Delete board?',
//             style: TextStyle(
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to delete "$board"?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext, false);
//               },
//               child: const Text('Cancel'),
//             ),
//             FilledButton(
//               style: FilledButton.styleFrom(
//                 backgroundColor: Colors.red,
//               ),
//               onPressed: () {
//                 Navigator.pop(dialogContext, true);
//               },
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );

//     if (!mounted || shouldDelete != true) {
//       return;
//     }

//     setState(() {
//       _boards.remove(board);
//     });

//     _showMessage('Board deleted');
//   }

//   void _showMessage(String message) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(
//         SnackBar(
//           content: Text(message),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           margin: const EdgeInsets.all(16),
//         ),
//       );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colors = theme.colorScheme;
//     final boards = _filteredBoards;

//     return Scaffold(
//       backgroundColor: colors.surface,

//       appBar: AppBar(
//         elevation: 0,
//         titleSpacing: 20,
//         title: const Text(
//           'My Boards',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.w900,
//           ),
//         ),
//         actions: [
//           IconButton(
//             tooltip: 'Create board',
//             onPressed: _createBoard,
//             icon: const Icon(
//               Icons.add_rounded,
//               size: 28,
//             ),
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),

//       floatingActionButton: _boards.isNotEmpty
//           ? FloatingActionButton.extended(
//               onPressed: _createBoard,
//               icon: const Icon(Icons.add_rounded),
//               label: const Text(
//                 'New board',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             )
//           : null,

//       body: Column(
//         children: [
//           // Header
//           Padding(
//             padding: const EdgeInsets.fromLTRB(
//               20,
//               8,
//               20,
//               12,
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     _boards.isEmpty
//                         ? 'Organize your inspiration'
//                         : '${_boards.length} ${_boards.length == 1 ? 'board' : 'boards'}',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: colors.onSurfaceVariant,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 if (_boards.isNotEmpty)
//                   Icon(
//                     Icons.dashboard_outlined,
//                     size: 20,
//                     color: colors.onSurfaceVariant,
//                   ),
//               ],
//             ),
//           ),

//           // Search
//           if (_boards.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(
//                 20,
//                 4,
//                 20,
//                 14,
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 onChanged: (value) {
//                   setState(() {
//                     _searchQuery = value;
//                   });
//                 },
//                 decoration: InputDecoration(
//                   hintText: 'Search boards',
//                   prefixIcon: const Icon(
//                     Icons.search_rounded,
//                   ),
//                   suffixIcon: _searchQuery.isNotEmpty
//                       ? IconButton(
//                           onPressed: () {
//                             _searchController.clear();

//                             setState(() {
//                               _searchQuery = '';
//                             });
//                           },
//                           icon: const Icon(
//                             Icons.close_rounded,
//                           ),
//                         )
//                       : null,
//                   filled: true,
//                   fillColor:
//                       colors.surfaceContainerHighest,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(18),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding:
//                       const EdgeInsets.symmetric(
//                     vertical: 16,
//                   ),
//                 ),
//               ),
//             ),

//           Expanded(
//             child: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 300),
//               child: _boards.isEmpty
//                   ? _EmptyBoards(
//                       key: const ValueKey('empty'),
//                       onCreate: _createBoard,
//                     )
//                   : boards.isEmpty
//                       ? _NoSearchResults(
//                           key: const ValueKey('no-results'),
//                           query: _searchQuery,
//                         )
//                       : ListView.builder(
//                           key: const ValueKey('boards'),
//                           padding: const EdgeInsets.fromLTRB(
//                             20,
//                             8,
//                             20,
//                             100,
//                           ),
//                           itemCount: boards.length,
//                           itemBuilder: (context, index) {
//                             final board = boards[index];

//                             return _AnimatedBoardCard(
//                               key: ValueKey(board),
//                               board: board,
//                               index: index,
//                               onRename: () {
//                                 _renameBoard(board);
//                               },
//                               onDelete: () {
//                                 _deleteBoard(board);
//                               },
//                               onTap: () {
//                                 _showMessage(
//                                   '$board is empty. Save pins here to see them.',
//                                 );
//                               },
//                             );
//                           },
//                         ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _AnimatedBoardCard extends StatefulWidget {
//   final String board;
//   final int index;
//   final VoidCallback onRename;
//   final VoidCallback onDelete;
//   final VoidCallback onTap;

//   const _AnimatedBoardCard({
//     super.key,
//     required this.board,
//     required this.index,
//     required this.onRename,
//     required this.onDelete,
//     required this.onTap,
//   });

//   @override
//   State<_AnimatedBoardCard> createState() =>
//       _AnimatedBoardCardState();
// }

// class _AnimatedBoardCardState
//     extends State<_AnimatedBoardCard>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;

//   late final Animation<double> _fade;
//   late final Animation<Offset> _slide;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 450),
//     );

//     _fade = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOut,
//     );

//     _slide = Tween<Offset>(
//       begin: const Offset(0, 0.12),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeOutCubic,
//       ),
//     );

//     Future.delayed(
//       Duration(milliseconds: widget.index * 70),
//       () {
//         if (mounted) {
//           _controller.forward();
//         }
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colors = theme.colorScheme;

//     return FadeTransition(
//       opacity: _fade,
//       child: SlideTransition(
//         position: _slide,
//         child: Padding(
//           padding: const EdgeInsets.only(bottom: 14),
//           child: Material(
//             color: colors.surfaceContainerHighest,
//             borderRadius: BorderRadius.circular(24),
//             clipBehavior: Clip.antiAlias,
//             child: InkWell(
//               onTap: widget.onTap,
//               child: Padding(
//                 padding: const EdgeInsets.all(14),
//                 child: Row(
//                   children: [
//                     // Board preview
//                     Container(
//                       width: 78,
//                       height: 78,
//                       decoration: BoxDecoration(
//                         borderRadius:
//                             BorderRadius.circular(18),
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             colors.primaryContainer,
//                             colors.secondaryContainer,
//                           ],
//                         ),
//                       ),
//                       child: Icon(
//                         Icons.folder_rounded,
//                         size: 38,
//                         color: colors.primary,
//                       ),
//                     ),

//                     const SizedBox(width: 16),

//                     // Board information
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.board,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w900,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.push_pin_outlined,
//                                 size: 16,
//                                 color:
//                                     colors.onSurfaceVariant,
//                               ),
//                               const SizedBox(width: 5),
//                               Text(
//                                 '0 pins',
//                                 style: TextStyle(
//                                   color:
//                                       colors.onSurfaceVariant,
//                                   fontWeight:
//                                       FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 5),
//                           Text(
//                             'Tap to view board',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color:
//                                   colors.onSurfaceVariant,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     // Menu
//                     PopupMenuButton<String>(
//                       tooltip: 'Board options',
//                       onSelected: (value) {
//                         if (value == 'rename') {
//                           widget.onRename();
//                         } else if (value == 'delete') {
//                           widget.onDelete();
//                         }
//                       },
//                       itemBuilder: (_) => const [
//                         PopupMenuItem(
//                           value: 'rename',
//                           child: Row(
//                             children: [
//                               Icon(Icons.edit_outlined),
//                               SizedBox(width: 12),
//                               Text('Rename'),
//                             ],
//                           ),
//                         ),
//                         PopupMenuItem(
//                           value: 'delete',
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.delete_outline,
//                                 color: Colors.red,
//                               ),
//                               SizedBox(width: 12),
//                               Text('Delete'),
//                             ],
//                           ),
//                         ),
//                       ],
//                       child: const Padding(
//                         padding: EdgeInsets.all(8),
//                         child: Icon(
//                           Icons.more_vert_rounded,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _EmptyBoards extends StatelessWidget {
//   final VoidCallback onCreate;

//   const _EmptyBoards({
//     super.key,
//     required this.onCreate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;

//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 130,
//               height: 130,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: colors.primaryContainer,
//               ),
//               child: Icon(
//                 Icons.folder_copy_rounded,
//                 size: 64,
//                 color: colors.primary,
//               ),
//             ),

//             const SizedBox(height: 28),

//             const Text(
//               'Create your first board',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),

//             const SizedBox(height: 10),

//             Text(
//               'Save and organize your favorite anime, '
//               'cars, bikes, sports and more.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 15,
//                 height: 1.5,
//                 color: colors.onSurfaceVariant,
//               ),
//             ),

//             const SizedBox(height: 26),

//             FilledButton.icon(
//               onPressed: onCreate,
//               icon: const Icon(
//                 Icons.add_rounded,
//               ),
//               label: const Text(
//                 'Create board',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               style: FilledButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 16,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _NoSearchResults extends StatelessWidget {
//   final String query;

//   const _NoSearchResults({
//     super.key,
//     required this.query,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;

//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.search_off_rounded,
//               size: 60,
//               color: colors.onSurfaceVariant,
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'No boards found',
//               style: TextStyle(
//                 fontSize: 21,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Nothing matches "$query"',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: colors.onSurfaceVariant,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// import '../services/firestore_service.dart';

// class BoardsScreen extends StatefulWidget {
//   const BoardsScreen({super.key});

//   @override
//   State<BoardsScreen> createState() => _BoardsScreenState();
// }

// class _BoardsScreenState extends State<BoardsScreen> {
//   final FirestoreService _service = FirestoreService();

//   bool _loading = true;

//   List<QueryDocumentSnapshot<Map<String, dynamic>>> _boards = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadBoards();
//   }

//   Future<void> _loadBoards() async {
//     try {
//       final snapshot = await _service.getBoards();

//       if (!mounted) return;

//       setState(() {
//         _boards = snapshot.docs;
//         _loading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _loading = false;
//       });

//       _showMessage('Could not load boards: $e');
//     }
//   }

//   Future<void> _createBoard() async {
//     final controller = TextEditingController();

//     final name = await showDialog<String>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: const Text(
//             'Create new board',
//             style: TextStyle(
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           content: TextField(
//             controller: controller,
//             autofocus: true,
//             textCapitalization: TextCapitalization.words,
//             decoration: InputDecoration(
//               hintText: 'e.g. Anime Wallpapers',
//               prefixIcon: const Icon(
//                 Icons.folder_outlined,
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(14),
//               ),
//             ),
//             onSubmitted: (value) {
//               if (value.trim().isNotEmpty) {
//                 Navigator.pop(
//                   dialogContext,
//                   value.trim(),
//                 );
//               }
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext);
//               },
//               child: const Text('Cancel'),
//             ),
//             FilledButton.icon(
//               onPressed: () {
//                 final value = controller.text.trim();

//                 if (value.isNotEmpty) {
//                   Navigator.pop(
//                     dialogContext,
//                     value,
//                   );
//                 }
//               },
//               icon: const Icon(Icons.add),
//               label: const Text('Create'),
//             ),
//           ],
//         );
//       },
//     );

//     controller.dispose();

//     if (name == null || name.trim().isEmpty) {
//       return;
//     }

//     try {
//       await _service.createBoard(name);

//       if (!mounted) return;

//       _showMessage(
//         'Board "$name" created ✓',
//       );

//       await _loadBoards();
//     } catch (e) {
//       if (!mounted) return;

//       _showMessage(
//         'Could not create board: $e',
//       );
//     }
//   }

//   Future<void> _deleteBoard(
//     String boardId,
//     String name,
//   ) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: const Text('Delete board?'),
//           content: Text(
//             'Delete "$name" and all pins inside it?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                   false,
//                 );
//               },
//               child: const Text('Cancel'),
//             ),
//             FilledButton(
//               onPressed: () {
//                 Navigator.pop(
//                   dialogContext,
//                   true,
//                 );
//               },
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirm != true) return;

//     try {
//       await _service.deleteBoard(boardId);

//       if (!mounted) return;

//       _showMessage('Board deleted');

//       await _loadBoards();
//     } catch (e) {
//       if (!mounted) return;

//       _showMessage(
//         'Could not delete board: $e',
//       );
//     }
//   }

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'My Boards',
//           style: TextStyle(
//             fontWeight: FontWeight.w900,
//           ),
//         ),
//         actions: [
//           IconButton(
//             tooltip: 'Create board',
//             onPressed: _createBoard,
//             icon: const Icon(
//               Icons.add_rounded,
//             ),
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _loadBoards,
//         child: _loading
//             ? const Center(
//                 child: CircularProgressIndicator(),
//               )
//             : _boards.isEmpty
//                 ? _EmptyBoards(
//                     onCreate: _createBoard,
//                   )
//                 : ListView.builder(
//                     physics:
//                         const AlwaysScrollableScrollPhysics(),
//                     padding: const EdgeInsets.fromLTRB(
//                       16,
//                       10,
//                       16,
//                       30,
//                     ),
//                     itemCount: _boards.length,
//                     itemBuilder: (_, index) {
//                       final board = _boards[index];

//                       final name =
//                           board.data()['name']?.toString() ??
//                               'Untitled board';

//                       return Card(
//                         elevation: 0,
//                         margin: const EdgeInsets.only(
//                           bottom: 12,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(20),
//                         ),
//                         child: ListTile(
//                           contentPadding:
//                               const EdgeInsets.symmetric(
//                             horizontal: 18,
//                             vertical: 8,
//                           ),
//                           leading: Container(
//                             width: 50,
//                             height: 50,
//                             decoration: BoxDecoration(
//                               color: theme
//                                   .colorScheme
//                                   .primaryContainer,
//                               borderRadius:
//                                   BorderRadius.circular(15),
//                             ),
//                             child: Icon(
//                               Icons.folder_rounded,
//                               color: theme
//                                   .colorScheme
//                                   .onPrimaryContainer,
//                             ),
//                           ),
//                           title: Text(
//                             name,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w800,
//                             ),
//                           ),
//                           subtitle: const Text(
//                             'Tap to view board',
//                           ),
//                           trailing: PopupMenuButton<String>(
//                             onSelected: (value) {
//                               if (value == 'delete') {
//                                 _deleteBoard(
//                                   board.id,
//                                   name,
//                                 );
//                               }
//                             },
//                             itemBuilder: (_) => const [
//                               PopupMenuItem(
//                                 value: 'delete',
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       Icons.delete_outline,
//                                     ),
//                                     SizedBox(width: 10),
//                                     Text('Delete'),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//       ),
//       floatingActionButton: _boards.isEmpty
//           ? null
//           : FloatingActionButton.extended(
//               onPressed: _createBoard,
//               icon: const Icon(Icons.add),
//               label: const Text('New board'),
//             ),
//     );
//   }
// }

// class _EmptyBoards extends StatelessWidget {
//   final VoidCallback onCreate;

//   const _EmptyBoards({
//     required this.onCreate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       children: [
//         SizedBox(
//           height: MediaQuery.of(context).size.height * .65,
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.all(30),
//               child: Column(
//                 mainAxisAlignment:
//                     MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       color: Theme.of(context)
//                           .colorScheme
//                           .primaryContainer,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.folder_open_rounded,
//                       size: 48,
//                       color: Theme.of(context)
//                           .colorScheme
//                           .onPrimaryContainer,
//                     ),
//                   ),
//                   const SizedBox(height: 22),
//                   const Text(
//                     'Create your first board',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w900,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Organize your favorite images into collections.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Theme.of(context)
//                           .textTheme
//                           .bodyMedium
//                           ?.color
//                           ?.withOpacity(.65),
//                     ),
//                   ),
//                   const SizedBox(height: 22),
//                   FilledButton.icon(
//                     onPressed: onCreate,
//                     icon: const Icon(Icons.add),
//                     label: const Text('Create board'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/pin.dart';
import '../services/firestore_service.dart';

class BoardsScreen extends StatefulWidget {
  const BoardsScreen({super.key});

  @override
  State<BoardsScreen> createState() => _BoardsScreenState();
}

class _BoardsScreenState extends State<BoardsScreen> {
  final FirestoreService _service = FirestoreService();

  bool _loading = true;
  bool _creating = false;

  String? _error;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _boards = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadBoards();
      }
    });
  }

  // ============================================================
  // LOAD BOARDS
  // ============================================================

  Future<void> _loadBoards() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final snapshot = await _service.getBoards();

      if (!mounted) return;

      setState(() {
        _boards = snapshot.docs;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  // ============================================================
  // CREATE BOARD
  // ============================================================

  Future<void> _createBoard() async {
    if (_creating) return;

    final name = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return const _CreateBoardDialog();
      },
    );

    if (!mounted) return;

    if (name == null || name.trim().isEmpty) {
      return;
    }

    setState(() {
      _creating = true;
      _error = null;
    });

    try {
      await _service.createBoard(name.trim());

      if (!mounted) return;

      final snapshot = await _service.getBoards();

      if (!mounted) return;

      setState(() {
        _boards = snapshot.docs;
        _creating = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _creating = false;
        _error = e.toString();
      });
    }
  }

  // ============================================================
  // DELETE BOARD
  // ============================================================

  Future<void> _deleteBoard(
    String boardId,
    String boardName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete board?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Delete "$boardName" and all pins inside this board?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    try {
      await _service.deleteBoard(boardId);

      if (!mounted) return;

      await _loadBoards();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    }
  }

  // ============================================================
  // OPEN BOARD
  // ============================================================

  void _openBoard(
    String boardId,
    String boardName,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BoardDetailScreen(
          boardId: boardId,
          boardName: boardName,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'My Boards',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Create board',
            onPressed: _creating ? null : _createBoard,
            icon: _creating
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.add_rounded,
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBoards,
        child: _buildBody(),
      ),
      floatingActionButton: _boards.isEmpty || _loading
          ? null
          : FloatingActionButton.extended(
              onPressed: _creating ? null : _createBoard,
              icon: const Icon(
                Icons.add_rounded,
              ),
              label: const Text(
                'Create board',
              ),
            ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 500,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    if (_error != null) {
      return _ErrorBoards(
        message: _error!,
        onRetry: _loadBoards,
      );
    }

    if (_boards.isEmpty) {
      return _EmptyBoards(
        onCreate: _createBoard,
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        100,
      ),
      itemCount: _boards.length,
      itemBuilder: (context, index) {
        final board = _boards[index];

        final data = board.data();

        final name = data['name']?.toString() ?? 'Untitled board';

        return _BoardCard(
          name: name,
          onTap: () {
            _openBoard(
              board.id,
              name,
            );
          },
          onDelete: () {
            _deleteBoard(
              board.id,
              name,
            );
          },
        );
      },
    );
  }
}

// =====================================================================
// BOARD CARD
// =====================================================================

class _BoardCard extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BoardCard({
    required this.name,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  Icons.folder_rounded,
                  size: 30,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap to view board',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete board',
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// CREATE BOARD DIALOG
// =====================================================================

class _CreateBoardDialog extends StatefulWidget {
  const _CreateBoardDialog();

  @override
  State<_CreateBoardDialog> createState() => _CreateBoardDialogState();
}

class _CreateBoardDialogState extends State<_CreateBoardDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _create() {
    final name = _controller.text.trim();

    if (name.isEmpty) {
      return;
    }

    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Create new board',
        style: TextStyle(
          fontWeight: FontWeight.w800,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: 'e.g. Anime Wallpapers',
          prefixIcon: const Icon(
            Icons.folder_outlined,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onSubmitted: (_) {
          _create();
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _create,
          icon: const Icon(
            Icons.add_rounded,
          ),
          label: const Text(
            'Create',
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// EMPTY BOARDS
// =====================================================================

class _EmptyBoards extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyBoards({
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * .70,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.folder_open_rounded,
                      size: 52,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  const Text(
                    'Create your first board',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Organize your favorite images into collections.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(.65),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  FilledButton.icon(
                    onPressed: onCreate,
                    icon: const Icon(
                      Icons.add_rounded,
                    ),
                    label: const Text(
                      'Create board',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// ERROR SCREEN
// =====================================================================

class _ErrorBoards extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBoards({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * .70,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  const Text(
                    'Could not load boards',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(.70),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                    label: const Text(
                      'Try again',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// BOARD DETAIL SCREEN
// =====================================================================

class BoardDetailScreen extends StatelessWidget {
  final String boardId;
  final String boardName;

  const BoardDetailScreen({
    super.key,
    required this.boardId,
    required this.boardName,
  });

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          boardName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: StreamBuilder<List<Pin>>(
        stream: service.watchBoard(boardId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _BoardError(
              message: snapshot.error.toString(),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final pins = snapshot.data ?? [];

          if (pins.isEmpty) {
            return const _EmptyBoardPins();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: .72,
            ),
            itemCount: pins.length,
            itemBuilder: (context, index) {
              return _BoardPinCard(
                pin: pins[index],
              );
            },
          );
        },
      ),
    );
  }
}

// =====================================================================
// BOARD PIN CARD
// =====================================================================

class _BoardPinCard extends StatelessWidget {
  final Pin pin;

  const _BoardPinCard({
    required this.pin,
  });

  @override
  Widget build(BuildContext context) {
    /*
     * We use toMap() instead of assuming a specific
     * Pin property name.
     *
     * This makes this screen compatible with your
     * existing Pin model.
     */

    final data = pin.toMap();

    final imageUrl = _getString(
      data,
      [
        'imageUrl',
        'image',
        'url',
        'src',
      ],
    );

    final title = _getString(
      data,
      [
        'title',
        'name',
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const _BrokenImage();
              },
            )
          else
            const _BrokenImage(),
          if (title.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  28,
                  12,
                  12,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black87,
                    ],
                  ),
                ),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getString(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return '';
  }
}

// =====================================================================
// EMPTY BOARD
// =====================================================================

class _EmptyBoardPins extends StatelessWidget {
  const _EmptyBoardPins();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: 50,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            const Text(
              'No pins yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Save pins to this board and they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// BOARD ERROR
// =====================================================================

class _BoardError extends StatelessWidget {
  final String message;

  const _BoardError({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
            ),
            const SizedBox(
              height: 18,
            ),
            const Text(
              'Could not load pins',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// BROKEN IMAGE
// =====================================================================

class _BrokenImage extends StatelessWidget {
  const _BrokenImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 42,
        ),
      ),
    );
  }
}
