import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert'; // For JSON encoding/decoding

// IMPORTANT: Add web_socket_channel to your pubspec.yaml:
// dependencies:
//   flutter:
//     sdk: flutter
//   web_socket_channel: ^2.4.0 // Use the latest stable version

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multiplayer Tic-Tac-Toe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // WebSocket channel instance for communication with the server.
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isConnecting = false;

  // Game state variables, updated based on server messages.
  List<String> _gameBoard = List.filled(9, ''); // 'X', 'O', or '' for empty cells
  String? _currentPlayerSymbol; // The symbol assigned to *this* client ('X' or 'O')
  String? _turn; // Whose turn it is currently ('X' or 'O')
  String? _winner; // 'X', 'O', or 'draw' if game is over
  bool _isGameOver = false;
  String _statusMessage = 'Connect to start a game!';

  // The URL for the WebSocket server.
  // You will need a simple WebSocket server running at this address.
  // A basic Node.js example server using the 'ws' package is provided in the thought process.
  static const String _websocketUrl = 'ws://localhost:8080';

  @override
  void initState() {
    super.initState();
    // Optionally connect on app start, or wait for user action.
    // For this example, we'll let the user initiate connection.
  }

  @override
  void dispose() {
    _disconnectWebSocket(); // Ensure WebSocket is closed when the widget is disposed.
    super.dispose();
  }

  /// Initiates a connection to the WebSocket server.
  void _connectWebSocket() async {
    if (_isConnected || _isConnecting) return; // Prevent multiple connection attempts.

    setState(() {
      _isConnecting = true;
      _statusMessage = 'Connecting to $_websocketUrl...';
    });

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_websocketUrl));
      await _channel!.ready; // Wait for the WebSocket connection to be fully established.

      setState(() {
        _isConnected = true;
        _isConnecting = false;
        _statusMessage = 'Connected! Waiting for opponent...';
      });

      // Listen for incoming messages from the server.
      _channel!.stream.listen(
        (message) {
          _handleServerMessage(message.toString());
        },
        onDone: () {
          // Called when the server closes the connection or an error occurs.
          _handleDisconnection('Disconnected from server.');
        },
        onError: (error) {
          // Called if an error occurs during connection or message processing.
          _handleDisconnection('Connection error: $error');
        },
        cancelOnError: true, // Stop listening on error to prevent further issues.
      );
    } catch (e) {
      // Catch any exceptions during connection attempt (e.g., server not found).
      _handleDisconnection('Failed to connect: $e');
    }
  }

  /// Handles and processes incoming JSON messages from the WebSocket server.
  void _handleServerMessage(String rawMessage) {
    try {
      final Map<String, dynamic> message = jsonDecode(rawMessage);

      setState(() {
        switch (message['type']) {
          case 'player_assigned':
            _currentPlayerSymbol = message['symbol'] as String;
            _statusMessage = 'You are player $_currentPlayerSymbol.';
            break;
          case 'game_state':
            // Update all game-related state variables based on the server's authoritative state.
            _gameBoard = List<String>.from(message['board'] as List);
            _turn = message['turn'] as String?;
            _winner = message['winner'] as String?;
            _isGameOver = message['gameOver'] as bool;

            // Update the user-facing status message.
            if (_isGameOver) {
              if (_winner == 'draw') {
                _statusMessage = 'Game Over: It\'s a Draw!';
              } else if (_winner != null) {
                _statusMessage = 'Game Over: $_winner Wins!';
              }
            } else if (_turn != null) {
              _statusMessage = _currentPlayerSymbol == _turn
                  ? 'Your turn ($_turn)'
                  : 'Opponent\'s turn ($_turn)';
            } else {
              _statusMessage = 'Game starting...'; // Initial state before a turn is assigned.
            }
            break;
          case 'error':
            _statusMessage = 'Error: ${message['message']}';
            break;
          case 'reset': // Server-initiated game reset.
            _resetGameStateClientSide();
            _statusMessage = 'Game reset by server. Waiting for players...';
            break;
          default:
            _statusMessage = 'Unknown message type: ${message['type']}';
        }
      });
    } catch (e) {
      // Handle JSON parsing errors.
      setState(() {
        _statusMessage = 'Failed to parse message: $e. Raw: $rawMessage';
      });
    }
  }

  /// Handles the client-side logic for WebSocket disconnection.
  void _handleDisconnection(String message) {
    setState(() {
      _isConnected = false;
      _isConnecting = false;
      _statusMessage = message;
      _resetGameStateClientSide(); // Reset game state upon disconnection.
    });
    _channel?.sink.close(); // Ensure the WebSocket sink is properly closed.
    _channel = null; // Clear the channel reference.
  }

  /// Disconnects from the WebSocket server.
  void _disconnectWebSocket() {
    if (!_isConnected && !_isConnecting) return; // Only disconnect if currently connected or connecting.
    _channel?.sink.close(1000, 'Client initiated disconnect'); // Send a normal closure code.
    _handleDisconnection('Disconnected by user.');
  }

  /// Sends a move request to the server.
  void _makeMove(int index) {
    // Client-side validation to prevent sending invalid moves.
    if (!_isConnected ||
        _isGameOver ||
        _currentPlayerSymbol == null ||
        _turn != _currentPlayerSymbol ||
        _gameBoard[index] != '') {
      return; // Not connected, game over, not player's turn, or cell already occupied.
    }

    // Send the move to the server. The server will validate and broadcast the updated state.
    _sendMessage({
      'type': 'move',
      'index': index,
      'symbol': _currentPlayerSymbol,
    });
  }

  /// Sends a game reset request to the server.
  void _requestGameReset() {
    if (!_isConnected) return;
    _sendMessage({'type': 'reset_game'});
  }

  /// Resets the game state on the client side without affecting the server.
  void _resetGameStateClientSide() {
    _gameBoard = List.filled(9, '');
    _currentPlayerSymbol = null; // Player assignment needs to come from server again.
    _turn = null;
    _winner = null;
    _isGameOver = false;
    // _statusMessage is handled by _handleDisconnection or _handleServerMessage.
  }

  /// Helper function to send JSON-encoded messages over the WebSocket.
  void _sendMessage(Map<String, dynamic> data) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  /// Builds a single cell of the Tic-Tac-Toe board.
  Widget _buildCell(int index) {
    final symbol = _gameBoard[index];
    Color? textColor;
    if (symbol == 'X') {
      textColor = Theme.of(context).colorScheme.primary;
    } else if (symbol == 'O') {
      textColor = Theme.of(context).colorScheme.secondary;
    }

    return GestureDetector(
      onTap: () => _makeMove(index), // Tap to make a move.
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiplayer Tic-Tac-Toe'),
        backgroundColor: colorScheme.primaryContainer,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(
              _isConnected ? Icons.wifi : Icons.wifi_off,
              color: _isConnected ? colorScheme.primary : colorScheme.error,
              semanticLabel: _isConnected ? 'Connected' : 'Disconnected',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Connection Status and Controls Card
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              color: colorScheme.surface,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _statusMessage,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _winner != null
                                ? colorScheme.error // Highlight winner/draw message.
                                : (_isConnected
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant),
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isConnecting
                              ? null // Disable button while connecting.
                              : (_isConnected ? _disconnectWebSocket : _connectWebSocket),
                          icon: Icon(_isConnected ? Icons.link_off : Icons.link),
                          label: Text(_isConnected ? 'Disconnect' : 'Connect'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isConnected
                                ? colorScheme.errorContainer
                                : colorScheme.primaryContainer,
                            foregroundColor: _isConnected
                                ? colorScheme.onErrorContainer
                                : colorScheme.onPrimaryContainer,
                          ),
                        ),
                        // Show Reset Game button if connected and game is over or board is full.
                        if (_isConnected && (_isGameOver || _gameBoard.every((cell) => cell.isNotEmpty)))
                          ElevatedButton.icon(
                            onPressed: _requestGameReset,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset Game'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.tertiaryContainer,
                              foregroundColor: colorScheme.onTertiaryContainer,
                            ),
                          ),
                      ],
                    ),
                    if (_isConnecting) const LinearProgressIndicator(), // Show progress when connecting.
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Display current player's assigned symbol.
            if (_isConnected && _currentPlayerSymbol != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'You are: ',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      _currentPlayerSymbol!,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _currentPlayerSymbol == 'X'
                                ? colorScheme.primary
                                : colorScheme.secondary,
                          ),
                    ),
                  ],
                ),
              ),

            // The Tic-Tac-Toe game board.
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling for a fixed grid.
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return _buildCell(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
